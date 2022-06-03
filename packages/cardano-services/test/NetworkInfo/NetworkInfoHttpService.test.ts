/* eslint-disable @typescript-eslint/no-explicit-any */
import { Cardano, NetworkInfo, NetworkInfoProvider, testnetTimeSettings } from '@cardano-sdk/core';
import { DbSyncNetworkInfoProvider, NetworkInfoHttpService } from '../../src/NetworkInfo';
import { HttpServer, HttpServerConfig } from '../../src';
import { Pool } from 'pg';
import { getPort } from 'get-port-please';
import { networkInfoHttpProvider } from '@cardano-sdk/cardano-services-client';
import axios from 'axios';

const UNSUPPORTED_MEDIA_STRING = 'Request failed with status code 415';
const APPLICATION_CBOR = 'application/cbor';
const APPLICATION_JSON = 'application/json';

describe('NetworkInfoHttpService', () => {
  let dbConnection: Pool;
  let httpServer: HttpServer;
  let networkInfoProvider: DbSyncNetworkInfoProvider;
  let service: NetworkInfoHttpService;
  let port: number;
  let apiUrlBase: string;
  let config: HttpServerConfig;
  let cardanoNodeConfigPath: string;

  beforeAll(async () => {
    port = await getPort();
    config = { listen: { port } };
    apiUrlBase = `http://localhost:${port}/network-info`;
    cardanoNodeConfigPath = process.env.CARDANO_NODE_CONFIG_PATH!;
    dbConnection = new Pool({ connectionString: process.env.DB_CONNECTION_STRING });
  });

  afterEach(async () => {
    jest.resetAllMocks();
  });

  describe('healthy state', () => {
    beforeAll(async () => {
      networkInfoProvider = new DbSyncNetworkInfoProvider(cardanoNodeConfigPath, dbConnection);
      service = NetworkInfoHttpService.create({ networkInfoProvider });
      httpServer = new HttpServer(config, { services: [service] });
      await httpServer.initialize();
      await httpServer.start();
    });

    afterAll(async () => {
      await dbConnection.end();
      await httpServer.shutdown();
    });

    describe('/health', () => {
      it('forwards the networkInfoProvider health response', async () => {
        const res = await axios.post(`${apiUrlBase}/health`, {
          headers: { 'Content-Type': APPLICATION_JSON }
        });
        expect(res.status).toBe(200);
        expect(res.data).toEqual({ ok: true });
      });
    });

    describe('/network', () => {
      it('returns a 200 coded response with a well formed HTTP request', async () => {
        expect((await axios.post(`${apiUrlBase}/network`, { args: [] })).status).toEqual(200);
      });

      it('returns a 415 coded response if the wrong content type header is used', async () => {
        try {
          await axios.post(`${apiUrlBase}/network`, { args: [] }, { headers: { 'Content-Type': APPLICATION_CBOR } });
        } catch (error: any) {
          expect(error.response.status).toBe(415);
          expect(error.message).toBe(UNSUPPORTED_MEDIA_STRING);
        }
      });

      describe('with NetworkInfoHttpProvider', () => {
        let provider: NetworkInfoProvider;
        beforeEach(() => {
          provider = networkInfoHttpProvider(apiUrlBase);
        });

        it('time settings response is an array of network info response', async () => {
          const testnetNetworkInfo: NetworkInfo['network'] = {
            id: Cardano.NetworkId.testnet,
            magic: Cardano.CardanoNetworkMagic.Testnet,
            timeSettings: testnetTimeSettings
          };

          const response = await provider.networkInfo();
          expect(response.network).toEqual(testnetNetworkInfo);
        });

        it('response is an object of network info', async () => {
          const response = await provider.networkInfo();
          expect(response).toMatchSnapshot();
        });
      });
    });
  });
});
