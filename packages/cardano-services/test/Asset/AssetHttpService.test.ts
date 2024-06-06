/* eslint-disable sonarjs/cognitive-complexity */
/* eslint-disable sonarjs/no-identical-functions */
import { AssetFixtureBuilder, AssetWith } from './fixtures/FixtureBuilder.js';
import {
  AssetHttpService,
  CardanoTokenRegistry,
  DbSyncAssetProvider,
  DbSyncNftMetadataService,
  HttpServer,
  InMemoryCache,
  PAGINATION_PAGE_SIZE_LIMIT_ASSETS,
  UNLIMITED_CACHE_TTL
} from '../../src/index.js';
import { Cardano } from '@cardano-sdk/core';
import { INFO, createLogger } from 'bunyan';
import { Pool } from 'pg';
import { assetInfoHttpProvider } from '@cardano-sdk/cardano-services-client';
import { clearDbPools, servicesWithVersionPath as services } from '../util.js';
import { createDbSyncMetadataService } from '../../src/Metadata/index.js';
import { findLedgerTip } from '../../src/util/DbSyncProvider/index.js';
import { getPort } from 'get-port-please';
import { healthCheckResponseMock, mockCardanoNode } from '../../../core/test/CardanoNode/mocks.js';
import { logger } from '@cardano-sdk/util-dev';
import { mockTokenRegistry } from './fixtures/mocks.js';
import axios from 'axios';
import type { AssetProvider } from '@cardano-sdk/core';
import type { CreateHttpProviderConfig } from '@cardano-sdk/cardano-services-client';
import type { DbPools, LedgerTipModel } from '../../src/util/DbSyncProvider/index.js';
import type { HttpServerConfig, NftMetadataService, TokenMetadataService } from '../../src/index.js';
import type { OgmiosCardanoNode } from '@cardano-sdk/ogmios';

const APPLICATION_JSON = 'application/json';
const APPLICATION_CBOR = 'application/cbor';
const UNSUPPORTED_MEDIA_STRING = 'Request failed with status code 415';
const BAD_REQUEST_STRING = 'Request failed with status code 400';

