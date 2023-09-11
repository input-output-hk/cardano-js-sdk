import {
  AddressEntity,
  AssetEntity,
  BlockDataEntity,
  BlockEntity,
  CurrentPoolMetricsEntity,
  DataSourceExtensions,
  HandleEntity,
  HandleMetadataEntity,
  NftMetadataEntity,
  OutputEntity,
  PoolMetadataEntity,
  PoolRegistrationEntity,
  PoolRetirementEntity,
  StakeKeyRegistrationEntity,
  StakePoolEntity,
  TokensEntity,
  TypeormStabilityWindowBuffer,
  createStorePoolMetricsUpdateJob,
  storeAddresses,
  storeAssets,
  storeBlock,
  storeHandleMetadata,
  storeHandles,
  storeNftMetadata,
  storeStakeKeyRegistrations,
  storeStakePoolMetadataJob,
  storeStakePools,
  storeUtxo
} from '@cardano-sdk/projection-typeorm';
import { Cardano } from '@cardano-sdk/core';
import { Mappers as Mapper } from '@cardano-sdk/projection';
import { POOLS_METRICS_INTERVAL_DEFAULT } from '../Program/programs/types';
import { Sorter } from '@hapi/topo';
import { WithLogger } from '@cardano-sdk/util';
import { passthrough } from '@cardano-sdk/util-rxjs';

/**
 * Used as mount segments, so must be URL-friendly
 *
 */
export enum ProjectionName {
  Handle = 'handle',
  StakePool = 'stake-pool',
  StakePoolMetadataJob = 'stake-pool-metadata-job',
  StakePoolMetricsJob = 'stake-pool-metrics-job',
  UTXO = 'utxo',
  Address = 'address'
}

export interface ProjectionOptions {
  handlePolicyIds?: Cardano.PolicyId[];
}

const requiredExtensions = (projectionNames: ProjectionName[]): DataSourceExtensions => ({
  pgBoss: projectionNames.includes(ProjectionName.StakePoolMetadataJob)
});

const createMapperOperators = (
  projectionNames: ProjectionName[],
  { handlePolicyIds }: ProjectionOptions,
  { logger }: WithLogger
) => {
  const applyUtxoAndMintFilters = handlePolicyIds && !projectionNames.includes(ProjectionName.UTXO);
  const filterUtxo = applyUtxoAndMintFilters
    ? Mapper.filterProducedUtxoByAssetPolicyId({ policyIds: handlePolicyIds })
    : passthrough();
  const filterMint = applyUtxoAndMintFilters
    ? Mapper.filterMintByPolicyIds({ policyIds: handlePolicyIds })
    : passthrough();
  const withHandles = handlePolicyIds ? Mapper.withHandles({ policyIds: handlePolicyIds }, logger) : passthrough();
  const withHandleMetadata = handlePolicyIds
    ? Mapper.withHandleMetadata({ policyIds: handlePolicyIds }, logger)
    : passthrough();
  return {
    filterMint,
    filterUtxo,
    withAddresses: Mapper.withAddresses(),
    withCIP67: Mapper.withCIP67(),
    withCertificates: Mapper.withCertificates(),
    withHandleMetadata,
    withHandles,
    withMint: Mapper.withMint(),
    withNftMetadata: Mapper.withNftMetadata({ logger }),
    withStakeKeyRegistrations: Mapper.withStakeKeyRegistrations(),
    withStakePools: Mapper.withStakePools(),
    withUtxo: Mapper.withUtxo()
  };
};
type MapperOperators = ReturnType<typeof createMapperOperators>;
type MapperName = keyof MapperOperators;
type MapperOperator = MapperOperators[MapperName];

export const storeOperators = {
  storeAddresses: storeAddresses(),
  storeAssets: storeAssets(),
  storeBlock: storeBlock(),
  storeHandleMetadata: storeHandleMetadata(),
  storeHandles: storeHandles(),
  storeNftMetadata: storeNftMetadata(),
  storePoolMetricsUpdateJob: createStorePoolMetricsUpdateJob(POOLS_METRICS_INTERVAL_DEFAULT)(),
  storeStakeKeyRegistrations: storeStakeKeyRegistrations(),
  storeStakePoolMetadataJob: storeStakePoolMetadataJob(),
  storeStakePools: storeStakePools(),
  storeUtxo: storeUtxo()
};
type StoreOperators = typeof storeOperators;
type StoreName = keyof StoreOperators;
type StoreOperator = StoreOperators[StoreName];

const entities = {
  address: AddressEntity,
  asset: AssetEntity,
  block: BlockEntity,
  blockData: BlockDataEntity,
  currentPoolMetrics: CurrentPoolMetricsEntity,
  handle: HandleEntity,
  handleMetadata: HandleMetadataEntity,
  nftMetadata: NftMetadataEntity,
  output: OutputEntity,
  poolMetadata: PoolMetadataEntity,
  poolRegistration: PoolRegistrationEntity,
  poolRetirement: PoolRetirementEntity,
  stakeKeyRegistration: StakeKeyRegistrationEntity,
  stakePool: StakePoolEntity,
  tokens: TokensEntity
};
export const allEntities = Object.values(entities);
type Entities = typeof entities;
type EntityName = keyof Entities;
type Entity = Entities[EntityName];

