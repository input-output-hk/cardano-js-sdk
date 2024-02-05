/* eslint-disable sonarjs/no-identical-functions */
/* eslint-disable sonarjs/no-duplicate-string */
/* eslint-disable sonarjs/cognitive-complexity */
/* eslint-disable @typescript-eslint/no-explicit-any */
import { Cardano, ChainHistoryProvider } from '@cardano-sdk/core';
import { ChainHistoryFixtureBuilder, TxWith } from './fixtures/FixtureBuilder';
import {
  ChainHistoryHttpService,
  DbSyncChainHistoryProvider,
  HttpServer,
  HttpServerConfig,
  InMemoryCache,
  UNLIMITED_CACHE_TTL
} from '../../src';
import { CreateHttpProviderConfig, chainHistoryHttpProvider } from '@cardano-sdk/cardano-services-client';
import { DB_MAX_SAFE_INTEGER } from '../../src/ChainHistory/DbSyncChainHistory/queries';
import { DataMocks } from '../data-mocks';
import { DbPools, LedgerTipModel, findLedgerTip } from '../../src/util/DbSyncProvider';
import { OgmiosCardanoNode } from '@cardano-sdk/ogmios';
import { Pool } from 'pg';
import { clearDbPools, servicesWithVersionPath as services } from '../util';
import { createDbSyncMetadataService } from '../../src/Metadata';
import { getPort } from 'get-port-please';
import { healthCheckResponseMock, mockCardanoNode } from '../../../core/test/CardanoNode/mocks';
import { logger } from '@cardano-sdk/util-dev';
import axios from 'axios';

require('json-bigint-patch');

const UNSUPPORTED_MEDIA_STRING = 'Request failed with status code 415';
const BAD_REQUEST = 'Request failed with status code 400';
const APPLICATION_CBOR = 'application/cbor';
const APPLICATION_JSON = 'application/json';
const PAGINATION_PAGE_SIZE_LIMIT = 5;

