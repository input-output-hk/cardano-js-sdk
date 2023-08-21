import { BehaviorSubject, EMPTY, of } from 'rxjs';
import { Cardano, ProviderError, ProviderFailure, Serialization, TxSubmitProvider } from '@cardano-sdk/core';
import { ConnectionStatus, SmartTxSubmitProvider, TipSlot } from '../../src';
import { RetryBackoffConfig } from 'backoff-rxjs';
import { flushPromises, mockProviders } from '@cardano-sdk/util-dev';
import { usingAutoFree } from '@cardano-sdk/util';

describe('SmartTxSubmitProvider', () => {
  let underlyingProvider: jest.Mocked<TxSubmitProvider>;
  let provider: SmartTxSubmitProvider;
  const retryBackoffConfig: RetryBackoffConfig = { initialInterval: 1 };

  beforeEach(() => (underlyingProvider = mockProviders.mockTxSubmitProvider()));

  describe('healthCheck', () => {
    it('calls underlying provider', () => {
      provider = new SmartTxSubmitProvider(
        { retryBackoffConfig },
        { connectionStatus$: EMPTY, tip$: EMPTY, txSubmitProvider: underlyingProvider }
      );
      expect(provider.healthCheck()).toEqual(underlyingProvider.healthCheck());
      expect(underlyingProvider.healthCheck).toBeCalledTimes(2);
    });
  });

  describe('submitTx', () => {
    const txWithoutValidityInterval: Cardano.Tx = {
      body: {
        fee: 0n,
        inputs: [],
        outputs: [],
        validityInterval: {}
      },
      id: Cardano.TransactionId('6804edf9712d2b619edb6ac86861fe93a730693183a262b165fcc1ba1bc99cad'),
      witness: { signatures: new Map() }
    };
    const validityInterval = { invalidBefore: Cardano.Slot(5), invalidHereafter: Cardano.Slot(10) };
    const txWithoutValidityIntervalHex = usingAutoFree((scope) =>
      scope.manage(Serialization.Transaction.fromCore(scope, txWithoutValidityInterval)).toCbor()
    );
    const txWithValidityIntervalHex = usingAutoFree((scope) =>
      scope
        .manage(
          Serialization.Transaction.fromCore(scope, {
            ...txWithoutValidityInterval,
            body: {
              ...txWithoutValidityInterval.body,
              validityInterval
            }
          })
        )
        .toCbor()
    );

    describe('all preconditions are met', () => {
      beforeEach(() => {
        provider = new SmartTxSubmitProvider(
          { retryBackoffConfig },
          {
            connectionStatus$: of(ConnectionStatus.up),
            tip$: of({ slot: validityInterval.invalidBefore }),
            txSubmitProvider: underlyingProvider
          }
        );
      });

      it('calls underlying provider when online and tx has no validity interval', async () => {
        await provider.submitTx({ signedTransaction: txWithoutValidityIntervalHex });
        expect(underlyingProvider.submitTx).toBeCalledTimes(1);
      });

      it('calls underlying provider when online and within validity interval', async () => {
        await provider.submitTx({ signedTransaction: txWithValidityIntervalHex });
        expect(underlyingProvider.submitTx).toBeCalledTimes(1);
      });

      it('re-submits transactions that failed to submit due to a recoverable provider failure', async () => {
        underlyingProvider.submitTx
          .mockRejectedValueOnce(new ProviderError(ProviderFailure.ConnectionFailure))
          .mockRejectedValueOnce(new ProviderError(ProviderFailure.Unhealthy))
          .mockRejectedValueOnce(new ProviderError(ProviderFailure.Unknown));
        await provider.submitTx({ signedTransaction: txWithValidityIntervalHex });
        expect(underlyingProvider.submitTx).toBeCalledTimes(4);
      });

      it('rejects with any non-recoverable provider error', async () => {
        const error = new ProviderError(ProviderFailure.BadRequest);
        underlyingProvider.submitTx.mockRejectedValueOnce(error);
        await expect(provider.submitTx({ signedTransaction: txWithValidityIntervalHex })).rejects.toThrowError(error);
        expect(underlyingProvider.submitTx).toBeCalledTimes(1);
      });
    });

    it('immediately rejects if network tip is already >= `ValidityInterval.invalidHereafter`', async () => {
      provider = new SmartTxSubmitProvider(
        { retryBackoffConfig },
        {
          connectionStatus$: of(ConnectionStatus.up),
          tip$: of({ slot: validityInterval.invalidHereafter }),
          txSubmitProvider: underlyingProvider
        }
      );
      await expect(provider.submitTx({ signedTransaction: txWithValidityIntervalHex })).rejects.toThrowError(
        ProviderFailure.BadRequest
      );
      expect(underlyingProvider.submitTx).toBeCalledTimes(0);
    });

    it('awaits for network tip to be ahead of tx body `ValidityInterval.invalidBefore` before submitting', async () => {
      const tip$ = new BehaviorSubject<TipSlot>({ slot: Cardano.Slot(validityInterval.invalidBefore - 1) });
      provider = new SmartTxSubmitProvider(
        { retryBackoffConfig },
        {
          connectionStatus$: of(ConnectionStatus.up),
          tip$,
          txSubmitProvider: underlyingProvider
        }
      );
      const submitted = provider.submitTx({ signedTransaction: txWithValidityIntervalHex });
      await flushPromises();
      expect(underlyingProvider.submitTx).not.toBeCalled();
      tip$.next({ slot: validityInterval.invalidBefore });
      await submitted;
      expect(underlyingProvider.submitTx).toBeCalledTimes(1);
    });

    it('awaits for connection status to be "up" before submitting', async () => {
      const connectionStatus$ = new BehaviorSubject<ConnectionStatus>(ConnectionStatus.down);
      provider = new SmartTxSubmitProvider(
        { retryBackoffConfig },
        {
          connectionStatus$,
          tip$: of({ slot: validityInterval.invalidBefore }),
          txSubmitProvider: underlyingProvider
        }
      );
      const submitted = provider.submitTx({ signedTransaction: txWithValidityIntervalHex });
      await flushPromises();
      expect(underlyingProvider.submitTx).not.toBeCalled();
      connectionStatus$.next(ConnectionStatus.up);
      await submitted;
      expect(underlyingProvider.submitTx).toBeCalledTimes(1);
    });
  });
});
