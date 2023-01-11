import { Cardano, ChainSyncEventType } from '@cardano-sdk/core';
import { InMemoryStore } from '../../../src/sinks';
import { defaultIfEmpty, firstValueFrom } from 'rxjs';
import { stakeKeys } from '../../../src/sinks/inMemory/stakeKeys';

describe('sinks/inMemory/stakeKeys', () => {
  it('adds a key on registration, removes on deregistration and inverses operations on rollbacks', async () => {
    const store: InMemoryStore = {
      stakeKeys: new Set(),
      stakePools: new Map()
    };
    const sink = async (
      eventType: ChainSyncEventType,
      register: Cardano.Ed25519KeyHash[],
      deregister: Cardano.Ed25519KeyHash[]
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
      [Cardano.Ed25519KeyHash('3b62970858d61cf667701c1f34abef41659516b191d7d374e8b0857b')],
      []
    );
    await sink(
      ChainSyncEventType.RollForward,
      [Cardano.Ed25519KeyHash('3b62970858d61cf667701c1f34abef41659516b191d7d374e8b0857c')],
      []
    );
    expect(store.stakeKeys.size).toBe(2);
    await sink(
      ChainSyncEventType.RollForward,
      [],
      [Cardano.Ed25519KeyHash('3b62970858d61cf667701c1f34abef41659516b191d7d374e8b0857c')]
    );
    expect(store.stakeKeys.size).toBe(1);
    await sink(
      ChainSyncEventType.RollBackward,
      [Cardano.Ed25519KeyHash('3b62970858d61cf667701c1f34abef41659516b191d7d374e8b0857b')],
      []
    );
    expect(store.stakeKeys.size).toBe(0);
    await sink(
      ChainSyncEventType.RollBackward,
      [],
      [Cardano.Ed25519KeyHash('3b62970858d61cf667701c1f34abef41659516b191d7d374e8b0857b')]
    );
    expect(store.stakeKeys.size).toBe(1);
  });
});
