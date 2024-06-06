import { AddressWith, UtxoFixtureBuilder } from './fixtures/FixtureBuilder.js';
import { Cardano } from '@cardano-sdk/core';
import { DataMocks } from '../data-mocks/index.js';
import {
  DbSyncUtxoProvider,
  HttpServer,
  InMemoryCache,
  UNLIMITED_CACHE_TTL,
  UtxoHttpService
} from '../../src/index.js';
import { INFO, createLogger } from 'bunyan';
import { Pool } from 'pg';
import { clearDbPools, servicesWithVersionPath as services } from '../util.js';
import { findLedgerTip } from '../../src/util/DbSyncProvider/index.js';
import { getPort } from 'get-port-please';
import { healthCheckResponseMock, mockCardanoNode } from '../../../core/test/CardanoNode/mocks.js';
import { logger } from '@cardano-sdk/util-dev';
import { utxoHttpProvider } from '@cardano-sdk/cardano-services-client';
import axios from 'axios';
import type { CreateHttpProviderConfig } from '@cardano-sdk/cardano-services-client';
import type { DbPools, LedgerTipModel } from '../../src/util/DbSyncProvider/index.js';
import type { HttpServerConfig } from '../../src/index.js';
import type { OgmiosCardanoNode } from '@cardano-sdk/ogmios';
import type { UtxoProvider } from '@cardano-sdk/core';

const APPLICATION_JSON = 'application/json';
const APPLICATION_CBOR = 'application/cbor';
const UNSUPPORTED_MEDIA_STRING = 'Request failed with status code 415';
const BAD_REQUEST_STRING = 'Request failed with status code 400';