const storeEntities: Partial<Record<StoreName, EntityName[]>> = {
  storeAddresses: ['address'],
  storeAssets: ['asset'],
  storeBlock: ['block'],
  storeHandleMetadata: ['handleMetadata', 'output'],
  storeHandles: ['handle', 'asset', 'tokens', 'output'],
  storeNftMetadata: ['asset'],
  storePoolMetricsUpdateJob: ['stakePool', 'currentPoolMetrics', 'poolMetadata'],
  storeStakeKeyRegistrations: ['block', 'stakeKeyRegistration'],
  storeStakePoolMetadataJob: ['stakePool', 'currentPoolMetrics', 'poolMetadata'],
  storeStakePools: ['stakePool', 'currentPoolMetrics', 'poolMetadata'],
  storeUtxo: ['tokens', 'output']
};

const entityInterDependencies: Partial<Record<EntityName, EntityName[]>> = {
  address: ['stakeKeyRegistration'],
  asset: ['block', 'nftMetadata'],
  blockData: ['block'],
  currentPoolMetrics: ['stakePool'],
  handle: ['asset'],
  handleMetadata: ['output'],
  output: ['block', 'tokens'],
  poolMetadata: ['stakePool'],
  poolRegistration: ['block'],
  poolRetirement: ['block'],
  stakeKeyRegistration: ['block'],
  stakePool: ['block', 'poolRegistration', 'poolRetirement'],
  tokens: ['asset']
};

export const getEntities = (entityNames: EntityName[]): Entity[] => {
  const resolvedNames: EntityName[] = [];
  const resultEntities: Entity[] = [];

  const scanDependencies = (names: EntityName[] | undefined) => {
    if (!names) return;

    for (const name of names)
      if (!resolvedNames.includes(name)) {
        resolvedNames.push(name);
        resultEntities.push(entities[name]);
        scanDependencies(entityInterDependencies[name]);
      }
  };

  scanDependencies(entityNames);

  return resultEntities;
};

const mapperInterDependencies: Partial<Record<MapperName, MapperName[]>> = {
  filterMint: ['withMint'],
  filterUtxo: ['withUtxo'],
  withAddresses: ['withUtxo'],
  withCIP67: ['withUtxo'],
  withHandleMetadata: ['withNftMetadata', 'withCIP67'],
  withHandles: ['withMint', 'filterMint', 'withUtxo', 'filterUtxo', 'withCIP67'],
  withNftMetadata: ['withCIP67', 'withMint'],
  withStakeKeyRegistrations: ['withCertificates'],
  withStakePools: ['withCertificates']
};

const storeMapperDependencies: Partial<Record<StoreName, MapperName[]>> = {
  storeAddresses: ['withAddresses'],
  storeAssets: ['withMint'],
  storeHandleMetadata: ['withHandleMetadata'],
  storeHandles: ['withHandles'],
  storeNftMetadata: ['withNftMetadata'],
  storeStakeKeyRegistrations: ['withStakeKeyRegistrations'],
  storeStakePoolMetadataJob: ['withStakePools'],
  storeStakePools: ['withStakePools'],
  storeUtxo: ['withUtxo']
};

const storeInterDependencies: Partial<Record<StoreName, StoreName[]>> = {
  storeAddresses: ['storeStakeKeyRegistrations'],
  storeAssets: ['storeBlock'],
  storeHandleMetadata: ['storeUtxo'],
  storeHandles: ['storeUtxo'],
  storeNftMetadata: ['storeAssets'],
  storePoolMetricsUpdateJob: ['storeBlock'],
  storeStakePoolMetadataJob: ['storeBlock'],
  storeStakePools: ['storeBlock'],
  storeUtxo: ['storeBlock', 'storeAssets']
};

const projectionStoreDependencies: Record<ProjectionName, StoreName[]> = {
  address: ['storeAddresses'],
  // TODO: remove storeNftMetadata when TypeormAssetProvider tests
  // are updated to use 'asset' database instead of a handle database
  handle: ['storeHandles', 'storeHandleMetadata', 'storeNftMetadata'],
  'stake-pool': ['storeStakePools'],
  'stake-pool-metadata-job': ['storeStakePoolMetadataJob'],
  'stake-pool-metrics-job': ['storePoolMetricsUpdateJob'],
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
  options?: ProjectionOptions;
}

/**
 * Selects a required set of entities, mappers and store operators
 * based on 'projections' and presence of 'buffer':
 */
export const prepareTypeormProjection = (
  { projections, buffer, options = {} }: PrepareTypeormProjectionProps,
  dependencies: WithLogger
) => {
  const mapperSorter = new Sorter<MapperOperator>();
  const storeSorter = new Sorter<StoreOperator>();
  const entitySorter = new Sorter<Entity>();

  const mapperOperators = createMapperOperators(projections, options, dependencies);

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
