/* eslint-disable sonarjs/no-identical-functions */
/* eslint-disable sonarjs/no-duplicate-string */
/* eslint-disable sonarjs/cognitive-complexity */
/* eslint-disable max-len */
/* eslint-disable @typescript-eslint/no-explicit-any */
import { BlockNoModel, findLastBlockNo } from '../../src/util/DbSyncProvider';
import { Cardano, ChainHistoryProvider, ProviderError, ProviderFailure } from '@cardano-sdk/core';
import { ChainHistoryHttpService, DbSyncChainHistoryProvider, HttpServer, HttpServerConfig } from '../../src';
import { CreateHttpProviderConfig, chainHistoryHttpProvider } from '@cardano-sdk/cardano-services-client';
import { INFO, createLogger } from 'bunyan';
import { OgmiosCardanoNode } from '@cardano-sdk/ogmios';
import { Pool } from 'pg';
import { createDbSyncMetadataService } from '../../src/Metadata';
import { getPort } from 'get-port-please';
import { healthCheckResponseMock, mockCardanoNode } from '../../../core/test/CardanoNode/mocks';
import { dummyLogger as logger } from 'ts-log';
import axios from 'axios';

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

  beforeAll(async () => {
    port = await getPort();
    baseUrl = `http://localhost:${port}/chain-history`;
    clientConfig = { baseUrl, logger: createLogger({ level: INFO, name: 'unit tests' }) };
    config = { listen: { port } };
    dbConnection = new Pool({ connectionString: process.env.POSTGRES_CONNECTION_STRING });
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
      httpServer = new HttpServer(config, { logger, runnableDependencies: [cardanoNode], services: [service] });
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
          expect.assertions(2);
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
        const ids: Cardano.BlockId[] = [
          Cardano.BlockId('7a48b034645f51743550bbaf81f8a14771e58856e031eb63844738ca8ad72298'),
          Cardano.BlockId('469cc6fbcc186de6b12c392ad0cc84a20c4d4774c1f9c3cfd80745de00856f4b')
        ];
        const response = await provider.blocksByHashes({ ids });
        expect(response).toHaveLength(2);
      });

      it('does not include blocks not found', async () => {
        const ids: Cardano.BlockId[] = [
          Cardano.BlockId('7a48b034645f51743550bbaf81f8a14771e58856e031eb63844738ca8ad72298'),
          Cardano.BlockId('0000000000000000000000000000000000000000000000000000000000000000')
        ];
        const response = await provider.blocksByHashes({ ids });
        expect(response).toHaveLength(1);
      });

      it('returns a 400 coded error if provided block ids are greater than pagination page size limit', async () => {
        expect.assertions(2);
        const ids: Cardano.BlockId[] = [
          Cardano.BlockId('7a48b034645f51743550bbaf81f8a14771e58856e031eb63844738ca8ad72298'),
          Cardano.BlockId('469cc6fbcc186de6b12c392ad0cc84a20c4d4774c1f9c3cfd80745de00856f4b'),
          Cardano.BlockId('332340bfcf47951b4bc8eca51c4e9190d29e2fd6dae30be231ebcdadb2d8c399'),
          Cardano.BlockId('5caede44f4a5a775443095159cd42c8a64f35494086957ab3e04624015a6e13c'),
          Cardano.BlockId('f03084089ec7e74a79e69a5929b2d3c0836d6f12279bd103d0875847c740ae27'),
          Cardano.BlockId('2a05b10c31856b77ac90b67140c7faa2cef4c4afd093caf95fb5b2c328e25183')
        ];
        try {
          await axios.post(`${baseUrl}${url}`, { ids }, { headers: { 'Content-Type': APPLICATION_JSON } });
        } catch (error: any) {
          expect(error.response.status).toBe(400);
          expect(error.message).toBe(BAD_REQUEST);
        }
      });

      describe('server and snapshot testing', () => {
        it('has all block information', async () => {
          const ids: Cardano.BlockId[] = [
            Cardano.BlockId('7a48b034645f51743550bbaf81f8a14771e58856e031eb63844738ca8ad72298'),
            Cardano.BlockId('469cc6fbcc186de6b12c392ad0cc84a20c4d4774c1f9c3cfd80745de00856f4b')
          ];
          const response = await provider.blocksByHashes({ ids });
          expect(response.length).toEqual(2);
          expect(response).toMatchSnapshot();
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
          expect.assertions(2);
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
        const ids: Cardano.TransactionId[] = [
          Cardano.TransactionId('cefd2fcf657e5e5d6c35975f4e052f427819391b153ebb16ad8aa107ba5a3819'),
          Cardano.TransactionId('952dfa431223fd671c5e9e048e016f70fcebd9e41fcb726969415ff692736eeb'),
          Cardano.TransactionId('cb66e0f5778718f8bfcfd043712f37d9993f4703b254a7a4d954d34225fe2f99'),
          Cardano.TransactionId('24e75c64a309fd8fb400933795b2522ca818cba80a3838c2ff14cec2cc8ffe4e'),
          Cardano.TransactionId('3d2278e9cef71c79720a11bc3e08acbbd5f2175f7015d358c867fc9b419ae0b2')
        ];
        const response = await provider.transactionsByHashes({ ids });
        expect(response).toHaveLength(5);
      });

      it('does not include transactions not found', async () => {
        const ids: Cardano.TransactionId[] = [
          Cardano.TransactionId('295d5e0f7ee182426eaeda8c9f1c63502c72cdf4afd6e0ee0f209adf94a614e7'),
          Cardano.TransactionId('0000000000000000000000000000000000000000000000000000000000000000')
        ];
        const response = await provider.transactionsByHashes({ ids });
        expect(response.length).toEqual(1);
      });

      it('returns a 400 coded error if provided transaction ids are greater than pagination page size limit', async () => {
        expect.assertions(2);
        const ids: Cardano.TransactionId[] = [
          Cardano.TransactionId('cefd2fcf657e5e5d6c35975f4e052f427819391b153ebb16ad8aa107ba5a3819'),
          Cardano.TransactionId('952dfa431223fd671c5e9e048e016f70fcebd9e41fcb726969415ff692736eeb'),
          Cardano.TransactionId('cb66e0f5778718f8bfcfd043712f37d9993f4703b254a7a4d954d34225fe2f99'),
          Cardano.TransactionId('24e75c64a309fd8fb400933795b2522ca818cba80a3838c2ff14cec2cc8ffe4e'),
          Cardano.TransactionId('3d2278e9cef71c79720a11bc3e08acbbd5f2175f7015d358c867fc9b419ae0b2'),
          Cardano.TransactionId('5acd6efb1b66299f1c5a2c4221af4bcaa4ba9929e8e6aa0e3f48707fa1796fc3'),
          Cardano.TransactionId('face165bd7aa8d0d661cf1ceaa4e35d7611be3b1c7997da378c547aa2464a4fd')
        ];
        try {
          await axios.post(`${baseUrl}${url}`, { ids }, { headers: { 'Content-Type': APPLICATION_JSON } });
        } catch (error: any) {
          expect(error.response.status).toBe(400);
          expect(error.message).toBe(BAD_REQUEST);
        }
      });

      describe('server and snapshot testing', () => {
        it('has outputs with multi-assets', async () => {
          const ids: Cardano.TransactionId[] = [
            Cardano.TransactionId('cefd2fcf657e5e5d6c35975f4e052f427819391b153ebb16ad8aa107ba5a3819')
          ];
          const response = await provider.transactionsByHashes({ ids });
          const tx: Cardano.TxAlonzo = response[0];
          expect(response.length).toEqual(1);
          expect(tx.body.outputs[0].value.assets?.size).toBeGreaterThan(0);
          expect(response).toMatchSnapshot();
        });

        it('has mint operations', async () => {
          const ids: Cardano.TransactionId[] = [
            Cardano.TransactionId('952dfa431223fd671c5e9e048e016f70fcebd9e41fcb726969415ff692736eeb')
          ];
          const response = await provider.transactionsByHashes({ ids });
          const tx: Cardano.TxAlonzo = response[0];
          expect(response.length).toEqual(1);
          expect(response).toMatchSnapshot();
          expect(tx.body.mint?.size).toBeGreaterThan(0);
        });

        it('has withdrawals', async () => {
          const ids: Cardano.TransactionId[] = [
            Cardano.TransactionId('cb66e0f5778718f8bfcfd043712f37d9993f4703b254a7a4d954d34225fe2f99')
          ];
          const response = await provider.transactionsByHashes({ ids });
          const tx: Cardano.TxAlonzo = response[0];
          expect(response.length).toEqual(1);
          expect(response).toMatchSnapshot();
          expect(tx.body.withdrawals?.length).toBeGreaterThan(0);
        });

        it('has redeemers', async () => {
          const ids: Cardano.TransactionId[] = [
            Cardano.TransactionId('24e75c64a309fd8fb400933795b2522ca818cba80a3838c2ff14cec2cc8ffe4e')
          ];
          const response = await provider.transactionsByHashes({ ids });
          const tx: Cardano.TxAlonzo = response[0];
          expect(response.length).toEqual(1);
          expect(response).toMatchSnapshot();
          expect(tx.witness.redeemers?.length).toBeGreaterThan(0);
        });

        it('has auxiliary data', async () => {
          const ids: Cardano.TransactionId[] = [
            Cardano.TransactionId('3d2278e9cef71c79720a11bc3e08acbbd5f2175f7015d358c867fc9b419ae0b2')
          ];
          const response = await provider.transactionsByHashes({ ids });
          const tx: Cardano.TxAlonzo = response[0];
          expect(response.length).toEqual(1);
          expect(response).toMatchSnapshot();
          expect(tx.auxiliaryData).toBeDefined();
        });

        it('has collateral inputs', async () => {
          const ids: Cardano.TransactionId[] = [
            Cardano.TransactionId('5acd6efb1b66299f1c5a2c4221af4bcaa4ba9929e8e6aa0e3f48707fa1796fc3')
          ];
          const response = await provider.transactionsByHashes({ ids });
          const tx: Cardano.TxAlonzo = response[0];
          expect(response.length).toEqual(1);
          expect(response).toMatchSnapshot();
          expect(tx.body.collaterals?.length).toEqual(0);
        });

        it('has certificates', async () => {
          const ids: Cardano.TransactionId[] = [
            Cardano.TransactionId('face165bd7aa8d0d661cf1ceaa4e35d7611be3b1c7997da378c547aa2464a4fd'),
            Cardano.TransactionId('19251f57476d7af2777252270413c01383d9503110a68b4fde1a239c119c4f5d')
          ];
          const response = await provider.transactionsByHashes({ ids });
          const tx1: Cardano.TxAlonzo = response[0];
          const tx2: Cardano.TxAlonzo = response[1];
          expect(response.length).toEqual(2);
          expect(response).toMatchSnapshot();
          expect(tx1.body.certificates?.length).toBeGreaterThan(0);
          expect(tx2.body.certificates?.length).toBeGreaterThan(0);
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
          expect.assertions(2);
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
        const addresses: Cardano.Address[] = [
          Cardano.Address(
            'addr_test1qq7rv7r27wq5nz2q6htul8k55xrcjsz2tpxkhqfk5f6kfgfnqdurhe3e8zlltj63kwh78hg7ykrexmn6jxxn42egzs4skzyvvc'
          ),
          Cardano.Address(
            'addr_test1qr4m502gr9hnaxac5mxjln22jwavf7pcjmh9sw7fujdvgvj9ef6afquphwg7tj4mmm548m3t50hxfyygjuu222kx96eshcathg'
          )
        ];
        const response = await provider.transactionsByAddresses({ addresses, pagination: { limit: 5, startAt: 0 } });
        expect(response.pageResults).toHaveLength(3);
        expect(response.totalResultCount).toEqual(3);
      });

      it('does not include transactions not found', async () => {
        const addresses: Cardano.Address[] = [
          Cardano.Address(
            'addr_test1qq7rv7r27wq5nz2q6htul8k55xrcjsz2tpxkhqfk5f6kfgfnqdurhe3e8zlltj63kwh78hg7ykrexmn6jxxn42egzs4skzyvvc'
          ),
          Cardano.Address(
            'addr1qy4t3dy78sawthpu3049rj4858jr73flal3a3p9lgyv7u0e2hz6fu0p6uhwrezl228920g0y8aznlmlrmzzt7sgeaclsfpu9gf'
          )
        ];
        const response = await provider.transactionsByAddresses({ addresses, pagination: { limit: 5, startAt: 0 } });
        expect(response.pageResults).toHaveLength(1);
        expect(response.totalResultCount).toEqual(1);
      });

      it('does not include transactions before indicated block', async () => {
        const addresses: Cardano.Address[] = [
          Cardano.Address(
            'addr_test1qr4m502gr9hnaxac5mxjln22jwavf7pcjmh9sw7fujdvgvj9ef6afquphwg7tj4mmm548m3t50hxfyygjuu222kx96eshcathg'
          ),
          Cardano.Address(
            'addr_test1qrrgh4kuq2tlgcpawpta7e7t6dacelhkwh9wm0wzxdx2alv2fa9cu9sfmxem2d2jyzdukjh43dxh84elp9y64da67zvsasy6xs'
          )
        ];
        const response = await provider.transactionsByAddresses({
          addresses,
          blockRange: { lowerBound: 1_654_555 },
          pagination: { limit: 5, startAt: 0 }
        });
        expect(response.pageResults).toHaveLength(2);
        expect(response.totalResultCount).toEqual(2);
      });

      it('does not include transactions after indicated block', async () => {
        const addresses: Cardano.Address[] = [
          Cardano.Address(
            'addr_test1qr4m502gr9hnaxac5mxjln22jwavf7pcjmh9sw7fujdvgvj9ef6afquphwg7tj4mmm548m3t50hxfyygjuu222kx96eshcathg'
          ),
          Cardano.Address(
            'addr_test1qrrgh4kuq2tlgcpawpta7e7t6dacelhkwh9wm0wzxdx2alv2fa9cu9sfmxem2d2jyzdukjh43dxh84elp9y64da67zvsasy6xs'
          )
        ];
        const response = await provider.transactionsByAddresses({
          addresses,
          blockRange: { upperBound: 1_646_558 },
          pagination: { limit: 5, startAt: 0 }
        });
        expect(response.pageResults).toHaveLength(1);
        expect(response.totalResultCount).toEqual(1);
      });

      it('includes transactions only in specified block range', async () => {
        const addresses: Cardano.Address[] = [
          Cardano.Address(
            'addr_test1qr4m502gr9hnaxac5mxjln22jwavf7pcjmh9sw7fujdvgvj9ef6afquphwg7tj4mmm548m3t50hxfyygjuu222kx96eshcathg'
          ),
          Cardano.Address(
            'addr_test1qz2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzer3jcu5d8ps7zex2k2xt3uqxgjqnnj83ws8lhrn648jjxtwq2ytjqp'
          )
        ];
        const response = await provider.transactionsByAddresses({
          addresses,
          blockRange: { lowerBound: 1_654_556, upperBound: 3_157_933 },
          pagination: { limit: 5, startAt: 0 }
        });
        expect(response.pageResults).toHaveLength(3);
        expect(response.totalResultCount).toEqual(3);
      });

      it('returns a 400 coded error if pagination argument is not provided', async () => {
        expect.assertions(2);
        const addresses: Cardano.Address[] = [
          Cardano.Address(
            'addr_test1qpcnmvyjmxmsm75f747u566gw7ewz4mesdw7yl278uf9r3f5l7d7dpx2ymfwlm3e56flupga8yamjr2kwdt7dw77ktyqqtx2r7'
          )
        ];

        try {
          await axios.post(`${baseUrl}${url}`, { addresses }, { headers: { 'Content-Type': APPLICATION_JSON } });
        } catch (error: any) {
          expect(error.response.status).toBe(400);
          expect(error.message).toBe(BAD_REQUEST);
        }
      });

      it('returns a 400 coded error if provided transaction addresses are greater than pagination page size limit', async () => {
        expect.assertions(2);
        const addresses: Cardano.Address[] = [
          Cardano.Address(
            'addr_test1qpcnmvyjmxmsm75f747u566gw7ewz4mesdw7yl278uf9r3f5l7d7dpx2ymfwlm3e56flupga8yamjr2kwdt7dw77ktyqqtx2r7'
          ),
          Cardano.Address(
            'addr_test1qq7rv7r27wq5nz2q6htul8k55xrcjsz2tpxkhqfk5f6kfgfnqdurhe3e8zlltj63kwh78hg7ykrexmn6jxxn42egzs4skzyvvc'
          ),
          Cardano.Address(
            'addr_test1qr4m502gr9hnaxac5mxjln22jwavf7pcjmh9sw7fujdvgvj9ef6afquphwg7tj4mmm548m3t50hxfyygjuu222kx96eshcathg'
          ),
          Cardano.Address(
            'addr_test1qp620qa3rqzd5fxj3hy4dughv7xx2dt9gu9de70jf8hagdcvmqt35f2psxv7ajj5jnh4ajlc752rert8f9msffxdl45qyjefw8'
          ),
          Cardano.Address(
            'addr_test1qrrgh4kuq2tlgcpawpta7e7t6dacelhkwh9wm0wzxdx2alv2fa9cu9sfmxem2d2jyzdukjh43dxh84elp9y64da67zvsasy6xs'
          ),
          Cardano.Address(
            'addr_test1qrrgh4kuq2tlgcpawpta7e7t6dacelhkwh9wm0wzxdx2alv2fa9cu9sfmxem2d2jyzdukjh43dxh84elp9y64da67zvsasy6xs'
          )
        ];
        try {
          await axios.post(
            `${baseUrl}${url}`,
            { addresses, pagination: { limit: 5, startAt: 0 } },
            { headers: { 'Content-Type': APPLICATION_JSON } }
          );
        } catch (error: any) {
          expect(error.response.status).toBe(400);
          expect(error.message).toBe(BAD_REQUEST);
        }
      });

      describe('server and snapshot testing', () => {
        it('finds transactions with address within inputs', async () => {
          const addresses: Cardano.Address[] = [
            Cardano.Address(
              'addr_test1qq7rv7r27wq5nz2q6htul8k55xrcjsz2tpxkhqfk5f6kfgfnqdurhe3e8zlltj63kwh78hg7ykrexmn6jxxn42egzs4skzyvvc'
            )
          ];
          const response = await provider.transactionsByAddresses({ addresses, pagination: { limit: 5, startAt: 0 } });
          expect(response.pageResults).toHaveLength(1);
          expect(response).toMatchSnapshot();
        });

        it('finds transactions with address within outputs', async () => {
          const addresses: Cardano.Address[] = [
            Cardano.Address('addr_test1wphyve8r76kvfr5yn6k0fcmq0mn2uf6c6mvtsrafmr7awcg0vnzpg'),
            Cardano.Address(
              'addr_test1qpcnmvyjmxmsm75f747u566gw7ewz4mesdw7yl278uf9r3f5l7d7dpx2ymfwlm3e56flupga8yamjr2kwdt7dw77ktyqqtx2r7'
            ),
            Cardano.Address(
              'addr_test1qr4m502gr9hnaxac5mxjln22jwavf7pcjmh9sw7fujdvgvj9ef6afquphwg7tj4mmm548m3t50hxfyygjuu222kx96eshcathg'
            )
          ];
          const firstPageResponse = await provider.transactionsByAddresses({
            addresses,
            pagination: { limit: 5, startAt: 0 }
          });
          const secondPageResponse = await provider.transactionsByAddresses({
            addresses,
            pagination: { limit: 5, startAt: 5 }
          });
          const thirdPageResponse = await provider.transactionsByAddresses({
            addresses,
            pagination: { limit: 5, startAt: 10 }
          });
          const firstTx = firstPageResponse.pageResults[0];

          expect(secondPageResponse.pageResults.includes(firstTx)).toEqual(false);
          expect(thirdPageResponse.pageResults.includes(firstTx)).toEqual(false);

          expect(firstPageResponse.totalResultCount).toEqual(12);
          expect(firstPageResponse.pageResults).toHaveLength(5);
          expect(secondPageResponse.pageResults).toHaveLength(5);
          expect(thirdPageResponse.pageResults).toHaveLength(2);

          expect(firstPageResponse).toMatchSnapshot();
          expect(secondPageResponse).toMatchSnapshot();
          expect(thirdPageResponse).toMatchSnapshot();
        });

        it('does not include transactions before indicated block', async () => {
          const addresses: Cardano.Address[] = [
            Cardano.Address(
              'addr_test1qr4m502gr9hnaxac5mxjln22jwavf7pcjmh9sw7fujdvgvj9ef6afquphwg7tj4mmm548m3t50hxfyygjuu222kx96eshcathg'
            ),
            Cardano.Address(
              'addr_test1qrrgh4kuq2tlgcpawpta7e7t6dacelhkwh9wm0wzxdx2alv2fa9cu9sfmxem2d2jyzdukjh43dxh84elp9y64da67zvsasy6xs'
            )
          ];
          const response = await provider.transactionsByAddresses({
            addresses,
            blockRange: { lowerBound: 1_654_555 },
            pagination: { limit: 5, startAt: 0 }
          });

          expect(response.pageResults).toHaveLength(2);
          expect(response).toMatchSnapshot();
        });
      });
    });
  });
});
