import { ProjectionName, prepareTypeormProjection } from '../../src';
import { TypeormStabilityWindowBuffer } from '@cardano-sdk/projection-typeorm';
import { dummyLogger } from 'ts-log';

const prepare = (projections: ProjectionName[], useBuffer?: boolean) => {
  const { __debug } = prepareTypeormProjection(
    {
      buffer: useBuffer ? new TypeormStabilityWindowBuffer({ logger: dummyLogger }) : undefined,
      projections
    },
    { logger: dummyLogger }
  );
  return __debug;
};

describe('prepareTypeormProjection', () => {
  describe('computes required entities, mappers and stores based on selected projections and presence of a buffer', () => {
    test('utxo (without buffer)', () => {
      const { entities, mappers, stores } = prepare([ProjectionName.UTXO]);
      expect(new Set(entities)).toEqual(new Set(['tokens', 'block', 'asset', 'nftMetadata', 'output']));
      expect(mappers).toEqual(['withMint', 'withUtxo']);
      expect(stores).toEqual(['storeBlock', 'storeAssets', 'storeUtxo']);
    });

    test('utxo (with buffer)', () => {
      const { entities, mappers, stores } = prepare([ProjectionName.UTXO], true);
      expect(new Set(entities)).toEqual(new Set(['tokens', 'block', 'asset', 'nftMetadata', 'output', 'blockData']));
      expect(mappers).toEqual(['withMint', 'withUtxo']);
      // 'null' is expected here because buffer.storeBlockData is not a common operator,
      // but is a method of the buffer. As a result it's not part of the predefined operators object.
      expect(stores).toEqual(['storeBlock', 'storeAssets', 'storeUtxo', null]);
    });

    test('stake-pool,stake-pool-metadata', () => {
      const { entities, mappers, stores } = prepare([ProjectionName.StakePool, ProjectionName.StakePoolMetadataJob]);
      expect(new Set(entities)).toEqual(
        new Set(['block', 'stakePool', 'poolRegistration', 'poolRetirement', 'poolMetadata'])
      );
      expect(mappers).toEqual(['withCertificates', 'withStakePools']);
      expect(stores).toEqual(['storeBlock', 'storeStakePools', 'storeStakePoolMetadataJob']);
    });
  });
});
