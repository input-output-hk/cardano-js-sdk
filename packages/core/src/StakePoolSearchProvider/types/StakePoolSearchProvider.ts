import { StakePool } from './StakePool';

export interface StakePoolSearchProvider {
  /**
   * @param {string[]} query an array of partial pool data: bech32 ID, name, ticker
   * @param {boolean} fetchExt load extended metadata if available
   * @returns Stake pools that match any fragment.
   * @throws ProviderError
   */
  queryStakePools: (fragments: string[], fetchExt?: boolean) => Promise<StakePool[]>;
}
