import { AssetBuilder } from '../../src';
import { AssetFixtureBuilder, AssetWith } from './fixtures/FixtureBuilder';
import { Cardano } from '@cardano-sdk/core';
import { Pool } from 'pg';
import { logger } from '@cardano-sdk/util-dev';

const notValidAssetName = Cardano.AssetName('89abcdef');
const notValidPolicyId = Cardano.PolicyId('0123456789abcdef0123456789abcdef0123456789abcdef01234567');

describe('AssetBuilder', () => {
  let db: Pool;
  let builder: AssetBuilder;
  let fixtureBuilder: AssetFixtureBuilder;

  beforeAll(async () => {
    db = new Pool({ connectionString: process.env.LOCALNETWORK_INTEGRAION_TESTS_POSTGRES_CONNECTION_STRING });
    builder = new AssetBuilder(db, logger);
    fixtureBuilder = new AssetFixtureBuilder(db, logger);
  });

  afterAll(async () => {
    await db.end();
  });

  describe('queryLastMintTx', () => {
    test('query last Mint transaction', async () => {
      const assets = await fixtureBuilder.getAssets(1, { with: [AssetWith.CIP25Metadata] });
      const lastMintTx = await fixtureBuilder.queryLastMintTx(assets[0].policyId, assets[0].name);
      const result = await builder.queryLastMintTx(assets[0].policyId, assets[0].name);
      expect(result.tx_hash).toEqual(lastMintTx.tx_hash);
    });
    test('return undefined when not found', async () => {
      const result = await builder.queryLastMintTx(notValidPolicyId, notValidAssetName);
      expect(result).toBeUndefined();
    });
  });

  describe('queryMultiAsset', () => {
    test('query multi_asset', async () => {
      const assets = await fixtureBuilder.getAssets(1, { with: [AssetWith.CIP25Metadata] });
      const ma = await builder.queryMultiAsset(assets[0].policyId, assets[0].name);
      expect(ma.fingerprint).toEqual(Cardano.AssetFingerprint.fromParts(assets[0].policyId, assets[0].name).toString());
      expect(ma).toMatchShapeOf({
        fingerprint: '50fdcdbfa3154db86a87e4b5697ae30d272e0bbcfa8122efd3e301cb6d616361726f6e2d63616b65',
        id: '590675'
      });
    });
    test('return undefined when not found', async () => {
      const result = await builder.queryMultiAsset(notValidPolicyId, notValidAssetName);
      expect(result).toBeUndefined();
    });
  });

  describe('queryMultiAssetHistory', () => {
    test('query multi_asset transactions history', async () => {
      const assets = await fixtureBuilder.getAssets(1);
      const history = await fixtureBuilder.getHistory(assets[0].policyId, assets[0].name);
      const result = await builder.queryMultiAssetHistory(assets[0].policyId, assets[0].name);
      expect(result[0].quantity).toEqual(history[0].quantity.toString());
      expect(result[0].hash).toEqual(Buffer.from(history[0].transactionId, 'hex'));
    });

    test('return empty array when not found', async () => {
      const result = await builder.queryMultiAssetHistory(notValidPolicyId, notValidAssetName);
      expect(result).toStrictEqual([]);
    });
  });

  describe('queryMultiAssetQuantities', () => {
    test('query multi_asset', async () => {
      const result = await builder.queryMultiAssetQuantities('1');
      expect(result).toMatchShapeOf({ count: '1', sum: '1' });
    });
    test('return the record with empty data when not found', async () => {
      const result = await builder.queryMultiAssetQuantities('9999999');
      expect(result).toMatchShapeOf({ count: '0', sum: null });
    });
  });
});