describe('AssetHttpService', () => {
  let apiUrlBase: string;
  let apiUrlBaseWithVersion: string;
  let assetProvider: AssetProvider;
  let closeMock: () => Promise<void> = jest.fn();
  let config: HttpServerConfig;
  let dbPools: DbPools;
  let httpServer: HttpServer;
  let ntfMetadataService: NftMetadataService;
  let service: AssetHttpService;
  let port: number;
  let serverUrl = '';
  let tokenMetadataService: TokenMetadataService;
  let clientConfig: CreateHttpProviderConfig<AssetProvider>;
  let provider: AssetProvider;
  let cardanoNode: OgmiosCardanoNode;
  let lastBlockNoInDb: LedgerTipModel;
  let fixtureBuilder: AssetFixtureBuilder;

  beforeAll(async () => {
    port = await getPort();
    apiUrlBase = `http://localhost:${port}`;
    apiUrlBaseWithVersion = `${apiUrlBase}${services.asset.versionPath}/${services.asset.name}`;
    config = { listen: { port } };
    clientConfig = {
      baseUrl: apiUrlBase,
      logger: createLogger({ level: INFO, name: 'unit tests' })
    };
  });

  describe('healthy state', () => {
    beforeAll(async () => {
      ({ closeMock, serverUrl } = await mockTokenRegistry(async () => ({})));
      dbPools = {
        healthCheck: new Pool({ connectionString: process.env.POSTGRES_CONNECTION_STRING_DB_SYNC }),
        main: new Pool({ connectionString: process.env.POSTGRES_CONNECTION_STRING_DB_SYNC })
      };
      ntfMetadataService = new DbSyncNftMetadataService({
        db: dbPools.main,
        logger,
        metadataService: createDbSyncMetadataService(dbPools.main, logger)
      });
      lastBlockNoInDb = (await dbPools.main.query<LedgerTipModel>(findLedgerTip)).rows[0];
      cardanoNode = mockCardanoNode(
        healthCheckResponseMock({
          blockNo: lastBlockNoInDb.block_no,
          hash: lastBlockNoInDb.hash.toString('hex'),
          projectedTip: {
            blockNo: lastBlockNoInDb.block_no,
            hash: lastBlockNoInDb.hash.toString('hex'),
            slot: Number(lastBlockNoInDb.slot_no)
          },
          slot: Number(lastBlockNoInDb.slot_no),
          withTip: true
        })
      ) as unknown as OgmiosCardanoNode;
      const cache = { db: new InMemoryCache(UNLIMITED_CACHE_TTL), healthCheck: new InMemoryCache(UNLIMITED_CACHE_TTL) };

      tokenMetadataService = new CardanoTokenRegistry({ logger }, { tokenMetadataServerUrl: serverUrl });
      assetProvider = new DbSyncAssetProvider(
        { paginationPageSizeLimit: PAGINATION_PAGE_SIZE_LIMIT_ASSETS },
        {
          cache,
          cardanoNode,
          dbPools,
          logger,
          ntfMetadataService,
          tokenMetadataService
        }
      );
      service = new AssetHttpService({ assetProvider, logger });
      httpServer = new HttpServer(config, { logger, runnableDependencies: [cardanoNode], services: [service] });
      provider = assetInfoHttpProvider(clientConfig);
      fixtureBuilder = new AssetFixtureBuilder(dbPools.main, logger);
      await httpServer.initialize();
      await httpServer.start();
    });

    afterAll(async () => {
      await httpServer.shutdown();
      tokenMetadataService.shutdown();
      await clearDbPools(dbPools);
      await closeMock();
    });

    describe('/health', () => {
      it('forwards the assetProvider health response with HTTP request', async () => {
        const res = await axios.post(`${apiUrlBaseWithVersion}/health`, undefined, {
          headers: { 'Content-Type': APPLICATION_JSON }
        });
        expect(res.status).toBe(200);
        expect(res.data).toEqual(
          healthCheckResponseMock({
            blockNo: lastBlockNoInDb.block_no,
            hash: lastBlockNoInDb.hash.toString('hex'),
            projectedTip: {
              blockNo: lastBlockNoInDb.block_no,
              hash: lastBlockNoInDb.hash.toString('hex'),
              slot: Number(lastBlockNoInDb.slot_no)
            },
            slot: Number(lastBlockNoInDb.slot_no),
            withTip: true
          })
        );
      });

      it('forwards the assetProvider health response with provider client', async () => {
        const response = await provider.healthCheck();
        expect(response).toEqual(
          healthCheckResponseMock({
            blockNo: lastBlockNoInDb.block_no,
            hash: lastBlockNoInDb.hash.toString('hex'),
            projectedTip: {
              blockNo: lastBlockNoInDb.block_no,
              hash: lastBlockNoInDb.hash.toString('hex'),
              slot: Number(lastBlockNoInDb.slot_no)
            },
            slot: Number(lastBlockNoInDb.slot_no),
            withTip: true
          })
        );
      });
    });

    describe('/get-asset', () => {
      const path = 'get-asset';
      it('returns a 415 coded response if the wrong content type header is used', async () => {
        expect.assertions(2);
        try {
          await axios.post(
            `${apiUrlBaseWithVersion}/${path}`,
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
          await axios.post(`${apiUrlBaseWithVersion}/${path}`, { assetId: [['test']] });
          // eslint-disable-next-line @typescript-eslint/no-explicit-any
        } catch (error: any) {
          expect(error.response.status).toBe(400);
          expect(error.message).toBe(BAD_REQUEST_STRING);
        }
      });

      it('returns 404 coded response for not existing existing asset id', async () => {
        expect.assertions(1);
        try {
          await axios.post(`${apiUrlBaseWithVersion}/${path}`, {
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
        expect(() => Cardano.PolicyId(assets[0].policyId as unknown as string)).not.toThrow();
        expect(() => Cardano.AssetName(assets[0].name as unknown as string)).not.toThrow();
      });

      it('returns asset info with extra data when requested', async () => {
        const assets = await fixtureBuilder.getAssets(1, { with: [AssetWith.CIP25Metadata] });
        const res = await provider.getAsset({
          assetId: assets[0].id,
          extraData: { nftMetadata: true, tokenMetadata: true }
        });
        const { nftMetadata, tokenMetadata } = res;

        expect(nftMetadata).toEqual(assets[0].metadata);
        expect(tokenMetadata).toBeDefined();
      });
    });

    describe('/get-assets', () => {
      const path = 'get-assets';
      it('returns a 415 coded response if the wrong content type header is used', async () => {
        expect.assertions(2);
        try {
          await axios.post(
            `${apiUrlBaseWithVersion}/${path}`,
            { assetIds: ['0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef'] },
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
          await axios.post(`${apiUrlBaseWithVersion}/${path}`, { assetId: [['test']] });
          // eslint-disable-next-line @typescript-eslint/no-explicit-any
        } catch (error: any) {
          expect(error.response.status).toBe(400);
          expect(error.message).toBe(BAD_REQUEST_STRING);
        }
      });

      it('returns 404 coded response for not existing existing asset id', async () => {
        expect.assertions(1);
        try {
          await axios.post(`${apiUrlBaseWithVersion}/${path}`, {
            assetIds: ['0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef']
          });
          // eslint-disable-next-line @typescript-eslint/no-explicit-any
        } catch (error: any) {
          expect(error.response.status).toBe(404);
        }
      });

      it('returns a 400 coded error if provided assetIds are greater than pagination page size limit', async () => {
        const assets = await fixtureBuilder.getAssets(1);
        const assetIds = Array.from({ length: PAGINATION_PAGE_SIZE_LIMIT_ASSETS + 1 }, () => assets[0].id);
        expect.assertions(1);
        try {
          await axios.post(`${apiUrlBaseWithVersion}/${path}`, {
            assetIds
          });
          // eslint-disable-next-line @typescript-eslint/no-explicit-any
        } catch (error: any) {
          expect(error.response.status).toBe(400);
        }
      });

      it('returns asset info for existing asset id', async () => {
        const assets = await fixtureBuilder.getAssets(1);
        const res = await provider.getAssets({
          assetIds: [assets[0].id]
        });

        expect(res[0].name).toEqual(assets[0].name);
        expect(() => Cardano.PolicyId(assets[0].policyId as unknown as string)).not.toThrow();
        expect(() => Cardano.AssetName(assets[0].name as unknown as string)).not.toThrow();
      });

      it('returns asset info with extra data when requested', async () => {
        const assets = await fixtureBuilder.getAssets(1, { with: [AssetWith.CIP25Metadata] });
        const assetsResult = await provider.getAssets({
          assetIds: [assets[0].id],
          extraData: { nftMetadata: true, tokenMetadata: true }
        });
        const { nftMetadata, tokenMetadata } = assetsResult[0];

        expect(nftMetadata).toEqual(assets[0].metadata);
        expect(tokenMetadata).toBeDefined();
      });
    });
  });
});
