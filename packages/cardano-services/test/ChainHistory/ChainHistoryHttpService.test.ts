/* eslint-disable sonarjs/no-identical-functions */
/* eslint-disable sonarjs/no-duplicate-string */
/* eslint-disable max-len */
/* eslint-disable @typescript-eslint/no-explicit-any */
import {
  Cardano,
  ChainHistoryProvider,
  ProviderError,
  ProviderFailure,
  TransactionsByAddressesArgs,
  util
} from '@cardano-sdk/core';
import { ChainHistoryHttpService, DbSyncChainHistoryProvider, HttpServer, HttpServerConfig } from '../../src';
import { Pool } from 'pg';
import { chainHistoryHttpProvider } from '@cardano-sdk/cardano-services-client';
import { doServerRequest } from '../util';
import { getPort } from 'get-port-please';
import axios from 'axios';

const UNSUPPORTED_MEDIA_STRING = 'Request failed with status code 415';
const APPLICATION_CBOR = 'application/cbor';
const APPLICATION_JSON = 'application/json';

describe('ChainHistoryHttpService', () => {
  let dbConnection: Pool;
  let httpServer: HttpServer;
  let chainHistoryProvider: DbSyncChainHistoryProvider;
  let service: ChainHistoryHttpService;
  let port: number;
  let apiUrlBase: string;
  let config: HttpServerConfig;
  let doChainHistoryRequest: ReturnType<typeof doServerRequest>;

  beforeAll(async () => {
    port = await getPort();
    apiUrlBase = `http://localhost:${port}/chain-history`;
    config = { listen: { port } };
    dbConnection = new Pool({ connectionString: process.env.DB_CONNECTION_STRING });
    doChainHistoryRequest = doServerRequest(apiUrlBase);
  });

  afterEach(async () => {
    jest.resetAllMocks();
  });

  describe('unhealthy ChainHistoryProvider', () => {
    beforeAll(async () => {
      chainHistoryProvider = {
        healthCheck: jest.fn(() => Promise.resolve({ ok: false }))
      } as unknown as DbSyncChainHistoryProvider;
    });

    it('throws during initialization if the ChainHistoryProvider is unhealthy', async () => {
      await expect(() => ChainHistoryHttpService.create({ chainHistoryProvider })).rejects.toThrow(
        new ProviderError(ProviderFailure.Unhealthy)
      );
    });
  });

  describe('healthy state', () => {
    beforeAll(async () => {
      chainHistoryProvider = new DbSyncChainHistoryProvider(dbConnection);
      service = await ChainHistoryHttpService.create({ chainHistoryProvider });
      httpServer = new HttpServer(config, { services: [service] });
      await httpServer.initialize();
      await httpServer.start();
    });

    afterAll(async () => {
      await dbConnection.end();
      await httpServer.shutdown();
    });

    describe('/health', () => {
      const url = '/health';
      it('forwards the ChainHistoryProvider health response', async () => {
        const res = await axios.post(`${apiUrlBase}${url}`, undefined, {
          headers: { 'Content-Type': APPLICATION_JSON }
        });
        expect(res.status).toBe(200);
        expect(res.data).toEqual({ ok: true });
      });
    });

    describe('/blocks/by-hashes', () => {
      const url = '/blocks/by-hashes';
      it('returns a 200 coded response with a well formed HTTP request', async () => {
        expect((await axios.post(`${apiUrlBase}${url}`, { args: [[]] })).status).toEqual(200);
      });

      it('returns a 415 coded response if the wrong content type header is used', async () => {
        try {
          await axios.post(`${apiUrlBase}${url}`, { args: [[]] }, { headers: { 'Content-Type': APPLICATION_CBOR } });
          throw new Error('fail');
        } catch (error: any) {
          expect(error.response.status).toBe(415);
          expect(error.message).toBe(UNSUPPORTED_MEDIA_STRING);
        }
      });

      describe('with ChainHistoryProvider', () => {
        let provider: ChainHistoryProvider;
        beforeEach(() => {
          provider = chainHistoryHttpProvider(apiUrlBase);
        });

        it('returns an array of blocks', async () => {
          const hashes: Cardano.BlockId[] = [
            Cardano.BlockId('7a48b034645f51743550bbaf81f8a14771e58856e031eb63844738ca8ad72298'),
            Cardano.BlockId('469cc6fbcc186de6b12c392ad0cc84a20c4d4774c1f9c3cfd80745de00856f4b')
          ];
          const response = await provider.blocksByHashes(hashes);
          expect(response).toHaveLength(2);
        });

        it('does not include blocks not found', async () => {
          const hashes: Cardano.BlockId[] = [
            Cardano.BlockId('7a48b034645f51743550bbaf81f8a14771e58856e031eb63844738ca8ad72298'),
            Cardano.BlockId('0000000000000000000000000000000000000000000000000000000000000000')
          ];
          const response = await provider.blocksByHashes(hashes);
          expect(response).toHaveLength(1);
        });
      });

      describe('server and snapshot testing', () => {
        it('has all block information', async () => {
          const hashes: Cardano.BlockId[] = [
            Cardano.BlockId('7a48b034645f51743550bbaf81f8a14771e58856e031eb63844738ca8ad72298'),
            Cardano.BlockId('469cc6fbcc186de6b12c392ad0cc84a20c4d4774c1f9c3cfd80745de00856f4b')
          ];
          const response = await doChainHistoryRequest<[Cardano.BlockId[]], Cardano.Block[]>(url, [hashes]);
          expect(response.length).toEqual(2);
          expect(response).toMatchSnapshot();
        });
      });
    });

    describe('/txs/by-hashes', () => {
      const url = '/txs/by-hashes';
      it('returns a 200 coded response with a well formed HTTP request', async () => {
        expect((await axios.post(`${apiUrlBase}${url}`, { args: [[]] })).status).toEqual(200);
      });

      it('returns a 415 coded response if the wrong content type header is used', async () => {
        try {
          await axios.post(`${apiUrlBase}${url}`, { args: [[]] }, { headers: { 'Content-Type': APPLICATION_CBOR } });
          throw new Error('fail');
        } catch (error: any) {
          expect(error.response.status).toBe(415);
          expect(error.message).toBe(UNSUPPORTED_MEDIA_STRING);
        }
      });

      describe('with ChainHistoryProvider', () => {
        let provider: ChainHistoryProvider;
        beforeEach(() => {
          provider = chainHistoryHttpProvider(apiUrlBase);
        });

        it('returns an array of transactions', async () => {
          const hashes: Cardano.TransactionId[] = [
            Cardano.TransactionId('cefd2fcf657e5e5d6c35975f4e052f427819391b153ebb16ad8aa107ba5a3819'),
            Cardano.TransactionId('952dfa431223fd671c5e9e048e016f70fcebd9e41fcb726969415ff692736eeb'),
            Cardano.TransactionId('cb66e0f5778718f8bfcfd043712f37d9993f4703b254a7a4d954d34225fe2f99'),
            Cardano.TransactionId('24e75c64a309fd8fb400933795b2522ca818cba80a3838c2ff14cec2cc8ffe4e'),
            Cardano.TransactionId('3d2278e9cef71c79720a11bc3e08acbbd5f2175f7015d358c867fc9b419ae0b2'),
            Cardano.TransactionId('5acd6efb1b66299f1c5a2c4221af4bcaa4ba9929e8e6aa0e3f48707fa1796fc3'),
            Cardano.TransactionId('face165bd7aa8d0d661cf1ceaa4e35d7611be3b1c7997da378c547aa2464a4fd'),
            Cardano.TransactionId('19251f57476d7af2777252270413c01383d9503110a68b4fde1a239c119c4f5d')
          ];
          const response = await provider.transactionsByHashes(hashes);
          expect(response).toHaveLength(8);
        });

        it('does not include transactions not found', async () => {
          const hashes: Cardano.TransactionId[] = [
            Cardano.TransactionId('295d5e0f7ee182426eaeda8c9f1c63502c72cdf4afd6e0ee0f209adf94a614e7'),
            Cardano.TransactionId('0000000000000000000000000000000000000000000000000000000000000000')
          ];
          const response = await provider.transactionsByHashes(hashes);
          expect(response.length).toEqual(1);
        });
      });

      describe('server and snapshot testing', () => {
        it('has outputs with multi-assets', async () => {
          const hashes: Cardano.TransactionId[] = [
            Cardano.TransactionId('cefd2fcf657e5e5d6c35975f4e052f427819391b153ebb16ad8aa107ba5a3819')
          ];
          const response = await doChainHistoryRequest<[Cardano.TransactionId[]], Cardano.TxAlonzo[]>(url, [hashes]);
          const tx: Cardano.TxAlonzo = util.fromSerializableObject(response[0]);
          expect(response.length).toEqual(1);
          expect(tx.body.outputs[0].value.assets?.size).toBeGreaterThan(0);
          expect(response).toMatchSnapshot();
        });

        it('has mint operations', async () => {
          const hashes: Cardano.TransactionId[] = [
            Cardano.TransactionId('952dfa431223fd671c5e9e048e016f70fcebd9e41fcb726969415ff692736eeb')
          ];
          const response = await doChainHistoryRequest<[Cardano.TransactionId[]], Cardano.TxAlonzo[]>(url, [hashes]);
          const tx: Cardano.TxAlonzo = util.fromSerializableObject(response[0]);
          expect(response.length).toEqual(1);
          expect(response).toMatchSnapshot();
          expect(tx.body.mint?.size).toBeGreaterThan(0);
        });

        it('has withdrawals', async () => {
          const hashes: Cardano.TransactionId[] = [
            Cardano.TransactionId('cb66e0f5778718f8bfcfd043712f37d9993f4703b254a7a4d954d34225fe2f99')
          ];
          const response = await doChainHistoryRequest<[Cardano.TransactionId[]], Cardano.TxAlonzo[]>(url, [hashes]);
          const tx: Cardano.TxAlonzo = util.fromSerializableObject(response[0]);
          expect(response.length).toEqual(1);
          expect(response).toMatchSnapshot();
          expect(tx.body.withdrawals?.length).toBeGreaterThan(0);
        });

        it('has redeemers', async () => {
          const hashes: Cardano.TransactionId[] = [
            Cardano.TransactionId('24e75c64a309fd8fb400933795b2522ca818cba80a3838c2ff14cec2cc8ffe4e')
          ];
          const response = await doChainHistoryRequest<[Cardano.TransactionId[]], Cardano.TxAlonzo[]>(url, [hashes]);
          const tx: Cardano.TxAlonzo = util.fromSerializableObject(response[0]);
          expect(response.length).toEqual(1);
          expect(response).toMatchSnapshot();
          expect(tx.witness.redeemers?.length).toBeGreaterThan(0);
        });

        it('has auxiliary data', async () => {
          const hashes: Cardano.TransactionId[] = [
            Cardano.TransactionId('3d2278e9cef71c79720a11bc3e08acbbd5f2175f7015d358c867fc9b419ae0b2')
          ];
          const response = await doChainHistoryRequest<[Cardano.TransactionId[]], Cardano.TxAlonzo[]>(url, [hashes]);
          const tx: Cardano.TxAlonzo = util.fromSerializableObject(response[0]);
          expect(response.length).toEqual(1);
          expect(response).toMatchSnapshot();
          expect(tx.auxiliaryData).toBeDefined();
        });

        it('has collateral inputs', async () => {
          const hashes: Cardano.TransactionId[] = [
            Cardano.TransactionId('5acd6efb1b66299f1c5a2c4221af4bcaa4ba9929e8e6aa0e3f48707fa1796fc3')
          ];
          const response = await doChainHistoryRequest<[Cardano.TransactionId[]], Cardano.TxAlonzo[]>(url, [hashes]);
          const tx: Cardano.TxAlonzo = util.fromSerializableObject(response[0]);
          expect(response.length).toEqual(1);
          expect(response).toMatchSnapshot();
          expect(tx.body.collaterals?.length).toBeGreaterThan(0);
        });

        it('has certificates', async () => {
          const hashes: Cardano.TransactionId[] = [
            Cardano.TransactionId('face165bd7aa8d0d661cf1ceaa4e35d7611be3b1c7997da378c547aa2464a4fd'),
            Cardano.TransactionId('19251f57476d7af2777252270413c01383d9503110a68b4fde1a239c119c4f5d')
          ];
          const response = await doChainHistoryRequest<[Cardano.TransactionId[]], Cardano.TxAlonzo[]>(url, [hashes]);
          const tx1: Cardano.TxAlonzo = util.fromSerializableObject(response[0]);
          const tx2: Cardano.TxAlonzo = util.fromSerializableObject(response[1]);
          expect(response.length).toEqual(2);
          expect(response).toMatchSnapshot();
          expect(tx1.body.certificates?.length).toBeGreaterThan(0);
          expect(tx2.body.certificates?.length).toBeGreaterThan(0);
        });
      });
    });

    describe('/txs/by-addresses', () => {
      const url = '/txs/by-addresses';
      it('returns a 200 coded response with a well formed HTTP request', async () => {
        expect((await axios.post(`${apiUrlBase}${url}`, { args: [{ addresses: [] }] })).status).toEqual(200);
      });

      it('returns a 415 coded response if the wrong content type header is used', async () => {
        try {
          await axios.post(`${apiUrlBase}${url}`, { args: [[]] }, { headers: { 'Content-Type': APPLICATION_CBOR } });
          throw new Error('fail');
        } catch (error: any) {
          expect(error.response.status).toBe(415);
          expect(error.message).toBe(UNSUPPORTED_MEDIA_STRING);
        }
      });

      describe('with ChainHistoryProvider', () => {
        let provider: ChainHistoryProvider;
        beforeEach(() => {
          provider = chainHistoryHttpProvider(apiUrlBase);
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
          const response = await provider.transactionsByAddresses({ addresses });
          expect(response).toHaveLength(3);
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
          const response = await provider.transactionsByAddresses({ addresses });
          expect(response).toHaveLength(1);
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
          const response = await provider.transactionsByAddresses({ addresses, sinceBlock: 1_654_555 });
          expect(response).toHaveLength(2);
        });
      });

      describe('server and snapshot testing', () => {
        it('finds transactions with address within inputs', async () => {
          const addresses: Cardano.Address[] = [
            Cardano.Address(
              'addr_test1qq7rv7r27wq5nz2q6htul8k55xrcjsz2tpxkhqfk5f6kfgfnqdurhe3e8zlltj63kwh78hg7ykrexmn6jxxn42egzs4skzyvvc'
            )
          ];
          const response = await doChainHistoryRequest<[TransactionsByAddressesArgs], Cardano.TxAlonzo[]>(url, [
            { addresses }
          ]);
          expect(response).toHaveLength(1);
          expect(response).toMatchSnapshot();
        });

        it('finds transactions with address within outputs', async () => {
          const addresses: Cardano.Address[] = [
            Cardano.Address('addr_test1wphyve8r76kvfr5yn6k0fcmq0mn2uf6c6mvtsrafmr7awcg0vnzpg')
          ];
          const response = await doChainHistoryRequest<[TransactionsByAddressesArgs], Cardano.TxAlonzo[]>(url, [
            { addresses }
          ]);
          expect(response).toHaveLength(11);
          expect(response).toMatchSnapshot();
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
          const response = await doChainHistoryRequest<[TransactionsByAddressesArgs], Cardano.TxAlonzo[]>(url, [
            { addresses, sinceBlock: 1_654_555 }
          ]);
          expect(response.length).toEqual(2);
          expect(response).toMatchSnapshot();
        });
      });
    });
  });
});
