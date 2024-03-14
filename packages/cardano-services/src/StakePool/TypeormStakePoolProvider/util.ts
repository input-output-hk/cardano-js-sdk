/* eslint-disable complexity */
/* eslint-disable sonarjs/cognitive-complexity */
import {
  Cardano,
  FilterCondition,
  QueryStakePoolsArgs,
  SortField,
  SortOrder,
  StakePoolSortOptions
} from '@cardano-sdk/core';
import { Percent } from '@cardano-sdk/util';
import { PoolRewardsEntity } from '@cardano-sdk/projection-typeorm';
import { RosComputeParams } from '../../PgBoss';

type StakePoolWhereClauseArgs = {
  name?: string[];
  id?: string[];
  ticker?: string[];
  status?: string[];
};

export const stakePoolSearchSelection = [
  'pool.id',
  'pool.status',
  'params.rewardAccount',
  'params.pledge',
  'params.cost',
  'params.margin',
  'params.relays',
  'params.owners',
  'params.vrf',
  'params.metadataUrl',
  'params.metadataHash',
  'metadata.name',
  'metadata.homepage',
  'metadata.ticker',
  'metadata.description',
  'metadata.ext',
  'metrics.mintedBlocks',
  'metrics.liveDelegators',
  'metrics.activeStake',
  'metrics.liveStake',
  'metrics.activeSize',
  'metrics.liveSize',
  'metrics.liveSaturation',
  'metrics.livePledge',
  'metrics.lastRos',
  'metrics.ros'
];

export const sortSelectionMap: { [key in SortField]: string } = {
  apy: 'metrics_ros',
  blocks: 'metrics_minted_blocks',
  cost: 'params.cost',
  lastRos: 'metrics_last_ros',
  liveStake: 'metrics_live_stake',
  // PERF: this may be source of performances issue due to its complexity.
  // In case of performances degradation we need to keep in mind this.
  margin: "(margin->>'numerator')::numeric / (margin->>'denominator')::numeric",
  name: 'metadata.name',
  pledge: 'params_pledge',
  ros: 'metrics_ros',
  saturation: 'metrics_live_saturation',
  ticker: 'metadata_ticker'
};

export const nullsInSort = 'NULLS LAST';

export const stakePoolSearchTotalCount = 'count(*) over () as total_count';

const defaultSortOption = { field: 'name', order: 'asc' } as const;

export const getSortOptions = (sort: StakePoolSortOptions = defaultSortOption) => {
  const order = sort.order.toUpperCase() as Uppercase<SortOrder>;

  if (sort.field === 'name') return { field: `lower(${sortSelectionMap[sort.field]})`, order };

  return { field: sortSelectionMap[sort.field], order };
};

export const getFilterCondition = (condition?: FilterCondition, defaultCondition: Uppercase<FilterCondition> = 'OR') =>
  condition ? (condition.toUpperCase() as Uppercase<FilterCondition>) : defaultCondition;

// eslint-disable-next-line max-statements
export const getWhereClauseAndArgs = (filters: QueryStakePoolsArgs['filters']) => {
  if (!filters) return { args: {}, clause: '1=1' };

  let args: StakePoolWhereClauseArgs = {};
  const clauses: string[] = [];
  const identifierArgs: { [key: string]: unknown[] } = {};
  const condition = getFilterCondition(filters._condition, 'AND');

  if (filters.status?.length) {
    args = { ...args, status: filters.status };
    clauses.push('pool.status IN (:...status)');
  }
  if (filters.identifier && filters.identifier.values.length > 0) {
    const identifierClauses: string[] = [];
    const identifierCondition = getFilterCondition(filters.identifier?._condition, 'OR');
    for (const item of filters.identifier.values) {
      const key = item.id ? 'id' : item.name ? 'name' : 'ticker';
      const value = item[key]!.toLocaleLowerCase();
      identifierArgs[key] ? identifierArgs[key].push(value) : (identifierArgs[key] = [value]);
    }

    if ('id' in identifierArgs) identifierClauses.push('LOWER(pool.id) IN (:...id)');
    if ('name' in identifierArgs) {
      if (identifierArgs.name.length === 1) {
        // exact match first then regexp
        identifierClauses.push('(LOWER(metadata.name) IN (:...name) OR LOWER(metadata.name) ~* (:...name))');
      } else {
        identifierClauses.push('LOWER(metadata.name) IN (:...name)');
      }
    }
    if ('ticker' in identifierArgs) {
      if (identifierArgs.ticker.length === 1) {
        // exact match first then regexp
        identifierClauses.push('(LOWER(metadata.ticker) IN (:...ticker) OR LOWER(metadata.ticker) ~* (:...ticker))');
      } else {
        identifierClauses.push('LOWER(metadata.ticker) IN (:...ticker)');
      }
    }

    const identifierFilters = identifierClauses.join(` ${identifierCondition} `);
    clauses.push(` (${identifierFilters}) `);
  }
  if (filters.pledgeMet !== undefined && filters.pledgeMet !== null) {
    if (filters.pledgeMet) {
      clauses.push('params.pledge<=metrics.live_pledge');
    } else {
      clauses.push('params.pledge>metrics.live_pledge');
    }
  }

  return {
    args: { ...args, ...identifierArgs },
    clause: clauses.join(` ${condition} `)
  };
};

const millisecondsPerYear = 1000 * 3600 * 24 * 365;

/**
 * Computes the annualized ROS for a give stake pool. If `epochs` is not specified, the life time ROS
 * of the stake pool is computed.
 *
 * @returns the ROS
 */
export const computeROS = async ({ dataSource, epochs, logger, stakePool: { id } }: RosComputeParams) => {
  let ros = Percent(0);

  logger.debug(`Going to fetch ${epochs || 'all'} epoch rewards for stake pool ${id}`);

  const result = await dataSource.getRepository(PoolRewardsEntity).find({
    order: { epochNo: 'DESC' },
    select: {
      activeStake: true,
      epochLength: true,
      epochNo: true,
      id: true,
      leaderRewards: true,
      memberActiveStake: true,
      memberRewards: true,
      pledge: true,
      rewards: true
    },
    where: { stakePool: { id } },
    ...(epochs ? { take: epochs } : undefined)
  });

  if (result.length > 0) {
    let period = 0;
    let returnInPeriod = 0;

    for (const epochRewards of result) {
      const { epochLength, memberActiveStake, memberRewards } = epochRewards;

      period += epochLength!;
      returnInPeriod += memberActiveStake === 0n ? 0 : Number(memberRewards) / Number(memberActiveStake);
    }

    ros = Percent((returnInPeriod * millisecondsPerYear) / period);
  }

  logger.debug(`Stake pool ${id} ROS: ${ros}`);

  // eslint-disable-next-line @typescript-eslint/no-shadow, @typescript-eslint/no-unused-vars
  return [ros, result.map(({ id, ...rest }) => rest) as Cardano.StakePoolEpochRewards[]] as const;
};
