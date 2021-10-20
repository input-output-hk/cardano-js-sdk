import { Cardano } from '@cardano-sdk/core';

export interface StakePoolSearchService {
  queryStakePools: (fragments: string[]) => Promise<Cardano.StakePool[]>;
}
