import {
  AssetEntity,
  BlockDataEntity,
  BlockEntity,
  DataSourceExtensions,
  OutputEntity,
  PoolMetadataEntity,
  PoolRegistrationEntity,
  PoolRetirementEntity,
  StakePoolEntity,
  TokensEntity,
  TypeormStabilityWindowBuffer,
  storeAssets,
  storeBlock,
  storeStakePoolMetadataJob,
  storeStakePools,
  storeUtxo
} from '@cardano-sdk/projection-typeorm';
import { Mappers as Mapper } from '@cardano-sdk/projection';
import { Sorter } from '@hapi/topo';

export { DataSource } from 'typeorm';

/**
 * Used as mount segments, so must be URL-friendly
 *
 */
export enum ProjectionName {
  StakePool = 'stake-pool',
  StakePoolMetadataJob = 'stake-pool-metadata-job',
  UTXO = 'utxo'
}

const requiredExtensions = (projectionNames: ProjectionName[]): DataSourceExtensions => ({
  pgBoss: projectionNames.includes(ProjectionName.StakePoolMetadataJob)
});

const mapperOperators = {
  withCertificates: Mapper.withCertificates(),
  withMint: Mapper.withMint(),
  withStakePools: Mapper.withStakePools(),
  withUtxo: Mapper.withUtxo()
};
type MapperOperators = typeof mapperOperators;
type MapperName = keyof MapperOperators;
type MapperOperator = MapperOperators[MapperName];

const storeOperators = {
  storeAssets: storeAssets(),
  storeBlock: storeBlock(),
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
  storeStakePoolMetadataJob: ['block', 'poolMetadata'],
  storeStakePools: ['stakePool', 'poolRegistration', 'poolRetirement'],
  storeUtxo: ['tokens', 'output']
};

const entityInterDependencies: Partial<Record<EntityName, EntityName[]>> = {
  asset: ['block'],
  blockData: ['block'],
  output: ['block'],
  poolRegistration: ['block'],
  poolRetirement: ['block'],
  stakePool: ['block'],
  tokens: ['asset']
};

const mapperInterDependencies: Partial<Record<MapperName, MapperName[]>> = {
  withStakePools: ['withCertificates']
};

const storeMapperDependencies: Partial<Record<StoreName, MapperName[]>> = {
  storeAssets: ['withMint'],
  storeStakePoolMetadataJob: ['withStakePools'],
  storeStakePools: ['withStakePools'],
  storeUtxo: ['withUtxo']
};

const storeInterDependencies: Partial<Record<StoreName, StoreName[]>> = {
  storeAssets: ['storeBlock'],
  storeStakePoolMetadataJob: ['storeBlock'],
  storeStakePools: ['storeBlock'],
  storeUtxo: ['storeBlock', 'storeAssets']
};

const projectionStoreDependencies: Record<ProjectionName, StoreName[]> = {
  'stake-pool': ['storeStakePools'],
  'stake-pool-metadata-job': ['storeStakePoolMetadataJob'],
  utxo: ['storeUtxo']
};

const registerMapper = (mapperName: MapperName, mapperSorter: Sorter<MapperOperator>): void => {
  const mapperOperator = mapperOperators[mapperName];
  if (mapperSorter.nodes.includes(mapperOperator)) return;
  const dependencyMappers = mapperInterDependencies[mapperName];
  mapperSorter.add(mapperOperator, { after: dependencyMappers, group: mapperName });
  if (dependencyMappers) {
    for (const dependencyMapperName of dependencyMappers) {
      registerMapper(dependencyMapperName, mapperSorter);
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
      registerStore(dependencyStoreName, mapperSorter, storeSorter, entitySorter);
    }
  }
  const mapperDependencies = storeMapperDependencies[storeName];
  if (mapperDependencies) {
    for (const mapperName of mapperDependencies) {
      registerMapper(mapperName, mapperSorter);
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
}

/**
 * Selects a required set of entities, mappers and store operators
 * based on 'projections' and presence of 'buffer':
 */
export const prepareTypeormProjection = ({ projections, buffer }: PrepareTypeormProjectionProps) => {
  const mapperSorter = new Sorter<MapperOperator>();
  const storeSorter = new Sorter<StoreOperator>();
  const entitySorter = new Sorter<Entity>();
  for (const projection of projections) {
    for (const storeName of projectionStoreDependencies[projection]) {
      registerStore(storeName, mapperSorter, storeSorter, entitySorter);
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