describe('ChainHistoryHttpService', () => {
  let dbPools: DbPools;
  let httpServer: HttpServer;
  let chainHistoryProvider: DbSyncChainHistoryProvider;
  let service: ChainHistoryHttpService;
  let port: number;
  let baseUrl: string;
  let baseUrlWithVersion: string;
  let clientConfig: CreateHttpProviderConfig<ChainHistoryProvider>;
  let config: HttpServerConfig;
  let provider: ChainHistoryProvider;
  let cardanoNode: OgmiosCardanoNode;
  let lastBlockNoInDb: LedgerTipModel;
  let fixtureBuilder: ChainHistoryFixtureBuilder;
  const cache = { db: new InMemoryCache(UNLIMITED_CACHE_TTL), healthCheck: new InMemoryCache(UNLIMITED_CACHE_TTL) };

  beforeAll(async () => {
    port = await getPort();
    baseUrl = `http://localhost:${port}`;
    baseUrlWithVersion = `${baseUrl}${services.chainHistory.versionPath}/${services.chainHistory.name}`;
    clientConfig = { baseUrl, logger };
    config = { listen: { port } };
    dbPools = {
      healthCheck: new Pool({ connectionString: process.env.POSTGRES_CONNECTION_STRING_DB_SYNC }),
      main: new Pool({ connectionString: process.env.POSTGRES_CONNECTION_STRING_DB_SYNC })
    };
    fixtureBuilder = new ChainHistoryFixtureBuilder(dbPools.main, logger);
  });

  describe('healthy state', () => {
    beforeAll(async () => {
      const metadataService = createDbSyncMetadataService(dbPools.main, logger);
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
      chainHistoryProvider = new DbSyncChainHistoryProvider(
        { paginationPageSizeLimit: PAGINATION_PAGE_SIZE_LIMIT },
        { cache, cardanoNode, dbPools, logger, metadataService }
      );
      service = new ChainHistoryHttpService({ chainHistoryProvider, logger });
      provider = chainHistoryHttpProvider(clientConfig);
      httpServer = new HttpServer(config, {
        logger,
        runnableDependencies: [cardanoNode],
        services: [service]
      });
      await httpServer.initialize();
      await httpServer.start();
    });
    afterAll(async () => {
      await clearDbPools(dbPools);
      await httpServer.shutdown();
    });

    describe('/health', () => {
      const url = '/health';
      it('forwards the chainHistoryProvider health response with HTTP request', async () => {
        const res = await axios.post(`${baseUrlWithVersion}${url}`, undefined, {
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

      it('forwards the chainHistoryProvider health response with provider client', async () => {
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

    describe('/blocks/by-hashes', () => {
      const url = '/blocks/by-hashes';
      describe('with Http Service', () => {
        it('returns a 200 coded response with a well formed HTTP request', async () => {
          expect((await axios.post(`${baseUrlWithVersion}${url}`, { ids: [] })).status).toEqual(200);
        });

        it('returns a 415 coded response if the wrong content type header is used', async () => {
          try {
            await axios.post(
              `${baseUrlWithVersion}${url}`,
              { ids: [] },
              { headers: { 'Content-Type': APPLICATION_CBOR } }
            );
            throw new Error('fail');
          } catch (error: any) {
            expect(error.response.status).toBe(415);
            expect(error.message).toBe(UNSUPPORTED_MEDIA_STRING);
          }
        });
      });

      it('returns an array of blocks', async () => {
        const blockIds = await fixtureBuilder.getBlockHashes(2);
        const response = await provider.blocksByHashes({ ids: blockIds });

        expect(() => Cardano.BlockId(blockIds[0] as unknown as string)).not.toThrow();
        expect(() => Cardano.VrfVkBech32(response[0].vrf as unknown as string)).not.toThrow();

        expect(response).toHaveLength(2);
      });

      it('does not include blocks not found', async () => {
        const ids: Cardano.BlockId[] = [
          (await fixtureBuilder.getBlockHashes(1))[0],
          Cardano.BlockId('0000000000000000000000000000000000000000000000000000000000000000')
        ];
        const response = await provider.blocksByHashes({ ids });
        expect(response).toHaveLength(1);
      });

      it('returns a 400 coded error if provided block ids are greater than pagination page size limit', async () => {
        try {
          await axios.post(
            `${baseUrlWithVersion}${url}`,
            {
              ids: await fixtureBuilder.getBlockHashes(6)
            },
            { headers: { 'Content-Type': APPLICATION_JSON } }
          );
        } catch (error: any) {
          expect(error.response.status).toBe(400);
          expect(error.message).toBe(BAD_REQUEST);
        }
      });

      describe('server and snapshot testing', () => {
        it('has all block information', async () => {
          const response = await provider.blocksByHashes({ ids: await fixtureBuilder.getBlockHashes(2) });
          expect(response.length).toEqual(2);
          expect(response[0]).toMatchShapeOf(DataMocks.Block.block);
          expect(response[1]).toMatchShapeOf(DataMocks.Block.tipBlock);
        });
      });
    });

    describe('/txs/by-hashes', () => {
      const url = '/txs/by-hashes';
      describe('with Http Service', () => {
        it('returns a 200 coded response with a well formed HTTP request', async () => {
          expect((await axios.post(`${baseUrlWithVersion}${url}`, { ids: [] })).status).toEqual(200);
        });

        it('returns a 415 coded response if the wrong content type header is used', async () => {
          try {
            await axios.post(
              `${baseUrlWithVersion}${url}`,
              { ids: [] },
              { headers: { 'Content-Type': APPLICATION_CBOR } }
            );
            throw new Error('fail');
          } catch (error: any) {
            expect(error.response.status).toBe(415);
            expect(error.message).toBe(UNSUPPORTED_MEDIA_STRING);
          }
        });
      });

      it('returns an array of transactions', async () => {
        const ids = await fixtureBuilder.getTxHashes(5);
        const response = await provider.transactionsByHashes({ ids });

        expect(response).toHaveLength(5);
        expect(() => Cardano.TransactionId(ids[0] as unknown as string)).not.toThrow();
      });

      it('does not include transactions not found', async () => {
        const ids: Cardano.TransactionId[] = [
          (await fixtureBuilder.getTxHashes(1))[0],
          Cardano.TransactionId('0000000000000000000000000000000000000000000000000000000000000000')
        ];
        const response = await provider.transactionsByHashes({ ids });
        expect(response.length).toEqual(1);
      });

      it('returns a 400 coded error if provided transaction ids are greater than pagination page size limit', async () => {
        try {
          await axios.post(
            `${baseUrlWithVersion}${url}`,
            {
              ids: await fixtureBuilder.getTxHashes(6)
            },
            { headers: { 'Content-Type': APPLICATION_JSON } }
          );
        } catch (error: any) {
          expect(error.response.status).toBe(400);
          expect(error.message).toBe(BAD_REQUEST);
        }
      });

      describe('server and snapshot testing', () => {
        it('has outputs with multi-assets', async () => {
          const ids = await fixtureBuilder.getTxHashes(1, { with: [TxWith.MultiAsset] });
          const response = await provider.transactionsByHashes({ ids });
          const tx: Cardano.HydratedTx = response[0];

          // A transaction involving multi assets could also have outputs without multi assets, so we must first
          // find the index of the output inside the transaction with the native tokens.
          const maOutputIndex = tx.body.outputs.findIndex((output) => output?.value?.assets);

          expect(response.length).toEqual(1);
          expect(tx.body.outputs[maOutputIndex].value.assets?.size).toBeGreaterThan(0);
          expect(tx.body.outputs[maOutputIndex]).toMatchShapeOf(DataMocks.Tx.txOutWithAssets);
        });

        it('has mint operations', async () => {
          const response = await provider.transactionsByHashes({
            ids: await fixtureBuilder.getTxHashes(1, { with: [TxWith.Mint] })
          });
          const tx: Cardano.HydratedTx = response[0];
          expect(response.length).toEqual(1);
          expect(tx.body.mint).toMatchShapeOf(DataMocks.Tx.mint);
          expect(tx.body.mint?.size).toBeGreaterThan(0);
        });

        it('has withdrawals', async () => {
          const response = await provider.transactionsByHashes({
            ids: await fixtureBuilder.getTxHashes(1, { with: [TxWith.Withdrawal] })
          });
          const tx: Cardano.HydratedTx = response[0];
          expect(response.length).toEqual(1);
          expect(tx.body.withdrawals!).toMatchShapeOf(DataMocks.Tx.withdrawals);
          expect(tx.body.withdrawals?.length).toBeGreaterThan(0);
        });

        it('has redeemers', async () => {
          const response = await provider.transactionsByHashes({
            ids: await fixtureBuilder.getTxHashes(1, { with: [TxWith.Redeemer] })
          });

          const tx: Cardano.Tx = response[0];
          expect(response.length).toEqual(1);
          expect(tx.witness).toMatchShapeOf(DataMocks.Tx.witnessRedeemers);
          expect(tx.witness.redeemers!.length).toBeGreaterThan(0);
        });

        it('has auxiliary data', async () => {
          const response = await provider.transactionsByHashes({
            ids: await fixtureBuilder.getTxHashes(1, { with: [TxWith.AuxiliaryData] })
          });
          const tx: Cardano.HydratedTx = response[0];
          expect(response.length).toEqual(1);
          expect(tx.auxiliaryData).toBeDefined();
        });

        it('has collateral inputs', async () => {
          const response = await provider.transactionsByHashes({
            ids: await fixtureBuilder.getTxHashes(1, { with: [TxWith.CollateralInput] })
          });
          const tx: Cardano.HydratedTx = response[0];
          expect(response.length).toEqual(1);

          expect(tx.body.collaterals).toMatchShapeOf(DataMocks.Tx.collateralInputs);
          expect(tx.body.collaterals?.length).toEqual(1);
        });

        it('has collateral outputs', async () => {
          const response = await provider.transactionsByHashes({
            ids: await fixtureBuilder.getTxHashes(1, { with: [TxWith.CollateralOutput] })
          });
          const tx: Cardano.HydratedTx = response[0];
          expect(response.length).toEqual(1);

          expect(tx.body.collateralReturn).toMatchShapeOf(DataMocks.Tx.collateralReturn);
        });

        it('has certificates', async () => {
          const response = await provider.transactionsByHashes({
            ids: await fixtureBuilder.getTxHashes(2, { with: [TxWith.DelegationCertificate] })
          });

          const tx1: Cardano.HydratedTx = response[0];
          const tx2: Cardano.HydratedTx = response[1];

          expect(response.length).toEqual(2);
          expect(tx1.body.certificates?.length).toBeGreaterThan(0);
          expect(tx2.body.certificates?.length).toBeGreaterThan(0);
          expect(
            tx1.body.certificates?.filter((val) => val.__typename === Cardano.CertificateType.StakeDelegation)
          ).toMatchShapeOf(DataMocks.Tx.delegationCertificate);
          expect(
            tx2.body.certificates?.filter((val) => val.__typename === Cardano.CertificateType.StakeDelegation)
          ).toMatchShapeOf(DataMocks.Tx.delegationCertificate);
        });
      });
    });

    describe('/txs/by-addresses', () => {
      const url = '/txs/by-addresses';
      describe('with Http Server', () => {
        it('returns a 200 coded response with a well formed HTTP request', async () => {
          expect(
            (await axios.post(`${baseUrlWithVersion}${url}`, { addresses: [], pagination: { limit: 5, startAt: 0 } }))
              .status
          ).toEqual(200);
        });

        it('returns a 415 coded response if the wrong content type header is used', async () => {
          try {
            await axios.post(
              `${baseUrlWithVersion}${url}`,
              { addresses: [], pagination: { limit: 5, startAt: 0 } },
              { headers: { 'Content-Type': APPLICATION_CBOR } }
            );
            throw new Error('fail');
          } catch (error: any) {
            expect(error.response.status).toBe(415);
            expect(error.message).toBe(UNSUPPORTED_MEDIA_STRING);
          }
        });
      });

      it('returns an array of transactions', async () => {
        const addresses = await fixtureBuilder.getDistinctAddresses(2);
        const pagination = { limit: 5, startAt: 0 };

        const response = await provider.transactionsByAddresses({ addresses, pagination });

        expect(response.pageResults.length).toEqual(5);
        expect(() => Cardano.PaymentAddress(addresses[0] as unknown as string)).not.toThrow();
      });

      it('does not include transactions not found', async () => {
        const unknownAddress = Cardano.PaymentAddress(
          'addr_test1qrrmuxkfgytnf2lhlx2qhg8uz276747cnduyqpjutqac4qydra7fr0rzkg800zmk29x6tg92yqp7mnvmt42ruqgg5vjsncz9rt'
        );
        const response = await provider.transactionsByAddresses({
          addresses: [unknownAddress, (await fixtureBuilder.getDistinctAddresses(1))[0]],
          pagination: { limit: 5, startAt: 0 }
        });
        for (const tx of response.pageResults) {
          for (const output of tx.body.outputs) {
            expect(output.address).not.toEqual(unknownAddress);
          }
        }

        expect(response.pageResults.length).toEqual(5);
      });

      it('does not include transactions before indicated block', async () => {
        const { addresses, blockRange, txInRangeCount } = await fixtureBuilder.getAddressesWithSomeInBlockRange(2, {
          lowerBound: Cardano.BlockNo(10),
          upperBound: Cardano.BlockNo(100)
        });
        const response = await provider.transactionsByAddresses({
          addresses: [...addresses],
          blockRange,
          pagination: { limit: 5, startAt: 0 }
        });

        let lowerBound = DB_MAX_SAFE_INTEGER;
        for (const tx of response.pageResults) lowerBound = Math.min(lowerBound, tx.blockHeader.blockNo);

        expect(response.totalResultCount).toEqual(txInRangeCount);
        expect(lowerBound).toBeGreaterThanOrEqual(10);
        expect(() => Cardano.PaymentAddress([...addresses][0] as unknown as string)).not.toThrow();
        for (const tx of response.pageResults) expect(tx.blockHeader).toMatchShapeOf(DataMocks.Tx.blockHeader);
      });

      it('does not include transactions after indicated block', async () => {
        const { addresses, blockRange, txInRangeCount } = await fixtureBuilder.getAddressesWithSomeInBlockRange(2, {
          lowerBound: Cardano.BlockNo(0),
          upperBound: Cardano.BlockNo(10)
        });
        const response = await provider.transactionsByAddresses({
          addresses: [...addresses],
          blockRange,
          pagination: { limit: 5, startAt: 0 }
        });

        let upperBound = 0;
        for (const tx of response.pageResults) upperBound = Math.max(upperBound, tx.blockHeader.blockNo);

        expect(response.totalResultCount).toEqual(txInRangeCount);
        expect(upperBound).toBeLessThanOrEqual(10);
        for (const tx of response.pageResults) expect(tx.blockHeader).toMatchShapeOf(DataMocks.Tx.blockHeader);
      });

      // TODO: fails after regenerating test db: no tx'es in this block range
      it.skip('includes transactions only in specified block range', async () => {
        const { addresses, blockRange, txInRangeCount } = await fixtureBuilder.getAddressesWithSomeInBlockRange(2, {
          lowerBound: Cardano.BlockNo(600),
          upperBound: Cardano.BlockNo(1000)
        });

        const response = await provider.transactionsByAddresses({
          addresses: [...addresses],
          blockRange,
          pagination: { limit: 5, startAt: 0 }
        });

        let lowerBound = DB_MAX_SAFE_INTEGER;
        let upperBound = 0;

        for (const tx of response.pageResults) {
          upperBound = Math.max(upperBound, tx.blockHeader.blockNo);
          lowerBound = Math.min(lowerBound, tx.blockHeader.blockNo);
        }

        expect(response.totalResultCount).toEqual(txInRangeCount);
        expect(lowerBound).toBeGreaterThanOrEqual(200);
        expect(upperBound).toBeLessThanOrEqual(1000);
        for (const tx of response.pageResults) expect(tx.blockHeader).toMatchShapeOf(DataMocks.Tx.blockHeader);
      });

      it('returns a 400 coded error if pagination argument is not provided', async () => {
        try {
          await axios.post(
            `${baseUrlWithVersion}${url}`,
            {
              addresses: await fixtureBuilder.getDistinctAddresses(1)
            },
            { headers: { 'Content-Type': APPLICATION_JSON } }
          );
        } catch (error: any) {
          expect(error.response.status).toBe(400);
          expect(error.message).toBe(BAD_REQUEST);
        }
      });

      it('returns a 400 coded error if provided transaction addresses are greater than pagination page size limit', async () => {
        try {
          await axios.post(
            `${baseUrlWithVersion}${url}`,
            {
              addresses: await fixtureBuilder.getDistinctAddresses(6),
              pagination: { limit: 5, startAt: 0 }
            },
            { headers: { 'Content-Type': APPLICATION_JSON } }
          );
        } catch (error: any) {
          expect(error.response.status).toBe(400);
          expect(error.message).toBe(BAD_REQUEST);
        }
      });

      describe('finds transactions of given addresses', () => {
        it('finds transactions with address within inputs', async () => {
          const genesisAddresses: Cardano.PaymentAddress[] = await fixtureBuilder.getDistinctAddresses(3);
          const addresses: Cardano.PaymentAddress[] = [genesisAddresses[0]];
          const response = await provider.transactionsByAddresses({ addresses, pagination: { limit: 5, startAt: 0 } });
          expect(response.pageResults.length).toBeGreaterThan(0);
          expect(
            response.pageResults[1].body.inputs.find((txIn) => txIn.address === genesisAddresses[0])
          ).toBeDefined();
          expect(response.pageResults[0].body.inputs).toMatchShapeOf(DataMocks.Tx.inputs);
        });

        it('finds transactions with address within outputs', async () => {
          const addresses: Cardano.PaymentAddress[] = await fixtureBuilder.getGenesisAddresses();
          expect(() => Cardano.PaymentAddress(addresses[0] as unknown as string)).not.toThrow();

          const firstPageResponse = await provider.transactionsByAddresses({
            addresses,
            pagination: { limit: 3, startAt: 0 }
          });
          const secondPageResponse = await provider.transactionsByAddresses({
            addresses,
            pagination: { limit: 3, startAt: 3 }
          });

          const firstTx = firstPageResponse.pageResults[0];

          expect(secondPageResponse.pageResults.includes(firstTx)).toEqual(false);

          expect(firstPageResponse.totalResultCount).toBeGreaterThan(0);
          expect(firstPageResponse.pageResults.length).toBeGreaterThan(0);
          expect(secondPageResponse.pageResults.length).toBeGreaterThan(0);

          let outputs: Cardano.TxOut[] = [];

          for (const tx of firstPageResponse.pageResults) outputs = [...outputs, ...tx.body.outputs];
          for (const tx of secondPageResponse.pageResults) outputs = [...outputs, ...tx.body.outputs];

          expect(outputs.find((txOut) => txOut.address === addresses[0])).toBeDefined();
          expect(outputs.find((txOut) => txOut.address === addresses[1])).toBeDefined();
          expect(outputs.find((txOut) => txOut.address === addresses[2])).toBeDefined();
          expect(firstPageResponse.pageResults[0].body.outputs).toMatchShapeOf(DataMocks.Tx.outputs);
          expect(secondPageResponse.pageResults[0].body.outputs).toMatchShapeOf(DataMocks.Tx.outputs);
        });
      });
    });
  });
});
