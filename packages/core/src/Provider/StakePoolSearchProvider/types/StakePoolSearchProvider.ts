import { Cardano } from '../../..';

export interface StakePoolQueryOptions {
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

export interface StakePoolSearchProvider {
  /**
   * @param {string[]} query an array of partial pool data: bech32 ID, name, ticker
   * @param {StakePoolQueryOptions} options query options
   * @returns Stake pools that match any fragment
   * @throws ProviderError
   */
  queryStakePools: (fragments: string[], options?: StakePoolQueryOptions) => Promise<Cardano.StakePool[]>;
}
