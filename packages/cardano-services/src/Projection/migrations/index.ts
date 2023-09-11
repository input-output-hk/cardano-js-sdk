import { AddressTableMigrations1690955710125 } from './1690955710125-address-table';
import { AssetTableMigration1682519108365 } from './1682519108365-asset-table';
import { BlockDataTableMigration1682519108359 } from './1682519108359-block-data-table';
import { BlockTableMigration1682519108358 } from './1682519108358-block-table';
import { CostPledgeNumericMigration1689091319930 } from './1689091319930-cost-pledge-numeric';
import { FkPoolRegistrationMigration1682519108369 } from './1682519108369-fk-pool-registration';
import { FkPoolRetirementMigration1682519108370 } from './1682519108370-fk-pool-retirement';
import { HandleDefaultMigrations1693830294136 } from './1693830294136-handle-default-columns';
import { HandleMetadataTableMigrations1693490983715 } from './1693490983715-handle-metadata-table';
import { HandleTableMigration1686138943349 } from './1686138943349-handle-table';
import { NftMetadataTableMigration1690269355640 } from './1690269355640-nft-metadata-table';
import { OutputTableMigration1682519108367 } from './1682519108367-output-table';
import { PoolMetadataTableMigration1682519108363 } from './1682519108363-pool-metadata-table';
import { PoolMetricsMigrations1685011799580 } from './1685011799580-stake-pool-metrics-table';
import { PoolRegistrationTableMigration1682519108360 } from './1682519108360-pool-registration-table';
import { PoolRetirementTableMigration1682519108361 } from './1682519108361-pool-retirement-table';
import { StakeKeyRegistrationsTableMigrations1690964880195 } from './1690964880195-stake-key-registrations-table';
import { StakePoolTableMigration1682519108362 } from './1682519108362-stake-pool-table';
import { TokensQuantityNumericMigrations1691042603934 } from './1691042603934-tokens-quantity-numeric';
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
  FkPoolRetirementMigration1682519108370,
  PoolMetricsMigrations1685011799580,
  HandleTableMigration1686138943349,
  CostPledgeNumericMigration1689091319930,
  NftMetadataTableMigration1690269355640,
  AddressTableMigrations1690955710125,
  StakeKeyRegistrationsTableMigrations1690964880195,
  TokensQuantityNumericMigrations1691042603934,
  HandleMetadataTableMigrations1693490983715,
  HandleDefaultMigrations1693830294136
];
