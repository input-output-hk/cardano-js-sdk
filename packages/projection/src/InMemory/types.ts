import { Cardano } from '@cardano-sdk/core';
import { Ed25519KeyHashHex } from '@cardano-sdk/crypto';
import { PoolRetirement, PoolUpdate } from '../Operators';

export type InMemoryStore = {
  stakeKeys: Set<Ed25519KeyHashHex>;
  stakePools: Map<
    Cardano.PoolId,
    {
      updates: PoolUpdate[];
      retirements: PoolRetirement[];
    }
  >;
};

export type WithInMemoryStore = {
  store: InMemoryStore;
};
