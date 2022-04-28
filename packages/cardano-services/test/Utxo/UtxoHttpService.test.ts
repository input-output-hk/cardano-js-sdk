/* eslint-disable max-len */
import { Cardano, UtxoProvider } from '@cardano-sdk/core';
import { DbSyncUtxoProvider, HttpServer, HttpServerConfig, UtxoHttpService } from '../../src';
import { Pool } from 'pg';
import { getPort } from 'get-port-please';
import { utxoHttpProvider } from '@cardano-sdk/cardano-services-client';
import got from 'got';

const APPLICATION_JSON = 'application/json';
const APPLICATION_CBOR = 'application/cbor';
const UNSUPPORTED_MEDIA_STRING = 'Response code 415 (Unsupported Media Type)';
const BAD_REQUEST_STRING = 'Response code 400 (Bad Request)';

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
    port = await getPort();
    apiUrlBase = `http://localhost:${port}/utxo`;
    config = { listen: { port } };
    dbConnection = new Pool({ connectionString: process.env.DB_CONNECTION_STRING });
  });

  afterEach(async () => {
    jest.resetAllMocks();
  });

  describe('healthy state', () => {
    beforeAll(async () => {
      utxoProvider = new DbSyncUtxoProvider(dbConnection);
      service = UtxoHttpService.create({ utxoProvider });
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
        const res = await got(`${apiUrlBase}/health`, {
          headers: { 'Content-Type': APPLICATION_JSON }
        });
        expect(res.statusCode).toBe(200);
        expect(JSON.parse(res.body)).toEqual({ ok: true });
      });
      it('with utxoProvider', async () => {
        const response = await provider.healthCheck();
        expect(response).toEqual({ ok: true });
      });
    });
    describe('/utxo-by-addresses', () => {
      it('returns a 415 coded response if the wrong content type header is used', async () => {
        try {
          await got.post(`${apiUrlBase}/utxo-by-addresses`, {
            headers: { 'Content-Type': APPLICATION_CBOR }
          });
          // eslint-disable-next-line @typescript-eslint/no-explicit-any
        } catch (error: any) {
          expect(error.response.statusCode).toBe(415);
          expect(error.message).toBe(UNSUPPORTED_MEDIA_STRING);
        }
      });
      it('returns 400 coded respons if the request is bad formed', async () => {
        try {
          await got.post(`${apiUrlBase}/utxo-by-addresses`, {
            json: { addresses: ['asd'] }
          });
          // eslint-disable-next-line @typescript-eslint/no-explicit-any
        } catch (error: any) {
          expect(error.response.statusCode).toBe(400);
          expect(error.message).toBe(BAD_REQUEST_STRING);
        }
      });
      it('valid request should pass OpenApi schema validations', async () => {
        const req = ['asd'];
        const res = await got.post(`${apiUrlBase}/utxo-by-addresses`, {
          json: { args: [req] }
        });
        expect(res.statusCode).toEqual(200);
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
