import { Cardano } from '@cardano-sdk/core';
import { PoolRetirement, PoolUpdate } from '../../operators';

export type InMemoryStore = {
  stakeKeys: Set<Cardano.Ed25519KeyHash>;
  stakePools: Map<
    Cardano.PoolId,
    {
      updates: PoolUpdate[];
      retirements: PoolRetirement[];
    }
  >;
  adaHandles: Map<Cardano.Address, string>;
};

export type WithInMemoryStore = {
  store: InMemoryStore;
};
