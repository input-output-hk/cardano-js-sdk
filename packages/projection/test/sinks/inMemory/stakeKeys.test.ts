import * as Crypto from '@cardano-sdk/crypto';
import { ChainSyncEventType } from '@cardano-sdk/core';
import { defaultIfEmpty, firstValueFrom } from 'rxjs';
import { sinks } from '../../../src';
import { stakeKeys } from '../../../src/sinks/inMemory/stakeKeys';

describe('sinks/inMemory/stakeKeys', () => {
  it('adds a key on registration, removes on deregistration and inverses operations on rollbacks', async () => {
    const store: sinks.InMemoryStore = {
      stakeKeys: new Set(),
      stakePools: new Map()
    };
    const sink = async (
      eventType: ChainSyncEventType,
      register: Crypto.Ed25519KeyHashHex[],
      deregister: Crypto.Ed25519KeyHashHex[]
    ) => {
      await firstValueFrom(
        stakeKeys
          .sink({
            eventType,
            stakeKeys: { deregister: new Set(deregister), register: new Set(register) },
            store
            // eslint-disable-next-line @typescript-eslint/no-explicit-any
          } as any)
          .pipe(defaultIfEmpty(null))
      );
    };
    await sink(
      ChainSyncEventType.RollForward,
      [Crypto.Ed25519KeyHashHex('3b62970858d61cf667701c1f34abef41659516b191d7d374e8b0857b')],
      []
    );
    await sink(
      ChainSyncEventType.RollForward,
      [Crypto.Ed25519KeyHashHex('3b62970858d61cf667701c1f34abef41659516b191d7d374e8b0857c')],
      []
    );
    expect(store.stakeKeys.size).toBe(2);
    await sink(
      ChainSyncEventType.RollForward,
      [],
      [Crypto.Ed25519KeyHashHex('3b62970858d61cf667701c1f34abef41659516b191d7d374e8b0857c')]
    );
    expect(store.stakeKeys.size).toBe(1);
    await sink(
      ChainSyncEventType.RollBackward,
      [Crypto.Ed25519KeyHashHex('3b62970858d61cf667701c1f34abef41659516b191d7d374e8b0857b')],
      []
    );
    expect(store.stakeKeys.size).toBe(0);
    await sink(
      ChainSyncEventType.RollBackward,
      [],
      [Crypto.Ed25519KeyHashHex('3b62970858d61cf667701c1f34abef41659516b191d7d374e8b0857b')]
    );
    expect(store.stakeKeys.size).toBe(1);
  });
});
