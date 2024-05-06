import { Cardano, Provider } from '../../..';
import { DeepPartial } from '@cardano-sdk/util';
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

/** Options for the fuzzy search on stake pool metadata */
export interface FuzzyOptions {
  /** Determines how close the match must be to the location. */
  distance: number;

  /** Determines how much the field length affects scoring. */
  fieldNormWeight: number;

  /** When `true`, the calculation for the relevance score will ignore `fieldNormWeight`. */
  ignoreFieldNorm: boolean;

  /** When `true`, search will ignore `location` and `distance`. */
  ignoreLocation: boolean;

  /** Determines approximately where in the text is the pattern expected to be found. */
  location: number;

  /** Only the matches whose length exceeds this value will be returned. */
  minMatchCharLength: number;

  /** Maximum threshold. `0`: exact match; `1`: match everything. */
  threshold: number;

  /** When `true`, it enables the use of unix-like search commands. */
  useExtendedSearch: boolean;

  /** Weights of metadata fields. Free positive values: they will be normalized internally. */
  weights: { description: number; homepage: number; name: number; poolId: number; ticker: number };
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

    /** Fuzzy search on text metadata fields. Ignored if shorter than 3 characters. If provided and valid, `identifier` is ignored. */
    text?: string;
  };

  /** Overrides default fuzzy options. Ignored in _live_ environments. */
  fuzzyOptions?: DeepPartial<FuzzyOptions>;

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
