import {
  AddressEntity,
  AssetEntity,
  BlockDataEntity,
  BlockEntity,
  CredentialEntity,
  CurrentPoolMetricsEntity,
  DataSourceExtensions,
  GovernanceActionEntity,
  HandleEntity,
  HandleMetadataEntity,
  NftMetadataEntity,
  OutputEntity,
  PoolDelistedEntity,
  PoolMetadataEntity,
  PoolRegistrationEntity,
  PoolRetirementEntity,
  PoolRewardsEntity,
  StakeKeyRegistrationEntity,
  StakePoolEntity,
  TokensEntity,
  TransactionEntity,
  createStorePoolMetricsUpdateJob,
  createStoreStakePoolMetadataJob,
  storeAddresses,
  storeAssets,
  storeBlock,
  storeCredentials,
  storeGovernanceAction,
  storeHandleMetadata,
  storeHandles,
  storeNftMetadata,
  storeStakeKeyRegistrations,
  storeStakePoolRewardsJob,
  storeStakePools,
  storeTransactions,
  storeUtxo,
  willStoreAddresses,
  willStoreAssets,
  willStoreBlockData,
  willStoreCredentials,
  willStoreGovernanceAction,
  willStoreHandleMetadata,
  willStoreHandles,
  willStoreNftMetadata,
  willStoreStakeKeyRegistrations,
  willStoreStakePoolMetadataJob,
  willStoreStakePoolRewardsJob,
  willStoreStakePools,
  willStoreTransactions,
  willStoreUtxo
} from '@cardano-sdk/projection-typeorm';
import { Cardano, ChainSyncEventType } from '@cardano-sdk/core';
import { Mappers as Mapper, ProjectionEvent } from '@cardano-sdk/projection';
import { ObservableType, passthrough } from '@cardano-sdk/util-rxjs';
import { POOLS_METRICS_INTERVAL_DEFAULT, POOLS_METRICS_OUTDATED_INTERVAL_DEFAULT } from '../Program/programs/types';
import { Sorter } from '@hapi/topo';
import { WithLogger, isNotNil } from '@cardano-sdk/util';

/** Used as mount segments, so must be URL-friendly */
export enum ProjectionName {
  Address = 'address',
  Asset = 'asset',
  Handle = 'handle',
  ProtocolParameters = 'protocol-parameters',
  StakePool = 'stake-pool',
  StakePoolMetadataJob = 'stake-pool-metadata-job',
  StakePoolMetricsJob = 'stake-pool-metrics-job',
  StakePoolRewardsJob = 'stake-pool-rewards-job',
  Transactions = 'transactions',
  UTXO = 'utxo'
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
  const filterProducedUtxoByAssetsPresence =
    projectionNames.includes(ProjectionName.Asset) && !projectionNames.includes(ProjectionName.UTXO)
      ? Mapper.filterProducedUtxoByAssetsPresence()
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
    filterProducedUtxoByAssetsPresence,
    filterUtxo,
    withAddresses: Mapper.withAddresses(),
    withCIP67: Mapper.withCIP67(),
    withCertificates: Mapper.withCertificates(),
    withGovernanceActions: Mapper.withGovernanceActions(),
    withHandleMetadata,
    withHandles,
    withMint: Mapper.withMint(),
    withNftMetadata: Mapper.withNftMetadata({ logger }),
    withStakeKeyRegistrations: Mapper.withStakeKeyRegistrations(),
    withStakePools: Mapper.withStakePools(),
    withUtxo: Mapper.withUtxo(),
    withValidByronAddresses: Mapper.withValidByronAddresses()
  };
};
type MapperOperators = ReturnType<typeof createMapperOperators>;
type MapperName = keyof MapperOperators;
type MapperOperator = MapperOperators[MapperName];

export const storeOperators = {
  storeAddresses: storeAddresses(),
  storeAssets: storeAssets(),
  storeBlock: storeBlock(),
  storeCredentials: storeCredentials(),
  storeGovernanceAction: storeGovernanceAction(),
  storeHandleMetadata: storeHandleMetadata(),
  storeHandles: storeHandles(),
  storeNftMetadata: storeNftMetadata(),
  storePoolMetricsUpdateJob: createStorePoolMetricsUpdateJob(
    POOLS_METRICS_INTERVAL_DEFAULT,
    POOLS_METRICS_OUTDATED_INTERVAL_DEFAULT
  )(),
  storeStakeKeyRegistrations: storeStakeKeyRegistrations(),
  storeStakePoolMetadataJob: createStoreStakePoolMetadataJob()(),
  storeStakePoolRewardsJob: storeStakePoolRewardsJob(),
  storeStakePools: storeStakePools(),
  storeTransactions: storeTransactions(),
  storeUtxo: storeUtxo()
};
type StoreOperators = typeof storeOperators;
type StoreName = keyof StoreOperators;
type StoreOperator = StoreOperators[StoreName];

