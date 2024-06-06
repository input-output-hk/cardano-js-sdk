import { AddressTableMigrations1690955710125 } from './1690955710125-address-table.js';
import { AssetTableMigration1682519108365 } from './1682519108365-asset-table.js';
import { BlockDataTableMigration1682519108359 } from './1682519108359-block-data-table.js';
import { BlockTableMigration1682519108358 } from './1682519108358-block-table.js';
import { CostPledgeNumericMigration1689091319930 } from './1689091319930-cost-pledge-numeric.js';
import { CurrentStakePollMetricsAttributesMigrations1698174358997 } from './1698174358997-current-pool-metrics-attributes.js';
import { FkPoolRegistrationMigration1682519108369 } from './1682519108369-fk-pool-registration.js';
import { FkPoolRetirementMigration1682519108370 } from './1682519108370-fk-pool-retirement.js';
import { HandleDefaultMigrations1693830294136 } from './1693830294136-handle-default-columns.js';
import { HandleMetadataTableMigrations1693490983715 } from './1693490983715-handle-metadata-table.js';
import { HandleParentMigration1700556589063 } from './1700556589063-handle-parent.js';
import { HandleTableMigration1686138943349 } from './1686138943349-handle-table.js';
import { NftMetadataTableMigration1690269355640 } from './1690269355640-nft-metadata-table.js';
import { OutputTableMigration1682519108367 } from './1682519108367-output-table.js';
import { PoolDelistedTableMigration1695899010515 } from './1695899010515-pool-delisted-table.js';
import { PoolMetadataTableMigration1682519108363 } from './1682519108363-pool-metadata-table.js';
import { PoolMetricsMigrations1685011799580 } from './1685011799580-stake-pool-metrics-table.js';
import { PoolRegistrationTableMigration1682519108360 } from './1682519108360-pool-registration-table.js';
import { PoolRetirementTableMigration1682519108361 } from './1682519108361-pool-retirement-table.js';
import { PoolRewardsTableMigrations1698175956871 } from './1698175956871-pool-rewards-table.js';
import { RewardsPledgeNumericMigration1715157190230 } from './1715157190230-rewards-pledge-numeric.js';
import { StakeKeyRegistrationsTableMigrations1690964880195 } from './1690964880195-stake-key-registrations-table.js';
import { StakePoolTableMigration1682519108362 } from './1682519108362-stake-pool-table.js';
import { TokensQuantityNumericMigrations1691042603934 } from './1691042603934-tokens-quantity-numeric.js';
import { TokensTableMigration1682519108368 } from './1682519108368-tokens-table.js';

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
  HandleDefaultMigrations1693830294136,
  PoolDelistedTableMigration1695899010515,
  CurrentStakePollMetricsAttributesMigrations1698174358997,
  PoolRewardsTableMigrations1698175956871,
  HandleParentMigration1700556589063,
  RewardsPledgeNumericMigration1715157190230
];
