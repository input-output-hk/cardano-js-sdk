import { AssetBuilder } from '../../src/Asset';
import { Cardano } from '@cardano-sdk/core';
import { Pool } from 'pg';
import { logger } from '@cardano-sdk/util-dev';

const notValidAssetName = Cardano.AssetName('89abcdef');
const notValidPolicyId = Cardano.PolicyId('0123456789abcdef0123456789abcdef0123456789abcdef01234567');
const validAssetName = Cardano.AssetName('6d616361726f6e2d63616b65');
const validPolicyId = Cardano.PolicyId('50fdcdbfa3154db86a87e4b5697ae30d272e0bbcfa8122efd3e301cb');

describe('AssetBuilder', () => {
  let db: Pool;
  let builder: AssetBuilder;

  beforeAll(async () => {
    db = new Pool({ connectionString: process.env.POSTGRES_CONNECTION_STRING });
    builder = new AssetBuilder(db, logger);
  });

  afterAll(async () => {
    await db.end();
  });

  describe('queryLastMintTx', () => {
    test('query last Mint transaction', async () => {
      const result = await builder.queryLastMintTx(validPolicyId, validAssetName);
      expect(result).toMatchSnapshot();
      expect(result.tx_hash.toString('hex')).toEqual(
        'f66791a0354c43d8c5a93671eb96d94633e3419f3ccbb0a00c00a152d3b6ca06'
      );
    });
    test('return undefined when not found', async () => {
      const result = await builder.queryLastMintTx(notValidPolicyId, notValidAssetName);
      expect(result).toMatchSnapshot();
      expect(result).toBeUndefined();
    });
  });

  describe('queryMultiAsset', () => {
    test('query multi_asset', async () => {
      const result = await builder.queryMultiAsset(validPolicyId, validAssetName);
      expect(result).toMatchSnapshot();
      expect(result).toEqual({ fingerprint: 'asset1f0azzptnr8dghzjh7egqvdjmt33e3lz5uy59th', id: '590675' });
    });
    test('return undefined when not found', async () => {
      const result = await builder.queryMultiAsset(notValidPolicyId, notValidAssetName);
      expect(result).toMatchSnapshot();
      expect(result).toBeUndefined();
    });
  });

  describe('queryMultiAssetHistory', () => {
    test('query multi_asset transactions history', async () => {
      const result = await builder.queryMultiAssetHistory(validPolicyId, validAssetName);
      expect(result).toMatchSnapshot();
      expect(result[0].quantity).toEqual('1');
      expect(result[0].hash.toString('hex')).toEqual(
        'f66791a0354c43d8c5a93671eb96d94633e3419f3ccbb0a00c00a152d3b6ca06'
      );
    });
    test('return empty array when not found', async () => {
      const result = await builder.queryMultiAssetHistory(notValidPolicyId, notValidAssetName);
      expect(result).toMatchSnapshot();
      expect(result).toStrictEqual([]);
    });
  });

  describe('queryMultiAssetQuantities', () => {
    test('query multi_asset', async () => {
      const result = await builder.queryMultiAssetQuantities('590675');
      expect(result).toMatchSnapshot();
      expect(result).toEqual({ count: '1', sum: '1' });
    });
    test('return the record with empty data when not found', async () => {
      const result = await builder.queryMultiAssetQuantities('590676');
      expect(result).toMatchSnapshot();
      expect(result).toEqual({ count: '0', sum: null });
    });
  });
});