// eslint-disable-next-line @typescript-eslint/no-explicit-any
type InferArg0<F extends Function> = F extends (arg0: infer Args) => any ? Args : never;
type WillStore = {
  [k in keyof StoreOperators]: (args: ObservableType<InferArg0<StoreOperators[k]>>) => boolean;
};

const willStore: Partial<WillStore> = {
  storeAddresses: willStoreAddresses,
  storeAssets: willStoreAssets,
  storeCredentials: willStoreCredentials,
  storeGovernanceAction: willStoreGovernanceAction,
  storeHandleMetadata: willStoreHandleMetadata,
  storeHandles: willStoreHandles,
  storeNftMetadata: willStoreNftMetadata,
  storeStakeKeyRegistrations: willStoreStakeKeyRegistrations,
  storeStakePoolMetadataJob: willStoreStakePoolMetadataJob,
  storeStakePoolRewardsJob: willStoreStakePoolRewardsJob,
  storeStakePools: willStoreStakePools,
  storeTransactions: willStoreTransactions,
  storeUtxo: willStoreUtxo
};

const entities = {
  address: AddressEntity,
  asset: AssetEntity,
  block: BlockEntity,
  blockData: BlockDataEntity,
  credential: CredentialEntity,
  currentPoolMetrics: CurrentPoolMetricsEntity,
  governanceAction: GovernanceActionEntity,
  handle: HandleEntity,
  handleMetadata: HandleMetadataEntity,
  nftMetadata: NftMetadataEntity,
  output: OutputEntity,
  poolDelisted: PoolDelistedEntity,
  poolMetadata: PoolMetadataEntity,
  poolRegistration: PoolRegistrationEntity,
  poolRetirement: PoolRetirementEntity,
  poolRewards: PoolRewardsEntity,
  stakeKeyRegistration: StakeKeyRegistrationEntity,
  stakePool: StakePoolEntity,
  tokens: TokensEntity,
  transaction: TransactionEntity
};
export const allEntities = Object.values(entities);
type Entities = typeof entities;
type EntityName = keyof Entities;
type Entity = Entities[EntityName];

const storeEntities: Partial<Record<StoreName, EntityName[]>> = {
  storeAddresses: ['address'],
  storeAssets: ['asset'],
  storeBlock: ['block', 'blockData'],
  storeCredentials: ['credential', 'transaction', 'output'],
  storeGovernanceAction: ['governanceAction'],
  storeHandleMetadata: ['handleMetadata', 'output'],
  storeHandles: ['handle', 'asset', 'tokens', 'output'],
  storeNftMetadata: ['asset'],
  storePoolMetricsUpdateJob: ['stakePool', 'currentPoolMetrics', 'poolMetadata'],
  storeStakeKeyRegistrations: ['block', 'stakeKeyRegistration'],
  // 'stake-pool' projection requires it, but `storeStakePools` does not.
  // at the time of writing there was no way to specify a direct projection->entity dependency.
  storeStakePoolMetadataJob: ['stakePool', 'currentPoolMetrics', 'poolMetadata'],
  storeStakePoolRewardsJob: ['poolRewards', 'stakePool'],
  storeStakePools: ['stakePool', 'currentPoolMetrics', 'poolMetadata', 'poolDelisted'],
  storeTransactions: ['block', 'transaction'],
  storeUtxo: ['tokens', 'output']
};

