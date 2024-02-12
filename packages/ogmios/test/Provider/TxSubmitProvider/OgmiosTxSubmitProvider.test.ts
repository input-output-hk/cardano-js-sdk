import { Cardano, CardanoNodeErrors, ProviderError } from '@cardano-sdk/core';
import { Connection, createConnectionObject } from '@cardano-ogmios/client';
import { KoraLabsHandleProvider } from '@cardano-sdk/cardano-services-client';
import { OgmiosTxSubmitProvider } from '../../../src';
import { bufferToHexString } from '@cardano-sdk/util';
import { createMockOgmiosServer, listenPromise, serverClosePromise } from '../../mocks/mockOgmiosServer';
import { getRandomPort } from 'get-port-please';
import { healthCheckResponseMock } from '../../../../core/test/CardanoNode/mocks';
import { dummyLogger as logger } from 'ts-log';
import http from 'http';

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

jest.mock('@cardano-sdk/cardano-services-client', () => ({
  ...jest.requireActual('@cardano-sdk/cardano-services-client'),
  KoraLabsHandleProvider: jest.fn().mockImplementation(() => ({
    healthCheck: jest.fn(),
    resolveHandles: jest.fn().mockResolvedValue([
      {
        ...mockHandleResolution,

        cardanoAddress: Cardano.PaymentAddress(
          'addr_test1qqk4sr4f7vtqzd2w90d5nfu3n59jhhpawyphnek2y7er02nkrezryq3ydtmkg0e7e2jvzg443h0ffzfwd09wpcxy2fuqmcnecd'
        )
      }
    ])
  }))
}));

const handleProvider = new KoraLabsHandleProvider({
  policyId: Cardano.PolicyId('50fdcdbfa3154db86a87e4b5697ae30d272e0bbcfa8122efd3e301cb'),
  serverUrl: 'https://localhost:3000'
});

const emptyUintArrayAsHexString = bufferToHexString(Buffer.from(new Uint8Array()));

describe('OgmiosTxSubmitProvider', () => {
  let mockServer: http.Server;
  let connection: Connection;
  let provider: OgmiosTxSubmitProvider;

  const responseWithServiceState = healthCheckResponseMock({ withTip: false });

  beforeAll(async () => {
    connection = createConnectionObject({ port: await getRandomPort() });
  });

  describe('healthCheck', () => {
    afterEach(async () => {
      if (mockServer !== undefined) {
        await serverClosePromise(mockServer);
      }
    });

    it('is not ok if cannot connect', async () => {
      provider = new OgmiosTxSubmitProvider(connection, { logger });
      const res = await provider.healthCheck();
      expect(res).toEqual({ ok: false });
    });

    it('is ok if node is close to the network tip', async () => {
      mockServer = createMockOgmiosServer({
        healthCheck: { response: { networkSynchronization: 0.999, success: true } },
        submitTx: { response: { success: true } }
      });
      await listenPromise(mockServer, connection.port);
      provider = new OgmiosTxSubmitProvider(connection, { logger });
      const res = await provider.healthCheck();
      expect(res).toEqual(responseWithServiceState);
    });

    it('is not ok if node is not close to the network tip', async () => {
      mockServer = createMockOgmiosServer({
        healthCheck: { response: { networkSynchronization: 0.8, success: true } },
        submitTx: { response: { success: true } }
      });
      await listenPromise(mockServer, connection.port);
      provider = new OgmiosTxSubmitProvider(connection, { logger });
      const res = await provider.healthCheck();
      expect(res).toEqual({
        ...responseWithServiceState,
        localNode: { ...responseWithServiceState.localNode, networkSync: 0.8 },
        ok: false
      });
    });

    it('returns not ok if the Ogmios server throws an error', async () => {
      mockServer = createMockOgmiosServer({
        healthCheck: { response: { failWith: new Error('Some error'), success: false } },
        submitTx: { response: { success: true } }
      });
      await listenPromise(mockServer, connection.port);
      provider = new OgmiosTxSubmitProvider(connection, { logger });
      const health = await provider.healthCheck();
      expect(health.ok).toBe(false);
    });
  });

  describe('submitTx', () => {
    afterEach(async () => {
      await provider.shutdown();
      await serverClosePromise(mockServer);
    });
    it('resolves if successful', async () => {
      mockServer = createMockOgmiosServer({ submitTx: { response: { success: true } } });
      await listenPromise(mockServer, connection.port);
      provider = new OgmiosTxSubmitProvider(connection, { logger });
      await provider.initialize();
      await provider.start();

      const res = await provider.submitTx({ signedTransaction: emptyUintArrayAsHexString });
      expect(res).toBeUndefined();
    });

    it('rejects with errors thrown by the service', async () => {
      mockServer = createMockOgmiosServer({
        submitTx: { response: { failWith: { type: 'eraMismatch' }, success: false } }
      });
      await listenPromise(mockServer, connection.port);
      provider = new OgmiosTxSubmitProvider(connection, { logger });
      await provider.initialize();
      await provider.start();

      await expect(provider.submitTx({ signedTransaction: emptyUintArrayAsHexString })).rejects.toThrowError(
        CardanoNodeErrors.TxSubmissionErrors.EraMismatchError
      );
    });

    it('does not throw an error if handles resolve to same addresses as in context', async () => {
      mockServer = createMockOgmiosServer({ submitTx: { response: { success: true } } });
      await listenPromise(mockServer, connection.port);
      provider = new OgmiosTxSubmitProvider(
        connection,
        { logger },
        new KoraLabsHandleProvider({
          policyId: Cardano.PolicyId('50fdcdbfa3154db86a87e4b5697ae30d272e0bbcfa8122efd3e301cb'),
          serverUrl: 'https://localhost:3000'
        })
      );
      await provider.initialize();
      await provider.start();

      const res = await provider.submitTx({
        context: {
          handleResolutions: [mockHandleResolution]
        },
        signedTransaction: emptyUintArrayAsHexString
      });
      expect(res).toBeUndefined();
    });

    it('throws an error if handles resolve to different addresses than in context', async () => {
      mockServer = createMockOgmiosServer({ submitTx: { response: { success: true } } });
      await listenPromise(mockServer, connection.port);
      provider = new OgmiosTxSubmitProvider(connection, { logger }, handleProvider);
      await provider.initialize();
      await provider.start();

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
      ).rejects.toThrowError(ProviderError);
    });
  });

  describe('shutdown', () => {
    beforeAll(async () => {
      mockServer = createMockOgmiosServer({ stateQuery: { systemStart: { response: { success: true } } } });
      await listenPromise(mockServer, connection.port);
    });

    afterAll(async () => {
      await serverClosePromise(mockServer);
    });

    beforeEach(async () => {
      provider = new OgmiosTxSubmitProvider(connection, { logger });
      await provider.initialize();
      await provider.start();
    });

    it('shuts down successfully', async () => {
      await expect(provider.shutdown()).resolves.not.toThrow();
    });

    it('throws when querying after shutting down', async () => {
      await provider.shutdown();
      await expect(provider.submitTx({ signedTransaction: emptyUintArrayAsHexString })).rejects.toThrowError(
        CardanoNodeErrors.NotInitializedError
      );
    });
  });
});
