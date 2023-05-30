import {
  AssetEntity,
  BlockDataEntity,
  BlockEntity,
  DataSourceExtensions,
  HandleEntity,
  OutputEntity,
  PoolMetadataEntity,
  PoolRegistrationEntity,
  PoolRetirementEntity,
  StakePoolEntity,
  TokensEntity,
  TypeormStabilityWindowBuffer,
  storeAssets,
  storeBlock,
  storeHandles,
  storeStakePoolMetadataJob,
  storeStakePools,
  storeUtxo
} from '@cardano-sdk/projection-typeorm';
import { Cardano } from '@cardano-sdk/core';
import { Mappers as Mapper } from '@cardano-sdk/projection';
import { Sorter } from '@hapi/topo';
import { passthrough } from '@cardano-sdk/util-rxjs';

export { DataSource } from 'typeorm';

/**
 * Used as mount segments, so must be URL-friendly
 *
 */
export enum ProjectionName {
  StakePool = 'stake-pool',
  Handle = 'handle',
  StakePoolMetadataJob = 'stake-pool-metadata-job',
  UTXO = 'utxo'
}

export interface ProjectionOptions {
  handlePolicyIds?: Cardano.PolicyId[];
}

const requiredExtensions = (projectionNames: ProjectionName[]): DataSourceExtensions => ({
  pgBoss: projectionNames.includes(ProjectionName.StakePoolMetadataJob)
});

const createMapperOperators = (projectionNames: ProjectionName[], { handlePolicyIds }: ProjectionOptions) => {
  const applyUtxoAndMintFilters = handlePolicyIds && !projectionNames.includes(ProjectionName.UTXO);
  const filterUtxo = applyUtxoAndMintFilters
    ? Mapper.filterProducedUtxoByAssetPolicyId({ policyIds: handlePolicyIds })
    : passthrough();
  const filterMint = applyUtxoAndMintFilters
    ? Mapper.filterMintByPolicyIds({ policyIds: handlePolicyIds })
    : passthrough();
  const withHandles = handlePolicyIds ? Mapper.withHandles({ policyIds: handlePolicyIds }) : passthrough();
  return {
    filterMint,
    filterUtxo,
    withCertificates: Mapper.withCertificates(),
    withHandles,
    withMint: Mapper.withMint(),
    withStakePools: Mapper.withStakePools(),
    withUtxo: Mapper.withUtxo()
  };
};
type MapperOperators = ReturnType<typeof createMapperOperators>;
type MapperName = keyof MapperOperators;
type MapperOperator = MapperOperators[MapperName];

const storeOperators = {
  storeAssets: storeAssets(),
  storeBlock: storeBlock(),
  storeHandles: storeHandles(),
  storeStakePoolMetadataJob: storeStakePoolMetadataJob(),
  storeStakePools: storeStakePools(),
  storeUtxo: storeUtxo()
};
type StoreOperators = typeof storeOperators;
type StoreName = keyof StoreOperators;
type StoreOperator = StoreOperators[StoreName];

const entities = {
  asset: AssetEntity,
  block: BlockEntity,
  blockData: BlockDataEntity,
  handle: HandleEntity,
  output: OutputEntity,
  poolMetadata: PoolMetadataEntity,
  poolRegistration: PoolRegistrationEntity,
  poolRetirement: PoolRetirementEntity,
  stakePool: StakePoolEntity,
  tokens: TokensEntity
};
export const allEntities = Object.values(entities);
type Entities = typeof entities;
type EntityName = keyof Entities;
type Entity = Entities[EntityName];

const storeEntities: Partial<Record<StoreName, EntityName[]>> = {
  storeAssets: ['asset'],
  storeBlock: ['block'],
  storeHandles: ['handle'],
  storeStakePoolMetadataJob: ['block', 'poolMetadata'],
  storeStakePools: ['stakePool', 'poolRegistration', 'poolRetirement'],
  storeUtxo: ['tokens', 'output']
};

const entityInterDependencies: Partial<Record<EntityName, EntityName[]>> = {
  asset: ['block'],
  blockData: ['block'],
  handle: ['block', 'tokens', 'asset', 'output'],
  output: ['block'],
  poolRegistration: ['block'],
  poolRetirement: ['block'],
  stakePool: ['block'],
  tokens: ['asset']
};

const mapperInterDependencies: Partial<Record<MapperName, MapperName[]>> = {
  filterMint: ['withMint'],
  filterUtxo: ['withUtxo'],
  withHandles: ['withMint', 'filterMint', 'withUtxo', 'filterUtxo'],
  withStakePools: ['withCertificates']
};

const storeMapperDependencies: Partial<Record<StoreName, MapperName[]>> = {
  storeAssets: ['withMint'],
  storeHandles: ['withHandles'],
  storeStakePoolMetadataJob: ['withStakePools'],
  storeStakePools: ['withStakePools'],
  storeUtxo: ['withUtxo']
};

