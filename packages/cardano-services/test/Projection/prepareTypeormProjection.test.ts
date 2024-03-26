import { ProjectionName, prepareTypeormProjection } from '../../src';
import { dummyLogger } from 'ts-log';

const prepare = (projections: ProjectionName[]) =>
  prepareTypeormProjection({ projections }, { logger: dummyLogger }).__debug;

describe('prepareTypeormProjection', () => {
  describe('computes required entities, mappers, predicates, and stores based on selected projections and presence of a buffer', () => {
    test('utxo', () => {
      const { entities, mappers, stores, willStoreCheckers } = prepare([ProjectionName.UTXO]);
      expect(new Set(entities)).toEqual(new Set(['tokens', 'block', 'asset', 'nftMetadata', 'output', 'blockData']));
      expect(mappers).toEqual(['withMint', 'withUtxo']);
      expect(stores).toEqual(['storeBlock', 'storeAssets', 'storeUtxo']);
      expect(willStoreCheckers).toEqual(['willStoreAssets', 'willStoreUtxo']);
    });

    test('stake-pool,stake-pool-metadata', () => {
      const { entities, mappers, stores, willStoreCheckers } = prepare([
        ProjectionName.StakePool,
        ProjectionName.StakePoolMetadataJob
      ]);
      expect(new Set(entities)).toEqual(
        new Set([
          'block',
          'blockData',
          'stakePool',
          'poolRegistration',
          'poolRetirement',
          'poolMetadata',
          'currentPoolMetrics',
          'poolDelisted'
        ])
      );
      expect(mappers).toEqual(['withCertificates', 'withStakePools']);
      expect(stores).toEqual(['storeBlock', 'storeStakePools', 'storeStakePoolMetadataJob']);
      expect(willStoreCheckers).toEqual(['willStoreStakePools', 'willStoreStakePoolMetadataJob']);
    });
  });
});
