/* eslint-disable max-len */
import { BlockNoModel, findLastBlockNo } from '../../src/util/DbSyncProvider';
import { Cardano, ProviderError, ProviderFailure, UtxoProvider } from '@cardano-sdk/core';
import { CreateHttpProviderConfig, utxoHttpProvider } from '@cardano-sdk/cardano-services-client';
import { DbSyncUtxoProvider, HttpServer, HttpServerConfig, UtxoHttpService } from '../../src';
import { INFO, createLogger } from 'bunyan';
import { OgmiosCardanoNode } from '@cardano-sdk/ogmios';
import { Pool } from 'pg';
import { getPort } from 'get-port-please';
import { healthCheckResponseMock, mockCardanoNode } from '../../../core/test/CardanoNode/mocks';
import { logger } from '@cardano-sdk/util-dev';
import axios from 'axios';

const APPLICATION_JSON = 'application/json';
const APPLICATION_CBOR = 'application/cbor';
const UNSUPPORTED_MEDIA_STRING = 'Request failed with status code 415';
const BAD_REQUEST_STRING = 'Request failed with status code 400';
const toCardanoAddresses = (addresses: string[]) => addresses.map((a) => Cardano.Address(a));
describe('UtxoHttpService', () => {
  let dbConnection: Pool;
  let httpServer: HttpServer;
  let utxoProvider: DbSyncUtxoProvider;
  let service: UtxoHttpService;
  let port: number;
  let baseUrl: string;
  let clientConfig: CreateHttpProviderConfig<UtxoProvider>;
  let config: HttpServerConfig;
  let cardanoNode: OgmiosCardanoNode;
  let provider: UtxoProvider;
  let lastBlockNoInDb: Cardano.BlockNo;

  beforeAll(async () => {
    port = await getPort();
    baseUrl = `http://localhost:${port}/utxo`;
    clientConfig = { baseUrl, logger: createLogger({ level: INFO, name: 'unit tests' }) };
    config = { listen: { port } };
    dbConnection = new Pool({ connectionString: process.env.POSTGRES_CONNECTION_STRING });
  });

  describe('unhealthy UtxoProvider', () => {
    beforeEach(async () => {
      utxoProvider = {
        healthCheck: jest.fn(() => Promise.resolve({ ok: false })),
        utxoByAddresses: jest.fn()
      } as unknown as DbSyncUtxoProvider;
    });
    it('should not throw during service create if the UtxoProvider is unhealthy', () => {
      expect(() => new UtxoHttpService({ logger, utxoProvider })).not.toThrow(
        new ProviderError(ProviderFailure.Unhealthy)
      );
    });

    it('throws during service initialization if the UtxoProvider is unhealthy', async () => {
      service = new UtxoHttpService({ logger, utxoProvider });
      httpServer = new HttpServer(config, { logger, runnableDependencies: [], services: [service] });
      await expect(httpServer.initialize()).rejects.toThrow(new ProviderError(ProviderFailure.Unhealthy));
    });
  });

  describe('healthy state', () => {
    beforeAll(async () => {
      lastBlockNoInDb = (await dbConnection.query<BlockNoModel>(findLastBlockNo)).rows[0].block_no;
      cardanoNode = mockCardanoNode(
        healthCheckResponseMock({ blockNo: lastBlockNoInDb })
      ) as unknown as OgmiosCardanoNode;
      utxoProvider = new DbSyncUtxoProvider({ cardanoNode, db: dbConnection, logger });
      service = new UtxoHttpService({ logger, utxoProvider });
      provider = utxoHttpProvider(clientConfig);
      httpServer = new HttpServer(config, { logger, runnableDependencies: [cardanoNode], services: [service] });
      await httpServer.initialize();
      await httpServer.start();
    });
    afterAll(async () => {
      await dbConnection.end();
      await httpServer.shutdown();
    });

    describe('/health', () => {
      it('forwards the utxoProvider health response with HTTP request', async () => {
        const res = await axios.post(`${baseUrl}/health`, undefined, {
          headers: { 'Content-Type': APPLICATION_JSON }
        });
        expect(res.status).toBe(200);
        expect(res.data).toEqual(healthCheckResponseMock({ blockNo: lastBlockNoInDb }));
      });

      it('forwards the utxoProvider health response with provider client', async () => {
        const response = await provider.healthCheck();
        expect(response).toEqual(healthCheckResponseMock({ blockNo: lastBlockNoInDb }));
      });
    });

    describe('/utxo-by-addresses', () => {
      it('returns a 415 coded response if the wrong content type header is used', async () => {
        try {
          await axios.post(
            `${baseUrl}/utxo-by-addresses`,
            { args: [[]] },
            { headers: { 'Content-Type': APPLICATION_CBOR } }
          );
          // eslint-disable-next-line @typescript-eslint/no-explicit-any
        } catch (error: any) {
          expect(error.response.status).toBe(415);
          expect(error.message).toBe(UNSUPPORTED_MEDIA_STRING);
        }
      });

      it('returns 400 coded respons if the request is bad formed', async () => {
        try {
          await axios.post(`${baseUrl}/utxo-by-addresses`, { addresses: ['asd'] });
          // eslint-disable-next-line @typescript-eslint/no-explicit-any
        } catch (error: any) {
          expect(error.response.status).toBe(400);
          expect(error.message).toBe(BAD_REQUEST_STRING);
        }
      });

      it('valid request should pass OpenApi schema validations', async () => {
        const addresses = ['asd'];
        const res = await axios.post(`${baseUrl}/utxo-by-addresses`, { addresses });
        expect(res.status).toEqual(200);
      });

      it('return UTxOs for a single address', async () => {
        const res = await provider.utxoByAddresses({
          addresses: [
            Cardano.Address(
              'addr_test1qpcnmvyjmxmsm75f747u566gw7ewz4mesdw7yl278uf9r3f5l7d7dpx2ymfwlm3e56flupga8yamjr2kwdt7dw77ktyqqtx2r7'
            )
          ]
        });
        expect(res).toMatchSnapshot();
      });

      it('return UTxOs for multiple addresses', async () => {
        const addresses = [
          'addr_test1qp620qa3rqzd5fxj3hy4dughv7xx2dt9gu9de70jf8hagdcvmqt35f2psxv7ajj5jnh4ajlc752rert8f9msffxdl45qyjefw8',
          'addr_test1qryz24mkq35j8s67fdrm44pe8na7n3tqkmyzy3sgnjq3d7szlx56h6fkjl8y3p73zpyce04eku9w943rcr6rgznp8cwq2axy9q',
          'addr_test1qpcnmvyjmxmsm75f747u566gw7ewz4mesdw7yl278uf9r3f5l7d7dpx2ymfwlm3e56flupga8yamjr2kwdt7dw77ktyqqtx2r7'
        ];
        const res = await provider.utxoByAddresses({ addresses: toCardanoAddresses(addresses) });
        expect(res).toMatchSnapshot();
      });

      it('returns UTxOs containing multiple assets', async () => {
        const addresses = [
          'addr_test1qp620qa3rqzd5fxj3hy4dughv7xx2dt9gu9de70jf8hagdcvmqt35f2psxv7ajj5jnh4ajlc752rert8f9msffxdl45qyjefw8',
          'addr_test1qryz24mkq35j8s67fdrm44pe8na7n3tqkmyzy3sgnjq3d7szlx56h6fkjl8y3p73zpyce04eku9w943rcr6rgznp8cwq2axy9q'
        ];
        const res = await provider.utxoByAddresses({ addresses: toCardanoAddresses(addresses) });
        expect(res).toMatchSnapshot();
      });

      it('returns UTxOs containing multiple assets and one of the assets has no name', async () => {
        const addressAssociatedWithUTxOWithNoAssetName =
          'addr_test1qp620qa3rqzd5fxj3hy4dughv7xx2dt9gu9de70jf8hagdcvmqt35f2psxv7ajj5jnh4ajlc752rert8f9msffxdl45qyjefw8';
        const assetWithNoNameId = '126b8676446c84a5cd6e3259223b16a2314c5676b88ae1c1f8579a8f';
        const addresses = [addressAssociatedWithUTxOWithNoAssetName];
        const res = await provider.utxoByAddresses({ addresses: toCardanoAddresses(addresses) });
        const txOut: Cardano.TxOut = res[0][1];

        expect(txOut.value.assets!.get(Cardano.AssetId(assetWithNoNameId))).toBeDefined();
        expect(txOut.value.assets!.size).toEqual(2);
      });
    });
  });
});
