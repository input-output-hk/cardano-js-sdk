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
  /** Defaults to `'or'`. */
  _condition?: FilterCondition;
  values: T[];
}

/** The StakePoolProvider.queryStakePools call arguments. */
export interface QueryStakePoolsArgs {
  /** Will return all stake pools sorted by name ascending if not specified. */
  sort?: StakePoolSortOptions;

  /** Will fetch all stake pools if not specified. */
  filters?: {
    /** Defaults to `'and'`. */
    _condition?: FilterCondition;

    /** Will return results for partial matches. */
    identifier?: MultipleChoiceSearchFilter<FilterIdentifiers>;

    /** If provided, returns all the pools which live stake meets / do not meets the pledge. */
    pledgeMet?: boolean;

    /** If provided, returns all the pools in any of the given status. */
    status?: Cardano.StakePoolStatus[];
  };

  /**
   * Used for APY metric computation. It will take 3 epochs back if not specified.
   *
   * @deprecated Use `epochsLength` instead
   */
  apyEpochsBackLimit?: number;

  /** If not `true`, `StakePool.rewardHistory` is `undefined`. */
  epochRewards?: boolean;

  /**
   * Controls the `StakePool.rewardHistory` and `StakePoolMetrics.lastRos` properties of the response.
   *
   * If `undefined`, `StakePool.rewardHistory` contains last `LAST_ROS_EPOCHS` elements and
   * `StakePoolMetrics.lastRos` is the **ROS in** `LAST_ROS_EPOCHS` **epochs** of the stake pool; otherwise
   * `StakePool.rewardHistory` contains the requested history and `StakePoolMetrics.ros` is
   * the **ROS in the requested time interval**.
   */
  epochsLength?: number;

  /** The configuration for paged result. */
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
