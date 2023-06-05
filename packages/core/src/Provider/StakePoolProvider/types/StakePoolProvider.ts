import { Cardano, Provider } from '../../..';
import { Paginated, PaginationArgs } from '../../types/Pagination';
import { SortFields } from '../util';

export type FilterCondition = 'and' | 'or';
export type SortOrder = 'asc' | 'desc';

export type SortField = typeof SortFields[number];

export interface StakePoolSortOptions {
  order: SortOrder;
  field: SortField;
}

export type FilterIdentifiers = Partial<
  Pick<Cardano.PoolParameters, 'id'> & Pick<Cardano.StakePoolMetadata, 'name' | 'ticker'>
>;

export interface MultipleChoiceSearchFilter<T> {
  /**
   * Defaults to 'or'
   */
  _condition?: FilterCondition;
  values: T[];
}

export interface QueryStakePoolsArgs {
  /**
   * Will return all stake pools sorted by name ascending if not specified
   */
  sort?: StakePoolSortOptions;
  /**
   * Will fetch all stake pools if not specified
   */
  filters?: {
    /**
     * Defaults to 'and'
     */
    _condition?: FilterCondition;
    /**
     * Will return results for partial matches
     */
    identifier?: MultipleChoiceSearchFilter<FilterIdentifiers>;
    pledgeMet?: boolean;
    status?: Cardano.StakePoolStatus[];
  };
  /**
   * Used for APY metric computation. It will take 3 epochs back if not specified
   */
  apyEpochsBackLimit?: number;
  /**
   * Will return all stake pools matching the query if not specified
   */
  pagination: PaginationArgs;
}

export interface StakePoolStats {
  qty: {
    activating: number;
    active: number;
    retired: number;
    retiring: number;
  };
}

export interface StakePoolProvider extends Provider {
  /**
   * @param {QueryStakePoolsArgs} args query args
   * @returns Stake pools
   * @throws ProviderError
   */
  queryStakePools: (args: QueryStakePoolsArgs) => Promise<Paginated<Cardano.StakePool>>;
  /**
   * @returns {StakePoolStats} Stake pool stats
   */
  stakePoolStats: () => Promise<StakePoolStats>;
}
