import { DataMocks } from '../data-mocks/index.js';
import { NotImplementedError, ProviderError, ProviderFailure } from '@cardano-sdk/core';
import { PoolMetadataEntity, PoolRegistrationEntity } from '@cardano-sdk/projection-typeorm';
import { StakePoolMetadataFetchMode } from '../../src/Program/options/index.js';
import {
  attachExtendedMetadata,
  getUrlToFetch,
  isUpdateOutdated,
  savePoolMetadata
} from '../../src/PgBoss/stakePoolMetadataHandler.js';
import { initHandlerTest, poolId } from './util.js';
import type { Cardano } from '@cardano-sdk/core';
import type { DataSource } from 'typeorm';
import type { Hash32ByteBase16 } from '@cardano-sdk/crypto';
import type { Pool } from 'pg';

describe('stakePoolMetadataHandler', () => {
  const rewardAccount = 'test_addr';
  const vrf = 'test_vfr';

  let dataSource: DataSource;
  let db: Pool;

  beforeAll(async () => {
    const testData = await initHandlerTest();
    const { block, stakePool } = testData;
    ({ dataSource, db } = testData);

    const registrationRepos = dataSource.getRepository(PoolRegistrationEntity);
    const registration1 = {
      block,
      cost: 0,
      id: '23',
      margin: {},
      marginPercent: 1,
      owners: [],
      pledge: 500_000,
      relays: [],
      rewardAccount,
      stakePool,
      vrf
    };
    const registration2 = {
      ...registration1,
      id: '42',
      pledge: 1_000_000
    };

    await registrationRepos.insert(registration1);
    await registrationRepos.insert(registration2);
  });

  afterAll(() => Promise.all([db.end(), dataSource.destroy()]));

  describe('isUpdateOutdated', () => {
    it('returns true if there is a newer pool update', async () => {
      expect(await isUpdateOutdated(dataSource, poolId, '23')).toBe(true);
    });

    it('returns false if there are no newer pool updates', async () => {
      expect(await isUpdateOutdated(dataSource, poolId, '42')).toBe(false);
    });
  });

  describe('savePoolMetadata', () => {
    const description = 'test pool description';
    const ext = null;
    const homepage = 'https://test.com';
    const name = 'test name';
    const ticker = 'TEST';

    const hash = 'test_pool_hash' as Hash32ByteBase16;
    const metadata = { description, homepage, name, ticker } as Cardano.StakePoolMetadata;

    it('inserts and updates the record', async () => {
      const metadataRepos = dataSource.getRepository(PoolMetadataEntity);
      const poolRegistrationId = '42';
      const poolUpdate = { id: poolRegistrationId as unknown as bigint };

      // No records before insert
      expect(await metadataRepos.find({ where: { poolUpdate } })).toEqual([]);

      // Insert
      await savePoolMetadata({ dataSource, hash, metadata, poolId, poolRegistrationId });

      // One record was inserted
      const insertResult = await metadataRepos.find({ where: { poolUpdate } });
      expect(insertResult).toEqual([{ description, ext, hash, homepage, id: insertResult[0].id, name, ticker }]);

      // Update
      metadata.name = 'updated';
      await savePoolMetadata({ dataSource, hash, metadata, poolId, poolRegistrationId });

      // One record updated and no records inserted
      const updateResult = await metadataRepos.find({ where: { poolUpdate } });
      expect(updateResult).toEqual([
        { description, ext, hash, homepage, id: insertResult[0].id, name: 'updated', ticker }
      ]);
    });

    it('does nothing if registration record does not exist', async () => {
      const metadataRepos = dataSource.getRepository(PoolMetadataEntity);
      const poolRegistrationId = '43';
      const poolUpdate = { id: poolRegistrationId as unknown as bigint };

      // No records before insert attempt
      expect(await metadataRepos.find({ where: { poolUpdate } })).toEqual([]);

      // Failing insert attempt
      await savePoolMetadata({ dataSource, hash, metadata, poolId, poolRegistrationId });

      // No records were inserted
      expect(await metadataRepos.find({ where: { poolUpdate } })).toEqual([]);
    });
  });

  describe('attachExtendedMetadata', () => {
    const metadata = {
      description: 'description',
      homepage: 'homepage',
      name: 'name',
      ticker: 'ticker'
    } as Cardano.StakePoolMetadata;

    it('attaches full extended metadata', async () => {
      const expectedExtendedMetadata = DataMocks.Pool.adaPoolExtendedMetadata;
      const attachedMetadata = attachExtendedMetadata(metadata, expectedExtendedMetadata);

      expect(attachedMetadata).not.toBeNull();
      expect(attachedMetadata).toEqual({ ...metadata, ext: expectedExtendedMetadata });
    });

    it('does not modify the base metadata if an extended metadata reference does not exist', async () => {
      const expectedExtendedMetadata = undefined;
      const attachedMetadata = attachExtendedMetadata(metadata, expectedExtendedMetadata);

      expect(attachedMetadata).not.toBeNull();
      expect(attachedMetadata).toEqual(metadata);
    });

    it('attaches extended metadata as undefined if a connection failure occurs', async () => {
      const error = new ProviderError(ProviderFailure.ConnectionFailure);
      const expectedExtendedMetadata = undefined;
      const attachedMetadata = attachExtendedMetadata(metadata, error);

      expect(attachedMetadata).not.toBeNull();
      expect(attachedMetadata).toEqual({ ...metadata, ext: expectedExtendedMetadata });
    });

    it('attaches extended metadata as null if the pool metadata is not found', async () => {
      const error = new ProviderError(ProviderFailure.NotFound);
      const expectedExtendedMetadata = null;
      const attachedMetadata = attachExtendedMetadata(metadata, error);

      expect(attachedMetadata).not.toBeNull();
      expect(attachedMetadata).toEqual({ ...metadata, ext: expectedExtendedMetadata });
    });
  });

  describe('getUrlToFetch', () => {
    it('returns correct url in mode StakePoolMetadataFetchMode.DIRECT', async () => {
      const expectedUrl = 'happy_url';
      const generatedUrl = getUrlToFetch(
        StakePoolMetadataFetchMode.DIRECT,
        'not_relevant',
        expectedUrl,
        'not_relevant',
        'not_relevant'
      );
      expect(generatedUrl).toEqual(expectedUrl);
    });

    it('returns correct url in node StakePoolMetadataFetchMode.SMASH', async () => {
      const smashUrl = 'http://localhost:3100';
      const poolRegistrationId = 'pool_registration_id';
      const metadataHash = 'metadata_hash';

      const expectedUrl = `${smashUrl}/metadata/${poolRegistrationId}/${metadataHash}`;
      const generatedUrl = getUrlToFetch(
        StakePoolMetadataFetchMode.SMASH,
        smashUrl,
        'not_relevant',
        poolRegistrationId,
        metadataHash
      );
      expect(generatedUrl).toEqual(expectedUrl);
    });

    it('throws NotImplementedError if an unhandled fetch mode is supplied', async () => {
      const smashUrl = 'http://localhost:3100';
      const poolRegistrationId = 'pool_registration_id';
      const metadataHash = 'metadata_hash';

      expect(() =>
        getUrlToFetch(
          StakePoolMetadataFetchMode['not_a_fetch_mode' as keyof typeof StakePoolMetadataFetchMode],
          smashUrl,
          'not_relevant',
          poolRegistrationId,
          metadataHash
        )
      ).toThrowError(NotImplementedError);
    });
  });
});
