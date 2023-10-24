import { Cardano } from '@cardano-sdk/core';
import { Ed25519KeyHashHex } from '@cardano-sdk/crypto';
import { Mappers } from '../operators';

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
