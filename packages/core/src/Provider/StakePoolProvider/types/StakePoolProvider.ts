import { Cardano } from '../../..';
import { SortFields } from '../util';

type FilterCondition = 'and' | 'or';
type SortOrder = 'asc' | 'desc';
export type SortField = typeof SortFields[number];
interface StakePoolSortOptions {
  order: SortOrder;
  field: SortField;
}

export interface MultipleChoiceSearchFilter<T> {
  /**
   * Defaults to 'or'
   */
  _condition?: FilterCondition;
  values: T[];
}

export interface StakePoolQueryOptions {
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
    identifier?: MultipleChoiceSearchFilter<
      Partial<Pick<Cardano.PoolParameters, 'id'> & Pick<Cardano.StakePoolMetadata, 'name' | 'ticker'>>
    >;
    pledgeMet?: boolean;
    status?: Cardano.StakePoolStatus[];
  };
  /**
   * Will fetch all stake pool reward history if not specified
   */
  rewardsHistoryLimit?: number;
  /**
   * Will return all stake pools matching the query if not specified
   */
  pagination?: {
    startAt: number;
    limit: number;
  };
}

export interface StakePoolSearchResults {
  pageResults: Cardano.StakePool[];
  totalResultCount: number;
}

export interface StakePoolStats {
  qty: {
    active: number;
    retired: number;
    retiring: number;
  };
}

export interface StakePoolProvider {
  /**
   * @param {StakePoolQueryOptions} options query options
   * @returns Stake pools
   * @throws ProviderError
   */
  queryStakePools: (options?: StakePoolQueryOptions) => Promise<StakePoolSearchResults>;
  /**
   * @returns {StakePoolStats} Stake pool stats
   */
  stakePoolStats: () => Promise<StakePoolStats>;
}
