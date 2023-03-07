import { AssetTableMigration1682519108365 } from './1682519108365-asset-table';
import { BlockDataTableMigration1682519108359 } from './1682519108359-block-data-table';
import { BlockTableMigration1682519108358 } from './1682519108358-block-table';
import { FkPoolRegistrationMigration1682519108369 } from './1682519108369-fk-pool-registration';
import { FkPoolRetirementMigration1682519108370 } from './1682519108370-fk-pool-retirement';
import { OutputTableMigration1682519108367 } from './1682519108367-output-table';
import { PoolMetadataTableMigration1682519108363 } from './1682519108363-pool-metadata-table';
import { PoolRegistrationTableMigration1682519108360 } from './1682519108360-pool-registration-table';
import { PoolRetirementTableMigration1682519108361 } from './1682519108361-pool-retirement-table';
import { StakePoolTableMigration1682519108362 } from './1682519108362-stake-pool-table';
import { TokensTableMigration1682519108368 } from './1682519108368-tokens-table';

type ProjectionMigration = Function & {
  entity: Function;
};

export const migrations: ProjectionMigration[] = [
  BlockTableMigration1682519108358,
  BlockDataTableMigration1682519108359,
  PoolRegistrationTableMigration1682519108360,
  PoolRetirementTableMigration1682519108361,
  StakePoolTableMigration1682519108362,
  PoolMetadataTableMigration1682519108363,
  AssetTableMigration1682519108365,
  OutputTableMigration1682519108367,
  TokensTableMigration1682519108368,
  FkPoolRegistrationMigration1682519108369,
  FkPoolRetirementMigration1682519108370
];