const entityInterDependencies: Partial<Record<EntityName, EntityName[]>> = {
  address: ['stakeKeyRegistration'],
  asset: ['block', 'nftMetadata'],
  blockData: ['block'],
  credential: [],
  currentPoolMetrics: ['stakePool'],
  governanceAction: ['block'],
  handle: ['asset'],
  handleMetadata: ['output'],
  output: ['block', 'tokens'],
  poolDelisted: ['stakePool'],
  poolMetadata: ['stakePool'],
  poolRegistration: ['block'],
  poolRetirement: ['block'],
  stakeKeyRegistration: ['block'],
  stakePool: ['block', 'poolRegistration', 'poolRetirement'],
  tokens: ['asset'],
  transaction: ['block', 'credential']
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
  withAddresses: ['withUtxo', 'filterUtxo'],
  withCIP67: ['withUtxo', 'filterUtxo', 'withMint', 'filterMint'],
  withHandleMetadata: ['withNftMetadata', 'withCIP67'],
  withHandles: ['withMint', 'filterMint', 'withUtxo', 'filterUtxo', 'withCIP67'],
  withNftMetadata: ['withCIP67', 'withMint', 'filterMint'],
  withStakeKeyRegistrations: ['withCertificates'],
  withStakePools: ['withCertificates'],
  withValidByronAddresses: ['withUtxo']
};

const storeMapperDependencies: Partial<Record<StoreName, MapperName[]>> = {
  storeAddresses: ['withAddresses'],
  storeAssets: ['withMint'],
  storeCredentials: ['withAddresses', 'withCertificates', 'withUtxo', 'withValidByronAddresses'],
  storeGovernanceAction: ['withGovernanceActions'],
  storeHandleMetadata: ['withHandleMetadata'],
  storeHandles: ['withHandles'],
  storeNftMetadata: ['withNftMetadata'],
  storeStakeKeyRegistrations: ['withStakeKeyRegistrations'],
  storeStakePoolMetadataJob: ['withStakePools'],
  storeStakePools: ['withStakePools'],
  storeUtxo: ['withUtxo']
};

const storeInterDependencies: Partial<Record<StoreName, StoreName[]>> = {
  storeAddresses: ['storeBlock', 'storeStakeKeyRegistrations'],
  storeAssets: ['storeBlock'],
  storeGovernanceAction: ['storeBlock'],
  storeHandleMetadata: ['storeUtxo'],
  storeHandles: ['storeUtxo', 'storeAddresses', 'storeHandleMetadata'],
  storeNftMetadata: ['storeAssets'],
  storePoolMetricsUpdateJob: ['storeBlock'],
  storeStakePoolMetadataJob: ['storeBlock'],
  storeStakePoolRewardsJob: ['storeBlock'],
  storeStakePools: ['storeBlock'],
  storeTransactions: ['storeCredentials', 'storeBlock', 'storeUtxo'],
  storeUtxo: ['storeBlock', 'storeAssets']
};

const projectionStoreDependencies: Record<ProjectionName, StoreName[]> = {
  address: ['storeAddresses'],
  asset: ['storeAssets', 'storeNftMetadata'],
  // TODO: remove storeNftMetadata when TypeormAssetProvider tests
  // are updated to use 'asset' database instead of a handle database
  handle: ['storeHandles', 'storeHandleMetadata', 'storeNftMetadata'],
  'protocol-parameters': ['storeGovernanceAction'],
  'stake-pool': ['storeStakePools'],
  'stake-pool-metadata-job': ['storeStakePoolMetadataJob'],
  'stake-pool-metrics-job': ['storePoolMetricsUpdateJob'],
  'stake-pool-rewards-job': ['storeStakePoolRewardsJob'],
  transaction: ['storeCredentials', 'storeTransactions'],
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
  options?: ProjectionOptions;
}

/** Selects a required set of entities, mappers and store operators based on 'projections' and presence of 'buffer': */
export const prepareTypeormProjection = (
  { projections, options = {} }: PrepareTypeormProjectionProps,
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
  const extensions = requiredExtensions(projections);
  const willStoreCheckers = selectedStores
    .map((store) => Object.entries(storeOperators).find(([_, operator]) => store === operator)!)
    .map(([storeName]) => willStore[storeName as keyof StoreOperators])
    .filter(isNotNil);

  return {
    __debug: {
      entities: selectedEntities.map((Entity) => keyOf(entities, Entity)),
      mappers: selectedMappers.map((mapper) => keyOf(mapperOperators, mapper)),
      stores: selectedStores.map((store) => keyOf(storeOperators, store)),
      willStoreCheckers: willStoreCheckers.map((checker) => checker.name)
    },
    entities: selectedEntities,
    extensions,
    mappers: selectedMappers,
    stores: selectedStores,
    willStore: <T extends ProjectionEvent>(evt: T) =>
      evt.eventType === ChainSyncEventType.RollBackward ||
      willStoreBlockData(evt) ||
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      willStoreCheckers.some((check) => check(evt as any))
  };
};

export type PreparedProjection = ReturnType<typeof prepareTypeormProjection>;
