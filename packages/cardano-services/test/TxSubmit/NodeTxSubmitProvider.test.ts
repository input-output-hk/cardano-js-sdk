import {
  Cardano,
  HandleProvider,
  HealthCheckResponse,
  ProviderError,
  ProviderFailure,
  TxSubmissionError,
  TxSubmissionErrorCode
} from '@cardano-sdk/core';
import { EMPTY, ReplaySubject, of, throwError } from 'rxjs';
import { HexBlob } from '@cardano-sdk/util';
import { NoCache, NodeTxSubmitProvider, NodeTxSubmitProviderProps } from '../../src';
import { generateRandomHexString } from '@cardano-sdk/util-dev';
import { dummyLogger as logger } from 'ts-log';

const mockHandleResolution = {
  cardanoAddress: Cardano.PaymentAddress(
    'addr_test1qqk4sr4f7vtqzd2w90d5nfu3n59jhhpawyphnek2y7er02nkrezryq3ydtmkg0e7e2jvzg443h0ffzfwd09wpcxy2fuqmcnecd'
  ),
  handle: 'alice',
  hasDatum: false,
  policyId: Cardano.PolicyId('50fdcdbfa3154db86a87e4b5697ae30d272e0bbcfa8122efd3e301cb'),
  resolvedAt: {
    hash: Cardano.BlockId('10d64cc11e9b20e15b6c46aa7b1fed11246f437e62225655a30ea47bf8cc22d0'),
    slot: Cardano.Slot(37_834_496)
  }
};

const emptyUintArrayAsHexString = HexBlob('');

describe('NodeTxSubmitProvider', () => {
  let cardanoNode: {
    healthCheck$: ReplaySubject<HealthCheckResponse>;
    submitTx: jest.MockedFunction<NodeTxSubmitProviderProps['cardanoNode']['submitTx']>;
  };
  let provider: NodeTxSubmitProvider;
  let handleProvider: jest.Mocked<HandleProvider>;

  // const responseWithServiceState = healthCheckResponseMock({ withTip: false });

  beforeEach(async () => {
    cardanoNode = { healthCheck$: new ReplaySubject(1), submitTx: jest.fn() };
  });

  afterEach(() => cardanoNode.healthCheck$.complete());

  const assertSubmissionWithoutContext = async () => {
    cardanoNode.submitTx.mockReturnValueOnce(of(Cardano.TransactionId(generateRandomHexString(64))));
    const res = await provider.submitTx({ signedTransaction: emptyUintArrayAsHexString });
    expect(res).toBeUndefined();
    expect(cardanoNode.submitTx).toBeCalledTimes(1);
  };

  describe('without handle provider', () => {
    beforeEach(async () => {
      provider = new NodeTxSubmitProvider({ cardanoNode, healthCheckCache: new NoCache(), logger });
    });

    describe('submitTx', () => {
      it('successfully submits a transaction without handle context', assertSubmissionWithoutContext);

      it('rejects with a ProviderError when cardanoNode.submitTx errors', async () => {
        const error = new TxSubmissionError(TxSubmissionErrorCode.EraMismatch, {}, 'Era mismatch');
        cardanoNode.submitTx.mockReturnValueOnce(throwError(() => error));
        await expect(provider.submitTx({ signedTransaction: emptyUintArrayAsHexString })).rejects.toThrowError(
          expect.objectContaining({
            innerError: error,
            name: ProviderError.name,
            reason: ProviderFailure.BadRequest
          })
        );
      });

      it('rejects with a ProviderError when cardanoNode.submitTx completes without emitting', async () => {
        cardanoNode.submitTx.mockReturnValueOnce(EMPTY);
        await expect(provider.submitTx({ signedTransaction: emptyUintArrayAsHexString })).rejects.toThrowError(
          expect.objectContaining({
            name: ProviderError.name,
            reason: ProviderFailure.ServerUnavailable
          })
        );
      });
    });

    describe('healthCheck', () => {
      it('resolves with first value emitted from node healthCheck$', async () => {
        const response = { ok: true };
        cardanoNode.healthCheck$.next(response);
        await expect(provider.healthCheck()).resolves.toEqual(response);
      });

      it('resolves with {ok: false} when healthCheck$ completes without emitting', async () => {
        cardanoNode.healthCheck$.complete();
        await expect(provider.healthCheck()).resolves.toMatchObject({ ok: false });
      });

      it('resolves with {ok: false} when healthCheck$ errors', async () => {
        cardanoNode.healthCheck$.error(new Error('any error'));
        await expect(provider.healthCheck()).resolves.toMatchObject({ ok: false });
      });
    });
  });

  describe('with handle provider', () => {
    beforeEach(() => {
      handleProvider = { getPolicyIds: jest.fn(), healthCheck: jest.fn(), resolveHandles: jest.fn() };
      provider = new NodeTxSubmitProvider({ cardanoNode, handleProvider, healthCheckCache: new NoCache(), logger });
    });

    describe('initialized provider', () => {
      describe('healthCheck', () => {
        it('resolves with {ok: false} when cardanoNode.healthCheck$ emits an unhealthy response', async () => {
          handleProvider.healthCheck.mockResolvedValueOnce({ ok: true });
          cardanoNode.healthCheck$.next({ ok: false });
          const res = await provider.healthCheck();
          expect(res).toMatchObject({ ok: false });
        });

        it('resolves with {ok: false} when handleProvider emits an unhealthy response', async () => {
          handleProvider.healthCheck.mockResolvedValueOnce({ ok: false });
          cardanoNode.healthCheck$.next({ ok: true });
          const res = await provider.healthCheck();
          expect(res).toMatchObject({ ok: false });
        });

        it('resolves with {ok: true} when both handleProvider and cardanoNode are healthy', async () => {
          handleProvider.healthCheck.mockResolvedValueOnce({ ok: true });
          cardanoNode.healthCheck$.next({ ok: true });
          const res = await provider.healthCheck();
          expect(res).toMatchObject({ ok: true });
        });
      });

      describe('submitTx', () => {
        it('successfully submits a transaction without handle context', assertSubmissionWithoutContext);

        it('successfully submits if handles resolve to same addresses as in context', async () => {
          handleProvider.resolveHandles.mockResolvedValueOnce([mockHandleResolution]);
          cardanoNode.submitTx.mockReturnValueOnce(of(Cardano.TransactionId(generateRandomHexString(64))));
          const res = await provider.submitTx({
            context: {
              handleResolutions: [mockHandleResolution]
            },
            signedTransaction: emptyUintArrayAsHexString
          });
          expect(res).toBeUndefined();
          expect(handleProvider.resolveHandles).toBeCalledTimes(1);
        });

        it('rejects with an error if handles resolve to different addresses than in context', async () => {
          handleProvider.resolveHandles = jest.fn().mockResolvedValue([
            {
              ...mockHandleResolution,
              cardanoAddress: Cardano.PaymentAddress(
                'addr_test1qq585l3hyxgj3nas2v3xymd23vvartfhceme6gv98aaeg9muzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475q2g7k3g'
              )
            }
          ]);
          await expect(
            provider.submitTx({
              context: {
                handleResolutions: [mockHandleResolution]
              },
              signedTransaction: emptyUintArrayAsHexString
            })
          ).rejects.toThrowError(
            expect.objectContaining({
              name: ProviderError.name,
              reason: ProviderFailure.Conflict
            })
          );
        });
      });
    });
  });
});