const storeInterDependencies: Partial<Record<StoreName, StoreName[]>> = {
  storeAssets: ['storeBlock'],
  storeHandles: ['storeUtxo'],
  storeStakePoolMetadataJob: ['storeBlock'],
  storeStakePools: ['storeBlock'],
  storeUtxo: ['storeBlock', 'storeAssets']
};

const projectionStoreDependencies: Record<ProjectionName, StoreName[]> = {
  handle: ['storeHandles'],
  'stake-pool': ['storeStakePools'],
  'stake-pool-metadata-job': ['storeStakePoolMetadataJob'],
  utxo: ['storeUtxo']
};

const registerMapper = (
  mapperOperators: MapperOperators,
  mapperName: MapperName,
  mapperSorter: Sorter<MapperOperator>
): void => {
  const mapperOperator = mapperOperators[mapperName];
  if (mapperSorter.nodes.includes(mapperOperator)) return;
  const dependencyMappers = mapperInterDependencies[mapperName];
  mapperSorter.add(mapperOperator, { after: dependencyMappers, group: mapperName });
  if (dependencyMappers) {
    for (const dependencyMapperName of dependencyMappers) {
      registerMapper(mapperOperators, dependencyMapperName, mapperSorter);
    }
  }
};

const registerEntity = (entityName: EntityName, entitySorter: Sorter<Entity>): void => {
  const entity = entities[entityName];
  if (entitySorter.nodes.includes(entity)) return;
  const dependencyEntities = entityInterDependencies[entityName];
  entitySorter.add(entity, { after: dependencyEntities, group: entityName });
  if (dependencyEntities) {
    for (const dependencyEntityName of dependencyEntities) {
      registerEntity(dependencyEntityName, entitySorter);
    }
  }
};

const registerStore = (
  mapperOperators: MapperOperators,
  storeName: StoreName,
  mapperSorter: Sorter<MapperOperator>,
  storeSorter: Sorter<StoreOperator>,
  entitySorter: Sorter<Entity>
): void => {
  const storeOperator = storeOperators[storeName];
  if (storeSorter.nodes.includes(storeOperator)) return;
  const dependencyStores = storeInterDependencies[storeName];
  storeSorter.add(storeOperator, { after: dependencyStores, group: storeName });
  if (dependencyStores) {
    for (const dependencyStoreName of dependencyStores) {
      registerStore(mapperOperators, dependencyStoreName, mapperSorter, storeSorter, entitySorter);
    }
  }
  const mapperDependencies = storeMapperDependencies[storeName];
  if (mapperDependencies) {
    for (const mapperName of mapperDependencies) {
      registerMapper(mapperOperators, mapperName, mapperSorter);
    }
  }
  const entityDependencies = storeEntities[storeName];
  if (entityDependencies) {
    for (const entityName of entityDependencies) {
      registerEntity(entityName, entitySorter);
    }
  }
};

const keyOf = <T extends {}>(obj: T, value: unknown): keyof T | null => {
  for (const [key, keyValue] of Object.entries(obj)) {
    if (value === keyValue) {
      return key as keyof T;
    }
  }
  return null;
};

export interface PrepareTypeormProjectionProps {
  projections: ProjectionName[];
  buffer?: TypeormStabilityWindowBuffer;
  // TODO: passthrough from cli/env,
  // ensure it's defined when 'handle' projection is enabled
  options?: ProjectionOptions;
}

/**
 * Selects a required set of entities, mappers and store operators
 * based on 'projections' and presence of 'buffer':
 */
export const prepareTypeormProjection = ({ projections, buffer, options = {} }: PrepareTypeormProjectionProps) => {
  const mapperSorter = new Sorter<MapperOperator>();
  const storeSorter = new Sorter<StoreOperator>();
  const entitySorter = new Sorter<Entity>();

  const mapperOperators = createMapperOperators(projections, options);

  for (const projection of projections) {
    for (const storeName of projectionStoreDependencies[projection]) {
      registerStore(mapperOperators, storeName, mapperSorter, storeSorter, entitySorter);
    }
  }
  const selectedEntities = entitySorter.nodes;
  const selectedMappers = mapperSorter.nodes;
  const selectedStores = storeSorter.nodes;
  if (buffer) {
    selectedEntities.push(BlockDataEntity);
    selectedStores.push(buffer.storeBlockData());
  }
  const extensions = requiredExtensions(projections);
  return {
    __debug: {
      entities: selectedEntities.map((Entity) => keyOf(entities, Entity)),
      mappers: selectedMappers.map((mapper) => keyOf(mapperOperators, mapper)),
      stores: selectedStores.map((store) => keyOf(storeOperators, store))
    },
    entities: selectedEntities,
    extensions,
    mappers: selectedMappers,
    stores: selectedStores
  };
};

export type PreparedProjection = ReturnType<typeof prepareTypeormProjection>;
