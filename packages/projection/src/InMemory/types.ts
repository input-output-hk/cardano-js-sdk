import type { Cardano } from '@cardano-sdk/core';
import type { Ed25519KeyHashHex } from '@cardano-sdk/crypto';
import type { Mappers } from '../operators/index.js';

export type InMemoryStore = {
  stakeKeys: Set<Ed25519KeyHashHex>;
  stakePools: Map<
    Cardano.PoolId,
    {
      updates: Array<Mappers.PoolUpdate>;
      retirements: Array<Mappers.PoolRetirement>;
    }
  >;
};

export type WithInMemoryStore = {
  store: InMemoryStore;
};
