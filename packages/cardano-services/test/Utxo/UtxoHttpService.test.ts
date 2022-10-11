/* eslint-disable max-len */
import { Cardano, ProviderError, ProviderFailure } from '@cardano-sdk/core';
import { DbSyncUtxoProvider, HttpServer, HttpServerConfig, UtxoHttpService } from '../../src';
import { OgmiosCardanoNode } from '@cardano-sdk/ogmios';
import { Pool } from 'pg';
import { getPort } from 'get-port-please';
import { dummyLogger as logger } from 'ts-log';
import { mockCardanoNode } from '../../../core/test/CardanoNode/mocks';
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
  let config: HttpServerConfig;
  let cardanoNode: OgmiosCardanoNode;

  beforeAll(async () => {
    port = await getPort();
    baseUrl = `http://localhost:${port}/utxo`;
    config = { listen: { port } };
    dbConnection = new Pool({ connectionString: process.env.POSTGRES_CONNECTION_STRING });
  });

  afterEach(async () => {
    jest.resetAllMocks();
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
      cardanoNode = mockCardanoNode() as unknown as OgmiosCardanoNode;
      utxoProvider = new DbSyncUtxoProvider({ cardanoNode, db: dbConnection, logger });
      service = new UtxoHttpService({ logger, utxoProvider });
      httpServer = new HttpServer(config, { logger, runnableDependencies: [cardanoNode], services: [service] });
      await httpServer.initialize();
      await httpServer.start();
    });

    afterAll(async () => {
      await dbConnection.end();
      await httpServer.shutdown();
    });

    describe('/health', () => {
      it('/health response should be true', async () => {
        const res = await axios.post(`${baseUrl}/health`, undefined, {
          headers: { 'Content-Type': APPLICATION_JSON }
        });
        expect(res.status).toBe(200);
        expect(res.data).toEqual({
          localNode: {
            ledgerTip: {
              blockNo: 3_391_731,
              hash: '9ef43ab6e234fcf90d103413096c7da752da2f45b15e1259f43d476afd12932c',
              slot: 52_819_355
            },
            networkSync: 0.999
          },
          ok: true
        });
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
        const res = await utxoProvider.utxoByAddresses({
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
        const res = await utxoProvider.utxoByAddresses({ addresses: toCardanoAddresses(addresses) });
        expect(res).toMatchSnapshot();
      });
      it('returns UTxOs containing multiple assets', async () => {
        const addresses = [
          'addr_test1qp620qa3rqzd5fxj3hy4dughv7xx2dt9gu9de70jf8hagdcvmqt35f2psxv7ajj5jnh4ajlc752rert8f9msffxdl45qyjefw8',
          'addr_test1qryz24mkq35j8s67fdrm44pe8na7n3tqkmyzy3sgnjq3d7szlx56h6fkjl8y3p73zpyce04eku9w943rcr6rgznp8cwq2axy9q'
        ];
        const res = await utxoProvider.utxoByAddresses({ addresses: toCardanoAddresses(addresses) });
        expect(res).toMatchSnapshot();
      });
    });
  });
});
