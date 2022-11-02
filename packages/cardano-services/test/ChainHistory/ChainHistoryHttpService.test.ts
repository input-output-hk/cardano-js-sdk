/* eslint-disable sonarjs/no-identical-functions */
/* eslint-disable sonarjs/no-duplicate-string */
/* eslint-disable sonarjs/cognitive-complexity */
/* eslint-disable max-len */
/* eslint-disable @typescript-eslint/no-explicit-any */
import { BlockNoModel, findLastBlockNo } from '../../src/util/DbSyncProvider';
import { Cardano, ChainHistoryProvider, ProviderError, ProviderFailure } from '@cardano-sdk/core';
import { ChainHistoryFixtureBuilder, TxWith } from './fixtures/FixtureBuilder';
import { ChainHistoryHttpService, DbSyncChainHistoryProvider, HttpServer, HttpServerConfig } from '../../src';
import { CreateHttpProviderConfig, chainHistoryHttpProvider } from '@cardano-sdk/cardano-services-client';
import { DB_MAX_SAFE_INTEGER } from '../../src/ChainHistory/DbSyncChainHistory/queries';
import { DataMocks } from '../data-mocks';
import { OgmiosCardanoNode } from '@cardano-sdk/ogmios';
import { Pool } from 'pg';
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
  let dbConnection: Pool;
  let httpServer: HttpServer;
  let chainHistoryProvider: DbSyncChainHistoryProvider;
  let service: ChainHistoryHttpService;
  let port: number;
  let baseUrl: string;
  let clientConfig: CreateHttpProviderConfig<ChainHistoryProvider>;
  let config: HttpServerConfig;
  let provider: ChainHistoryProvider;
  let cardanoNode: OgmiosCardanoNode;
  let lastBlockNoInDb: Cardano.BlockNo;
  let fixtureBuilder: ChainHistoryFixtureBuilder;

  beforeAll(async () => {
    port = await getPort();
    baseUrl = `http://localhost:${port}/chain-history`;
    clientConfig = { baseUrl, logger };
    config = { listen: { port } };
    dbConnection = new Pool({ connectionString: process.env.LOCALNETWORK_INTEGRAION_TESTS_POSTGRES_CONNECTION_STRING });
    fixtureBuilder = new ChainHistoryFixtureBuilder(dbConnection, logger);
  });

  describe('unhealthy ChainHistoryProvider', () => {
    beforeEach(async () => {
      chainHistoryProvider = {
        blocksByHashes: jest.fn(),
        healthCheck: jest.fn(() => Promise.resolve({ ok: false })),
        transactionsByAddresses: jest.fn(),
        transactionsByHashes: jest.fn()
      } as unknown as DbSyncChainHistoryProvider;
    });
    it('should not throw during service create if the ChainHistoryProvider is unhealthy', () => {
      expect(() => new ChainHistoryHttpService({ chainHistoryProvider, logger })).not.toThrow(
        new ProviderError(ProviderFailure.Unhealthy)
      );
    });

    it('throws during service initialization if the ChainHistoryProvider is unhealthy', async () => {
      service = new ChainHistoryHttpService({ chainHistoryProvider, logger });
      httpServer = new HttpServer(config, { logger, runnableDependencies: [], services: [service] });
      await expect(httpServer.initialize()).rejects.toThrow(new ProviderError(ProviderFailure.Unhealthy));
    });
  });

  describe('healthy state', () => {
    beforeAll(async () => {
      const metadataService = createDbSyncMetadataService(dbConnection, logger);
      lastBlockNoInDb = (await dbConnection.query<BlockNoModel>(findLastBlockNo)).rows[0].block_no;
      cardanoNode = mockCardanoNode(
        healthCheckResponseMock({ blockNo: lastBlockNoInDb })
      ) as unknown as OgmiosCardanoNode;
      chainHistoryProvider = new DbSyncChainHistoryProvider(
        { paginationPageSizeLimit: PAGINATION_PAGE_SIZE_LIMIT },
        { cardanoNode, db: dbConnection, logger, metadataService }
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
      await dbConnection.end();
      await httpServer.shutdown();
    });

    describe('/health', () => {
      const url = '/health';
      it('forwards the chainHistoryProvider health response with HTTP request', async () => {
        const res = await axios.post(`${baseUrl}${url}`, undefined, {
          headers: { 'Content-Type': APPLICATION_JSON }
        });
        expect(res.status).toBe(200);
        expect(res.data).toEqual(healthCheckResponseMock({ blockNo: lastBlockNoInDb }));
      });

      it('forwards the chainHistoryProvider health response with provider client', async () => {
        const response = await provider.healthCheck();
        expect(response).toEqual(healthCheckResponseMock({ blockNo: lastBlockNoInDb }));
      });
    });

    describe('/blocks/by-hashes', () => {
      const url = '/blocks/by-hashes';
      describe('with Http Service', () => {
        it('returns a 200 coded response with a well formed HTTP request', async () => {
          expect((await axios.post(`${baseUrl}${url}`, { ids: [] })).status).toEqual(200);
        });

        it('returns a 415 coded response if the wrong content type header is used', async () => {
          try {
            await axios.post(`${baseUrl}${url}`, { ids: [] }, { headers: { 'Content-Type': APPLICATION_CBOR } });
            throw new Error('fail');
          } catch (error: any) {
            expect(error.response.status).toBe(415);
            expect(error.message).toBe(UNSUPPORTED_MEDIA_STRING);
          }
        });
      });

      it('returns an array of blocks', async () => {
        const response = await provider.blocksByHashes({
          ids: await fixtureBuilder.getBlockHashes(2)
        });
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
            `${baseUrl}${url}`,
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
          expect((await axios.post(`${baseUrl}${url}`, { ids: [] })).status).toEqual(200);
        });

        it('returns a 415 coded response if the wrong content type header is used', async () => {
          try {
            await axios.post(`${baseUrl}${url}`, { ids: [] }, { headers: { 'Content-Type': APPLICATION_CBOR } });
            throw new Error('fail');
          } catch (error: any) {
            expect(error.response.status).toBe(415);
            expect(error.message).toBe(UNSUPPORTED_MEDIA_STRING);
          }
        });
      });

      it('returns an array of transactions', async () => {
        const response = await provider.transactionsByHashes({ ids: await fixtureBuilder.getTxHashes(5) });
        expect(response).toHaveLength(5);
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
            `${baseUrl}${url}`,
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
          const tx: Cardano.TxAlonzo = response[0];

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
          const tx: Cardano.TxAlonzo = response[0];
          expect(response.length).toEqual(1);
          expect(tx.body.mint).toMatchShapeOf(DataMocks.Tx.mint);
          expect(tx.body.mint?.size).toBeGreaterThan(0);
        });

        // Wait for the rewards withdrawal e2e to be completed.
        it.skip('has withdrawals', async () => {
          const response = await provider.transactionsByHashes({
            ids: await fixtureBuilder.getTxHashes(1, { with: [TxWith.Withdrawal] })
          });
          const tx: Cardano.TxAlonzo = response[0];
          expect(response.length).toEqual(1);
          expect(tx).toMatchShapeOf(DataMocks.Tx.withWithdrawals);
          expect(tx.body.withdrawals?.length).toBeGreaterThan(0);
        });

        it('has redeemers', async () => {
          const response = await provider.transactionsByHashes({
            ids: await fixtureBuilder.getTxHashes(1, { with: [TxWith.Redeemer] })
          });

          const tx: Cardano.NewTxAlonzo = response[0];
          expect(response.length).toEqual(1);
          expect(tx.witness).toMatchShapeOf(DataMocks.Tx.witnessRedeemers);
          expect(tx.witness.redeemers?.length).toBeGreaterThan(0);
        });

        it('has auxiliary data', async () => {
          const response = await provider.transactionsByHashes({
            ids: await fixtureBuilder.getTxHashes(1, { with: [TxWith.AuxiliaryData] })
          });
          const tx: Cardano.TxAlonzo = response[0];
          expect(response.length).toEqual(1);
          expect(tx.auxiliaryData).toBeDefined();
        });

        it('has collateral inputs', async () => {
          const response = await provider.transactionsByHashes({
            ids: await fixtureBuilder.getTxHashes(1, { with: [TxWith.CollateralInput] })
          });
          const tx: Cardano.TxAlonzo = response[0];
          expect(response.length).toEqual(1);

          expect(tx.body.collaterals).toMatchShapeOf(DataMocks.Tx.collateralInputs);
          expect(tx.body.collaterals?.length).toEqual(1);
        });

        it('has certificates', async () => {
          const response = await provider.transactionsByHashes({
            ids: await fixtureBuilder.getTxHashes(2, { with: [TxWith.DelegationCertificate] })
          });

          const tx1: Cardano.TxAlonzo = response[0];
          const tx2: Cardano.TxAlonzo = response[1];

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
            (await axios.post(`${baseUrl}${url}`, { addresses: [], pagination: { limit: 5, startAt: 0 } })).status
          ).toEqual(200);
        });

        it('returns a 415 coded response if the wrong content type header is used', async () => {
          try {
            await axios.post(
              `${baseUrl}${url}`,
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
        const response = await provider.transactionsByAddresses({
          addresses: await fixtureBuilder.getDistinctAddresses(2),
          pagination: { limit: 5, startAt: 0 }
        });
        expect(response.pageResults.length).toEqual(5);
      });

      it('does not include transactions not found', async () => {
        const unknownAddress = Cardano.Address(
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
          lowerBound: 10,
          upperBound: 100
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
        for (const tx of response.pageResults) expect(tx.blockHeader).toMatchShapeOf(DataMocks.Tx.blockHeader);
      });

      it('does not include transactions after indicated block', async () => {
        const { addresses, blockRange, txInRangeCount } = await fixtureBuilder.getAddressesWithSomeInBlockRange(2, {
          lowerBound: 0,
          upperBound: 10
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

      it('includes transactions only in specified block range', async () => {
        const { addresses, blockRange, txInRangeCount } = await fixtureBuilder.getAddressesWithSomeInBlockRange(2, {
          lowerBound: 200,
          upperBound: 1000
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
            `${baseUrl}${url}`,
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
            `${baseUrl}${url}`,
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
          const genesisAddresses: Cardano.Address[] = await fixtureBuilder.getGenesisAddresses();
          const addresses: Cardano.Address[] = [genesisAddresses[0]];
          const response = await provider.transactionsByAddresses({ addresses, pagination: { limit: 5, startAt: 0 } });
          expect(response.pageResults.length).toBeGreaterThan(0);
          expect(
            response.pageResults[0].body.inputs.find((txIn) => txIn.address === genesisAddresses[0])
          ).toBeDefined();
          expect(response.pageResults[0].body.inputs).toMatchShapeOf(DataMocks.Tx.inputs);
        });

        it('finds transactions with address within outputs', async () => {
          const addresses: Cardano.Address[] = await fixtureBuilder.getGenesisAddresses();
          const firstPageResponse = await provider.transactionsByAddresses({
            addresses,
            pagination: { limit: 5, startAt: 0 }
          });
          const secondPageResponse = await provider.transactionsByAddresses({
            addresses,
            pagination: { limit: 5, startAt: 5 }
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
