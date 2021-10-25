import { Cardano } from '../..';

export interface StakePoolSearchProvider {
  /**
   * @param {string[]} query an array of partial pool data: bech32 ID, name, ticker
   * @returns Stake pools that match any fragment.
   * @throws ProviderError
   */
  queryStakePools: (fragments: string[]) => Promise<Cardano.StakePool[]>;
}
