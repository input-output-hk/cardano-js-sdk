import { AssetFixtureBuilder, AssetWith } from './fixtures/FixtureBuilder';
import {
  AssetHttpService,
  CardanoTokenRegistry,
  DbSyncAssetProvider,
  DbSyncNftMetadataService,
  HttpServer,
  HttpServerConfig,
  NftMetadataService,
  TokenMetadataService
} from '../../src';
import { AssetProvider, Cardano } from '@cardano-sdk/core';
import { BlockNoModel, findLastBlockNo } from '../../src/util/DbSyncProvider';
import { CreateHttpProviderConfig, assetInfoHttpProvider } from '@cardano-sdk/cardano-services-client';
import { INFO, createLogger } from 'bunyan';
import { OgmiosCardanoNode } from '@cardano-sdk/ogmios';
import { Pool } from 'pg';
import { createDbSyncMetadataService } from '../../src/Metadata';
import { getPort } from 'get-port-please';
import { healthCheckResponseMock, mockCardanoNode } from '../../../core/test/CardanoNode/mocks';
import { logger } from '@cardano-sdk/util-dev';
import { mockTokenRegistry } from './fixtures/mocks';
import axios from 'axios';

const APPLICATION_JSON = 'application/json';
const APPLICATION_CBOR = 'application/cbor';
const UNSUPPORTED_MEDIA_STRING = 'Request failed with status code 415';
const BAD_REQUEST_STRING = 'Request failed with status code 400';
describe('AssetHttpService', () => {
  let apiUrlBase: string;
  let assetProvider: AssetProvider;
  let closeMock: () => Promise<void> = jest.fn();
  let config: HttpServerConfig;
  let db: Pool;
  let httpServer: HttpServer;
  let ntfMetadataService: NftMetadataService;
  let service: AssetHttpService;
  let port: number;
  let serverUrl = '';
  let tokenMetadataService: TokenMetadataService;
  let clientConfig: CreateHttpProviderConfig<AssetProvider>;
  let provider: AssetProvider;
  let cardanoNode: OgmiosCardanoNode;
  let lastBlockNoInDb: Cardano.BlockNo;
  let fixtureBuilder: AssetFixtureBuilder;

  beforeAll(async () => {
    port = await getPort();
    apiUrlBase = `http://localhost:${port}/asset`;
    config = { listen: { port } };
    clientConfig = { baseUrl: apiUrlBase, logger: createLogger({ level: INFO, name: 'unit tests' }) };
  });

  describe('healthy state', () => {
    beforeAll(async () => {
      ({ closeMock, serverUrl } = await mockTokenRegistry(() => ({})));
      db = new Pool({ connectionString: process.env.POSTGRES_CONNECTION_STRING });
      ntfMetadataService = new DbSyncNftMetadataService({
        db,
        logger,
        metadataService: createDbSyncMetadataService(db, logger)
      });
      lastBlockNoInDb = Cardano.BlockNo((await db.query<BlockNoModel>(findLastBlockNo)).rows[0].block_no);
      cardanoNode = mockCardanoNode(
        healthCheckResponseMock({ blockNo: lastBlockNoInDb.valueOf() })
      ) as unknown as OgmiosCardanoNode;
      tokenMetadataService = new CardanoTokenRegistry({ logger }, { tokenMetadataServerUrl: serverUrl });
      assetProvider = new DbSyncAssetProvider({ cardanoNode, db, logger, ntfMetadataService, tokenMetadataService });
      service = new AssetHttpService({ assetProvider, logger });
      httpServer = new HttpServer(config, { logger, runnableDependencies: [cardanoNode], services: [service] });
      provider = assetInfoHttpProvider(clientConfig);
      fixtureBuilder = new AssetFixtureBuilder(db, logger);
      await httpServer.initialize();
      await httpServer.start();
    });
    afterAll(async () => {
      await httpServer.shutdown();
      tokenMetadataService.shutdown();
      await db.end();
      await closeMock();
    });

    describe('/health', () => {
      it('forwards the assetProvider health response with HTTP request', async () => {
        const res = await axios.post(`${apiUrlBase}/health`, undefined, {
          headers: { 'Content-Type': APPLICATION_JSON }
        });
        expect(res.status).toBe(200);
        expect(res.data).toEqual(healthCheckResponseMock({ blockNo: lastBlockNoInDb.valueOf() }));
      });

      it('forwards the assetProvider health response with provider client', async () => {
        const response = await provider.healthCheck();
        expect(response).toEqual(healthCheckResponseMock({ blockNo: lastBlockNoInDb.valueOf() }));
      });
    });

    describe('/get-asset', () => {
      it('returns a 415 coded response if the wrong content type header is used', async () => {
        expect.assertions(2);
        try {
          await axios.post(
            `${apiUrlBase}/get-asset`,
            { assetId: '' },
            { headers: { 'Content-Type': APPLICATION_CBOR } }
          );
          // eslint-disable-next-line @typescript-eslint/no-explicit-any
        } catch (error: any) {
          expect(error.response.status).toBe(415);
          expect(error.message).toBe(UNSUPPORTED_MEDIA_STRING);
        }
      });

      it('returns 400 coded response if the request is bad formed', async () => {
        expect.assertions(2);
        try {
          await axios.post(`${apiUrlBase}/get-asset`, { assetId: [['test']] });
          // eslint-disable-next-line @typescript-eslint/no-explicit-any
        } catch (error: any) {
          expect(error.response.status).toBe(400);
          expect(error.message).toBe(BAD_REQUEST_STRING);
        }
      });

      it('returns 404 coded response for not existing existing asset id', async () => {
        expect.assertions(1);
        try {
          await axios.post(`${apiUrlBase}/get-asset`, {
            assetId: '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef'
          });
          // eslint-disable-next-line @typescript-eslint/no-explicit-any
        } catch (error: any) {
          expect(error.response.status).toBe(404);
        }
      });
      it('returns asset info for existing asset id', async () => {
        const assets = await fixtureBuilder.getAssets(1);
        const res = await provider.getAsset({
          assetId: assets[0].id
        });
        expect(res.name).toEqual(assets[0].name);
      });

      it('returns asset info with extra data when requested', async () => {
        const assets = await fixtureBuilder.getAssets(1, { with: [AssetWith.CIP25Metadata] });
        const res = await provider.getAsset({
          assetId: assets[0].id,
          extraData: { history: true, nftMetadata: true, tokenMetadata: true }
        });
        const expectedHistory = await fixtureBuilder.getHistory(assets[0].policyId, assets[0].name);
        const { history, nftMetadata, tokenMetadata } = res;

        expect(history).toEqual(expectedHistory);
        expect(nftMetadata).toEqual(assets[0].metadata);
        expect(tokenMetadata).toBeDefined();
      });
    });
  });
});