describe('UtxoHttpService', () => {
  let dbPools: DbPools;
  let httpServer: HttpServer;
  let utxoProvider: DbSyncUtxoProvider;
  let service: UtxoHttpService;
  let port: number;
  let baseUrl: string;
  let baseUrlWithVersion: string;
  let clientConfig: CreateHttpProviderConfig<UtxoProvider>;
  let config: HttpServerConfig;
  let cardanoNode: OgmiosCardanoNode;
  let provider: UtxoProvider;
  let lastBlockNoInDb: LedgerTipModel;
  let fixtureBuilder: UtxoFixtureBuilder;
  const cache = { db: new InMemoryCache(UNLIMITED_CACHE_TTL), healthCheck: new InMemoryCache(UNLIMITED_CACHE_TTL) };

  beforeAll(async () => {
    port = await getPort();
    baseUrl = `http://localhost:${port}`;
    baseUrlWithVersion = `${baseUrl}${services.utxo.versionPath}/${services.utxo.name}`;
    clientConfig = { baseUrl, logger: createLogger({ level: INFO, name: 'unit tests' }) };
    config = { listen: { port } };
    dbPools = {
      healthCheck: new Pool({
        connectionString: process.env.POSTGRES_CONNECTION_STRING_DB_SYNC
      }),
      main: new Pool({
        connectionString: process.env.POSTGRES_CONNECTION_STRING_DB_SYNC
      })
    };
    fixtureBuilder = new UtxoFixtureBuilder(dbPools.main, logger);
  });

  // eslint-disable-next-line sonarjs/cognitive-complexity
  describe('healthy state', () => {
    beforeAll(async () => {
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
      utxoProvider = new DbSyncUtxoProvider({ cache, cardanoNode, dbPools, logger });
      service = new UtxoHttpService({ logger, utxoProvider });
      provider = utxoHttpProvider(clientConfig);
      httpServer = new HttpServer(config, { logger, runnableDependencies: [cardanoNode], services: [service] });
      await httpServer.initialize();
      await httpServer.start();
    });
    afterAll(async () => {
      await clearDbPools(dbPools);
      await httpServer.shutdown();
    });

    describe('/health', () => {
      it('forwards the utxoProvider health response with HTTP request', async () => {
        const res = await axios.post(`${baseUrlWithVersion}/health`, undefined, {
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

      it('forwards the utxoProvider health response with provider client', async () => {
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

    describe('/utxo-by-addresses', () => {
      it('returns a 415 coded response if the wrong content type header is used', async () => {
        try {
          await axios.post(
            `${baseUrlWithVersion}/utxo-by-addresses`,
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
          await axios.post(`${baseUrlWithVersion}/utxo-by-addresses`, { addresses: ['asd'] });
          // eslint-disable-next-line @typescript-eslint/no-explicit-any
        } catch (error: any) {
          expect(error.response.status).toBe(400);
          expect(error.message).toBe(BAD_REQUEST_STRING);
        }
      });

      it('valid request should pass OpenApi schema validations', async () => {
        const addresses = ['asd'];
        const res = await axios.post(`${baseUrlWithVersion}/utxo-by-addresses`, { addresses });
        expect(res.status).toEqual(200);
      });

      it('return UTxOs for a single address', async () => {
        const addresses = await fixtureBuilder.getAddresses(1);
        const res = await provider.utxoByAddresses({ addresses });

        expect(res.length).toBeGreaterThan(0);
        expect(res[0]).toMatchShapeOf([DataMocks.Tx.input, DataMocks.Tx.output]);
        expect(() => Cardano.PaymentAddress(addresses[0] as unknown as string)).not.toThrow();
      });

      it('return UTxO with inline datum', async () => {
        const addresses = await fixtureBuilder.getAddresses(1, { with: [AddressWith.InlineDatum] });
        const res: Cardano.Utxo[] = await provider.utxoByAddresses({ addresses });

        expect(res.length).toBeGreaterThan(0);
        expect(res[0]).toMatchShapeOf([DataMocks.Tx.input, DataMocks.Tx.outputWithInlineDatum]);
        expect(res[0][1].datumHash).toBeUndefined();
      });

      it('return UTxO with time lock reference script', async () => {
        const addresses = await fixtureBuilder.getAddresses(1, {
          scriptType: 'timelock',
          with: [AddressWith.ReferenceScript]
        });
        const res = await provider.utxoByAddresses({ addresses });
        const scriptRefUtxo = res.find((utxo) => utxo[1].scriptReference!.__type === Cardano.ScriptType.Native);
        expect(res.length).toBeGreaterThan(0);
        expect(scriptRefUtxo).toBeDefined();
        expect(res[0]).toMatchShapeOf([DataMocks.Tx.input, DataMocks.Tx.outputWithInlineDatum]);
      });

      it('return UTxO with plutus v1 reference script', async () => {
        const addresses = await fixtureBuilder.getAddresses(1, {
          scriptType: 'plutusV1',
          with: [AddressWith.ReferenceScript]
        });
        const res = await provider.utxoByAddresses({ addresses });
        const scriptRefUtxo = res.find(
          (utxo) =>
            utxo[1].scriptReference!.__type === Cardano.ScriptType.Plutus &&
            utxo[1].scriptReference!.version === Cardano.PlutusLanguageVersion.V1
        );
        expect(res.length).toBeGreaterThan(0);
        expect(scriptRefUtxo).toBeDefined();
        expect(res[0]).toMatchShapeOf([DataMocks.Tx.input, DataMocks.Tx.outputWithInlineDatum]);
      });

      it('return UTxO with plutus v2 reference script', async () => {
        const addresses = await fixtureBuilder.getAddresses(1, {
          scriptType: 'plutusV2',
          with: [AddressWith.ReferenceScript]
        });
        const res = await provider.utxoByAddresses({ addresses });
        const scriptRefUtxo = res.find(
          (utxo) =>
            utxo[1].scriptReference!.__type === Cardano.ScriptType.Plutus &&
            utxo[1].scriptReference!.version === Cardano.PlutusLanguageVersion.V2
        );
        expect(res.length).toBeGreaterThan(0);
        expect(scriptRefUtxo).toBeDefined();
        expect(res[0]).toMatchShapeOf([DataMocks.Tx.input, DataMocks.Tx.outputWithInlineDatum]);
      });

      it('return UTxOs for multiple addresses', async () => {
        const addresses = await fixtureBuilder.getAddresses(3);
        const res = await provider.utxoByAddresses({ addresses });
        expect(res.length).toBeGreaterThan(0);
        expect(res[0]).toMatchShapeOf([DataMocks.Tx.input, DataMocks.Tx.output]);
      });

      it('returns UTxOs containing multiple assets', async () => {
        const addresses = await fixtureBuilder.getAddresses(2, { with: [AddressWith.MultiAsset] });
        const res = await provider.utxoByAddresses({ addresses });
        expect(res.length).toBeGreaterThan(0);
        expect(res[0]).toMatchShapeOf([DataMocks.Tx.input, DataMocks.Tx.output]);
      });

      it('returns UTxOs containing multiple assets and one of the assets has no name', async () => {
        const addresses = await fixtureBuilder.getAddresses(2, {
          with: [AddressWith.MultiAsset, AddressWith.AssetWithoutName]
        });
        const res = await provider.utxoByAddresses({ addresses });
        let txOutWithAssetThatHasNoName: Cardano.TxOut;

        for (const [_, output] of res) {
          const assets = output.value.assets;
          if (!assets) continue;

          for (const id of assets.keys()) {
            if (Cardano.AssetId.getAssetName(Cardano.AssetId(id)) === '') {
              txOutWithAssetThatHasNoName = output;
            }
          }
        }

        expect(txOutWithAssetThatHasNoName!).toBeDefined();
        expect(txOutWithAssetThatHasNoName!.value.assets!.size).toBeGreaterThan(0);
      });
    });
  });
});
