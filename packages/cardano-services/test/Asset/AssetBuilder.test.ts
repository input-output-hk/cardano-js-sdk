import { AssetBuilder } from '../../src/index.js';
import { AssetFixtureBuilder, AssetWith } from './fixtures/FixtureBuilder.js';
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
    db = new Pool({ connectionString: process.env.POSTGRES_CONNECTION_STRING_DB_SYNC });
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
      expect(() => Cardano.TransactionId(lastMintTx.tx_hash.toString('hex'))).not.toThrow();

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

      expect(() => Cardano.AssetFingerprint(ma.fingerprint)).not.toThrow();
      expect(ma.fingerprint).toEqual(Cardano.AssetFingerprint.fromParts(assets[0].policyId, assets[0].name));
      expect(ma).toMatchShapeOf({
        count: '123',
        fingerprint: '50fdcdbfa3154db86a87e4b5697ae30d272e0bbcfa8122efd3e301cb6d616361726f6e2d63616b65',
        sum: '42'
      });
    });
    test('return undefined when not found', async () => {
      const result = await builder.queryMultiAsset(notValidPolicyId, notValidAssetName);
      expect(result).toBeUndefined();
    });
  });
});
