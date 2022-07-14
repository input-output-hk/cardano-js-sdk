/* eslint-disable max-len */
import { Cardano, ProviderError, ProviderFailure, UtxoProvider } from '@cardano-sdk/core';
import { DbSyncUtxoProvider, HttpServer, HttpServerConfig, UtxoHttpService } from '../../src';
import { Pool } from 'pg';
import { getRandomPort } from 'get-port-please';
import { utxoHttpProvider } from '@cardano-sdk/cardano-services-client';
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
  let apiUrlBase: string;
  let config: HttpServerConfig;
  let provider: UtxoProvider;

  beforeAll(async () => {
    port = await getRandomPort();
    apiUrlBase = `http://localhost:${port}/utxo`;
    config = { listen: { port } };
    dbConnection = new Pool({ connectionString: process.env.DB_CONNECTION_STRING });
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
      expect(() => new UtxoHttpService({ utxoProvider })).not.toThrow(new ProviderError(ProviderFailure.Unhealthy));
    });

    it('throws during service initialization if the UtxoProvider is unhealthy', async () => {
      service = new UtxoHttpService({ utxoProvider });
      httpServer = new HttpServer(config, { services: [service] });
      await expect(httpServer.initialize()).rejects.toThrow(new ProviderError(ProviderFailure.Unhealthy));
    });
  });

  describe('healthy state', () => {
    beforeAll(async () => {
      utxoProvider = new DbSyncUtxoProvider(dbConnection);
      service = new UtxoHttpService({ utxoProvider });
      httpServer = new HttpServer(config, { services: [service] });
      provider = utxoHttpProvider(apiUrlBase);
      await httpServer.initialize();
      await httpServer.start();
    });

    afterAll(async () => {
      await dbConnection.end();
      await httpServer.shutdown();
    });

    describe('/health', () => {
      it('/health response should be true', async () => {
        const res = await axios.post(`${apiUrlBase}/health`, undefined, {
          headers: { 'Content-Type': APPLICATION_JSON }
        });
        expect(res.status).toBe(200);
        expect(res.data).toEqual({ ok: true });
      });
      it('with utxoProvider', async () => {
        const response = await provider.healthCheck();
        expect(response).toEqual({ ok: true });
      });
    });
    describe('/utxo-by-addresses', () => {
      it('returns a 415 coded response if the wrong content type header is used', async () => {
        try {
          await axios.post(
            `${apiUrlBase}/utxo-by-addresses`,
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
          await axios.post(`${apiUrlBase}/utxo-by-addresses`, { args: [{ addresses: ['asd'] }] });
          // eslint-disable-next-line @typescript-eslint/no-explicit-any
        } catch (error: any) {
          expect(error.response.status).toBe(400);
          expect(error.message).toBe(BAD_REQUEST_STRING);
        }
      });
      it('valid request should pass OpenApi schema validations', async () => {
        const req = ['asd'];
        const res = await axios.post(`${apiUrlBase}/utxo-by-addresses`, { args: [req] });
        expect(res.status).toEqual(200);
      });
      it('return UTxOs for a single address', async () => {
        const res = await utxoProvider.utxoByAddresses([
          Cardano.Address(
            'addr_test1qretqkqqvc4dax3482tpjdazrfl8exey274m3mzch3dv8lu476aeq3kd8q8splpsswcfmv4y370e8r76rc8lnnhte49qqyjmtc'
          )
        ]);
        expect(res).toMatchSnapshot();
      });
      it('return UTxOs for multiple addresses', async () => {
        const addresses = [
          'addr_test1qpcnmvyjmxmsm75f747u566gw7ewz4mesdw7yl278uf9r3f5l7d7dpx2ymfwlm3e56flupga8yamjr2kwdt7dw77ktyqqtx2r7',
          'addr_test1qr4m502gr9hnaxac5mxjln22jwavf7pcjmh9sw7fujdvgvj9ef6afquphwg7tj4mmm548m3t50hxfyygjuu222kx96eshcathg',
          'addr_test1qz2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzer3jcu5d8ps7zex2k2xt3uqxgjqnnj83ws8lhrn648jjxtwq2ytjqp'
        ];
        const res = await utxoProvider.utxoByAddresses(toCardanoAddresses(addresses));
        expect(res).toMatchSnapshot();
      });
      it('returns UTxOs containing multiple assets', async () => {
        const addresses = [
          'addr_test1qrcj98ukemwfuwc72ad95yydnx83qch6s7plr8rg44nxv53fumt3ljeck26752eajzyavd8my3cp8cx3x2c538lx7h5swm4j4n',
          'addr_test1qretqkqqvc4dax3482tpjdazrfl8exey274m3mzch3dv8lu476aeq3kd8q8splpsswcfmv4y370e8r76rc8lnnhte49qqyjmtc'
        ];
        const res = await utxoProvider.utxoByAddresses(toCardanoAddresses(addresses));
        expect(res).toMatchSnapshot();
      });
    });
  });
});
