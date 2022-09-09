import { Cardano, Provider } from '../../..';
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
  averages: {
    /**
     * Average margin of active stake pools in latest Epoch
     */
    margin: Cardano.Percent;
    /**
     * Average Annual Percentage Yield (APY)
     * of active stake pools in latest epoch
     */
    apy: Cardano.Percent;
  };
  qty: {
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
  queryStakePools: (args?: QueryStakePoolsArgs) => Promise<StakePoolSearchResults>;
  /**
   * @returns {StakePoolStats} Stake pool stats
   */
  stakePoolStats: () => Promise<StakePoolStats>;
}
