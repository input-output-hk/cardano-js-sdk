import { Cardano } from '@cardano-sdk/core';
import { ChainHistoryBuilder } from '../../../src';
import { Pool } from 'pg';

describe('ChainHistoryBuilder', () => {
  let dbConnection: Pool;
  let builder: ChainHistoryBuilder;

  beforeAll(async () => {
    dbConnection = new Pool({ connectionString: process.env.DB_CONNECTION_STRING });
    builder = new ChainHistoryBuilder(dbConnection);
  });

  afterAll(async () => {
    await dbConnection.end();
  });

  describe('queryTransactionInputsByHashes', () => {
    test('query transaction inputs by tx hashes', async () => {
      const result = await builder.queryTransactionInputsByHashes([
        Cardano.TransactionId('cefd2fcf657e5e5d6c35975f4e052f427819391b153ebb16ad8aa107ba5a3819'),
        Cardano.TransactionId('952dfa431223fd671c5e9e048e016f70fcebd9e41fcb726969415ff692736eeb')
      ]);
      expect(result).toHaveLength(2);
      expect(result).toMatchSnapshot();
    });
    test('query transaction inputs with empty array', async () => {
      const result = await builder.queryTransactionInputsByHashes([]);
      expect(result).toHaveLength(0);
    });
    test('query transaction inputs when tx hashes not found', async () => {
      const result = await builder.queryTransactionInputsByHashes([
        Cardano.TransactionId('0000000000000000000000000000000000000000000000000000000000000000')
      ]);
      expect(result).toHaveLength(0);
    });

    describe('with collateral true', () => {
      test('query transaction collateral inputs by tx hashes', async () => {
        const result = await builder.queryTransactionInputsByHashes(
          [
            Cardano.TransactionId('5acd6efb1b66299f1c5a2c4221af4bcaa4ba9929e8e6aa0e3f48707fa1796fc3'),
            Cardano.TransactionId('24e75c64a309fd8fb400933795b2522ca818cba80a3838c2ff14cec2cc8ffe4e')
          ],
          true
        );
        expect(result).toHaveLength(2);
        expect(result).toMatchSnapshot();
      });
      test('query transaction collateral inputs when tx not found or does not have any ', async () => {
        const result = await builder.queryTransactionInputsByHashes(
          [
            Cardano.TransactionId('295d5e0f7ee182426eaeda8c9f1c63502c72cdf4afd6e0ee0f209adf94a614e7'),
            Cardano.TransactionId('0000000000000000000000000000000000000000000000000000000000000000')
          ],
          true
        );
        expect(result).toHaveLength(0);
      });
    });
  });

  describe('queryTransactionOutputsByHashes', () => {
    test('query transaction outputs by tx hashes', async () => {
      const result = await builder.queryTransactionOutputsByHashes([
        Cardano.TransactionId('cefd2fcf657e5e5d6c35975f4e052f427819391b153ebb16ad8aa107ba5a3819'),
        Cardano.TransactionId('952dfa431223fd671c5e9e048e016f70fcebd9e41fcb726969415ff692736eeb')
      ]);
      expect(result).toHaveLength(4);
      expect(result).toMatchSnapshot();
    });
    test('query transaction outputs with empty array', async () => {
      const result = await builder.queryTransactionOutputsByHashes([]);
      expect(result).toHaveLength(0);
    });
    test('query transaction outputs when tx hashes not found', async () => {
      const result = await builder.queryTransactionOutputsByHashes([
        Cardano.TransactionId('0000000000000000000000000000000000000000000000000000000000000000')
      ]);
      expect(result).toHaveLength(0);
    });
  });

  describe('queryMultiAssetsByTxOut', () => {
    test('query multi assets by tx output', async () => {
      const result = await builder.queryMultiAssetsByTxOut([5_396_853n, 5_396_911n, 5_396_912n]);
      expect(result.size).toEqual(3);
      expect(result).toMatchSnapshot();
    });
    test('query multi assets with empty array', async () => {
      const result = await builder.queryMultiAssetsByTxOut([]);
      expect(result.size).toEqual(0);
    });
    test('query multi assets when tx output not found or has no multi-assets', async () => {
      const result = await builder.queryMultiAssetsByTxOut([0n, 5_396_852n]);
      expect(result.size).toEqual(0);
    });
  });

  describe('queryTxMintByHashes', () => {
    test('query transaction mint by tx hashes', async () => {
      const result = await builder.queryTxMintByHashes([
        Cardano.TransactionId('24e75c64a309fd8fb400933795b2522ca818cba80a3838c2ff14cec2cc8ffe4e'),
        Cardano.TransactionId('952dfa431223fd671c5e9e048e016f70fcebd9e41fcb726969415ff692736eeb')
      ]);
      expect(result.size).toEqual(2);
      expect(result).toMatchSnapshot();
    });
    test('query transaction mint with empty array', async () => {
      const result = await builder.queryTxMintByHashes([]);
      expect(result.size).toEqual(0);
    });
    test('query transaction mint when tx not found or has no mint operations', async () => {
      const result = await builder.queryTxMintByHashes([
        Cardano.TransactionId('0000000000000000000000000000000000000000000000000000000000000000'),
        Cardano.TransactionId('cefd2fcf657e5e5d6c35975f4e052f427819391b153ebb16ad8aa107ba5a3819')
      ]);
      expect(result.size).toEqual(0);
    });
  });

  describe('queryWithdrawalsByHashes', () => {
    test('query transaction withdrawals by tx hashes', async () => {
      const result = await builder.queryWithdrawalsByHashes([
        Cardano.TransactionId('cb66e0f5778718f8bfcfd043712f37d9993f4703b254a7a4d954d34225fe2f99')
      ]);
      expect(result.size).toEqual(1);
      expect(result).toMatchSnapshot();
    });
    test('query transaction withdrawals with empty array', async () => {
      const result = await builder.queryWithdrawalsByHashes([]);
      expect(result.size).toEqual(0);
    });
    test('query transaction withdrawals when tx not found or has no withdrawals', async () => {
      const result = await builder.queryWithdrawalsByHashes([
        Cardano.TransactionId('0000000000000000000000000000000000000000000000000000000000000000'),
        Cardano.TransactionId('cefd2fcf657e5e5d6c35975f4e052f427819391b153ebb16ad8aa107ba5a3819')
      ]);
      expect(result.size).toEqual(0);
    });
  });

  describe('queryRedeemersByHashes', () => {
    test('query transaction redeemers by tx hashes', async () => {
      const result = await builder.queryRedeemersByHashes([
        Cardano.TransactionId('5acd6efb1b66299f1c5a2c4221af4bcaa4ba9929e8e6aa0e3f48707fa1796fc3'),
        Cardano.TransactionId('24e75c64a309fd8fb400933795b2522ca818cba80a3838c2ff14cec2cc8ffe4e')
      ]);
      expect(result.size).toEqual(2);
      expect(result).toMatchSnapshot();
    });
    test('query transaction redeemers with empty array', async () => {
      const result = await builder.queryRedeemersByHashes([]);
      expect(result.size).toEqual(0);
    });
    test('query transaction redeemers when tx not found or has no redeemers', async () => {
      const result = await builder.queryRedeemersByHashes([
        Cardano.TransactionId('0000000000000000000000000000000000000000000000000000000000000000'),
        Cardano.TransactionId('cefd2fcf657e5e5d6c35975f4e052f427819391b153ebb16ad8aa107ba5a3819')
      ]);
      expect(result.size).toEqual(0);
    });
  });

  describe('queryTxMetadataByHashes', () => {
    test('query transaction metadata by tx hashes', async () => {
      const result = await builder.queryTxMetadataByHashes([
        Cardano.TransactionId('3d2278e9cef71c79720a11bc3e08acbbd5f2175f7015d358c867fc9b419ae0b2'),
        Cardano.TransactionId('545c4656544054045f5a4db0e962f6b09fc6d98b0303d42f3f006e3d920d3720')
      ]);
      expect(result.size).toEqual(2);
      expect(result).toMatchSnapshot();
    });
    test('query transaction metadata with empty array', async () => {
      const result = await builder.queryTxMetadataByHashes([]);
      expect(result.size).toEqual(0);
    });
    test('query transaction metadata when tx not found or has no metadata', async () => {
      const result = await builder.queryTxMetadataByHashes([
        Cardano.TransactionId('0000000000000000000000000000000000000000000000000000000000000000')
      ]);
      expect(result.size).toEqual(0);
    });
  });

  describe('queryProtocolParams', () => {
    test('query protocol parameters from last epoch', async () => {
      const result = await builder.queryProtocolParams();
      expect(result).toMatchSnapshot();
    });
  });

  describe('queryCertificatesByHashes', () => {
    test('query certificates by tx hashes', async () => {
      const result = await builder.queryCertificatesByHashes([
        Cardano.TransactionId('face165bd7aa8d0d661cf1ceaa4e35d7611be3b1c7997da378c547aa2464a4fd'),
        Cardano.TransactionId('19251f57476d7af2777252270413c01383d9503110a68b4fde1a239c119c4f5d'),
        Cardano.TransactionId('295d5e0f7ee182426eaeda8c9f1c63502c72cdf4afd6e0ee0f209adf94a614e7'),
        Cardano.TransactionId('68f21b8c6a8ae2c09839a00c908ba79bc81ffde240720f72589f842619915085'),
        Cardano.TransactionId('24986c0cd3475419bfb44756c27a0e13a6354a4071153f76a78f9b2d1e596089')
      ]);
      expect(result.size).toEqual(5);
      expect(result).toMatchSnapshot();
    });
    test('query certificates with empty array', async () => {
      const result = await builder.queryCertificatesByHashes([]);
      expect(result.size).toEqual(0);
    });
    test('query certificates when tx not found or has not certificates', async () => {
      const result = await builder.queryCertificatesByHashes([
        Cardano.TransactionId('0000000000000000000000000000000000000000000000000000000000000000'),
        Cardano.TransactionId('cefd2fcf657e5e5d6c35975f4e052f427819391b153ebb16ad8aa107ba5a3819')
      ]);
      expect(result.size).toEqual(0);
    });
  });
});
