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
import { AssetProvider } from '@cardano-sdk/core';
import { Pool } from 'pg';
import { createDbSyncMetadataService } from '../../src/Metadata';
import { fromSerializableObject } from '@cardano-sdk/util';
import { getPort } from 'get-port-please';
import { dummyLogger as logger } from 'ts-log';
import { mockTokenRegistry } from './CardanoTokenRegistry.test';
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
  let tokenMetadataServerUrl = '';
  let tokenMetadataService: TokenMetadataService;

  beforeAll(async () => {
    port = await getPort();
    apiUrlBase = `http://localhost:${port}/asset`;
    config = { listen: { port } };
  });

  describe('healthy state', () => {
    beforeAll(async () => {
      ({ closeMock, tokenMetadataServerUrl } = await mockTokenRegistry(() => ({})));
      db = new Pool({ connectionString: process.env.POSTGRES_CONNECTION_STRING });
      ntfMetadataService = new DbSyncNftMetadataService({
        db,
        logger,
        metadataService: createDbSyncMetadataService(db, logger)
      });
      tokenMetadataService = new CardanoTokenRegistry({ logger }, { tokenMetadataServerUrl });
      assetProvider = new DbSyncAssetProvider({ db, logger, ntfMetadataService, tokenMetadataService });
      service = new AssetHttpService({ assetProvider, logger });
      httpServer = new HttpServer(config, { services: [service] });
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
      it('/health response should be true', async () => {
        const res = await axios.post(`${apiUrlBase}/health`, undefined, {
          headers: { 'Content-Type': APPLICATION_JSON }
        });
        expect(res.status).toBe(200);
        expect(res.data).toEqual({ ok: true });
      });
    });

    describe('/get-asset', () => {
      it('returns a 415 coded response if the wrong content type header is used', async () => {
        try {
          await axios.post(`${apiUrlBase}/get-asset`, { args: [] }, { headers: { 'Content-Type': APPLICATION_CBOR } });
          // eslint-disable-next-line @typescript-eslint/no-explicit-any
        } catch (error: any) {
          expect(error.response.status).toBe(415);
          expect(error.message).toBe(UNSUPPORTED_MEDIA_STRING);
        }
      });

      it('returns 400 coded response if the request is bad formed', async () => {
        try {
          await axios.post(`${apiUrlBase}/get-asset`, { args: [['test']] });
          // eslint-disable-next-line @typescript-eslint/no-explicit-any
        } catch (error: any) {
          expect(error.response.status).toBe(400);
          expect(error.message).toBe(BAD_REQUEST_STRING);
        }
      });

      it('returns 404 coded response for not existing existing asset id', async () => {
        try {
          const res = await axios.post(`${apiUrlBase}/get-asset`, {
            args: ['0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef']
          });
          expect(res.data[0]).toEqual({});
          // eslint-disable-next-line @typescript-eslint/no-explicit-any
        } catch (error: any) {
          expect(error.response.status).toBe(404);
        }
      });

      it('returns asset info for existing asset id', async () => {
        const res = await axios.post(`${apiUrlBase}/get-asset`, {
          args: ['50fdcdbfa3154db86a87e4b5697ae30d272e0bbcfa8122efd3e301cb6d616361726f6e2d63616b65']
        });
        expect(fromSerializableObject(res.data)).toEqual({
          assetId: '50fdcdbfa3154db86a87e4b5697ae30d272e0bbcfa8122efd3e301cb6d616361726f6e2d63616b65',
          fingerprint: 'asset1f0azzptnr8dghzjh7egqvdjmt33e3lz5uy59th',
          mintOrBurnCount: 1,
          name: '6d616361726f6e2d63616b65',
          policyId: '50fdcdbfa3154db86a87e4b5697ae30d272e0bbcfa8122efd3e301cb',
          quantity: 1n
        });
      });

      it('returns asset info with extra data when requested', async () => {
        const res = await axios.post(`${apiUrlBase}/get-asset`, {
          args: [
            '50fdcdbfa3154db86a87e4b5697ae30d272e0bbcfa8122efd3e301cb6d616361726f6e2d63616b65',
            { history: true, nftMetadata: true, tokenMetadata: true }
          ]
        });
        const { history, nftMetadata, tokenMetadata } = fromSerializableObject(res.data);
        expect(history).toEqual([
          {
            quantity: 1n,
            transactionId: 'f66791a0354c43d8c5a93671eb96d94633e3419f3ccbb0a00c00a152d3b6ca06'
          }
        ]);
        expect(nftMetadata).toEqual({
          description: ['This is my first NFT of the macaron cake'],
          files: undefined,
          image: ['ipfs://QmcDAmZubQig7tGUgEwbWcgdvz4Aoa2EiRZyFoX3fXTVmr'],
          mediaType: undefined,
          name: 'macaron cake token',
          otherProperties: new Map([['id', 1n]]),
          version: '1.0'
        });
        expect(tokenMetadata).toEqual({
          desc: 'This is my first NFT of the macaron cake',
          name: 'macaron cake token'
        });
      });
    });
  });
});
