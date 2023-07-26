/* eslint-disable complexity */
/* eslint-disable sonarjs/cognitive-complexity */
import { FilterCondition, QueryStakePoolsArgs, SortField, SortOrder, StakePoolSortOptions } from '@cardano-sdk/core';

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
  'metrics.apy'
];

export const sortSelectionMap: { [key in SortField]: string } = {
  apy: 'metrics_apy',
  cost: 'params.cost',
  name: 'metadata.name',
  saturation: 'metrics_live_saturation'
};

export const nullsInSort = 'NULLS LAST';

export const stakePoolSearchTotalCount = 'count(*) over () as total_count';

export const getSortOptions = (
  sort?: StakePoolSortOptions,
  defaultField: SortField = 'name',
  defaultOrder: SortOrder = 'asc'
) => {
  if (!sort) {
    sort = { field: defaultField, order: defaultOrder };
  }
  if (sort.field === 'name') {
    return {
      field: `lower(${sortSelectionMap[sort.field as SortField]})`,
      order: sort.order.toUpperCase() as Uppercase<SortOrder>
    };
  }
  return {
    field: sortSelectionMap[sort.field as SortField],
    order: sort.order.toUpperCase() as Uppercase<SortOrder>
  };
};

export const getFilterCondition = (condition?: FilterCondition, defaultCondition: Uppercase<FilterCondition> = 'OR') =>
  condition ? (condition.toUpperCase() as Uppercase<FilterCondition>) : defaultCondition;

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
    if ('name' in identifierArgs) identifierClauses.push('LOWER(metadata.name) IN (:...name)');
    if ('ticker' in identifierArgs) identifierClauses.push('LOWER(metadata.ticker) IN (:...ticker)');

    const identifierFilters = identifierClauses.join(` ${identifierCondition} `);
    clauses.push(` (${identifierFilters}) `);
  }

  return {
    args: { ...args, ...identifierArgs },
    clause: clauses.join(` ${condition} `)
  };
};
