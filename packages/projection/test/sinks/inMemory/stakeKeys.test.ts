import * as Crypto from '@cardano-sdk/crypto';
import { ChainSyncEventType } from '@cardano-sdk/core';
import { GranularSinkEvent, InMemory } from '../../../src';
import { firstValueFrom, of } from 'rxjs';
import { stakeKeys } from '../../../src/sinks/inMemory/stakeKeys';

describe('sinks/inMemory/stakeKeys', () => {
  it('adds a key on registration, removes on deregistration and inverses operations on rollbacks', async () => {
    const store = InMemory.createStore();
    const sink = async (
      eventType: ChainSyncEventType,
      register: Crypto.Ed25519KeyHashHex[],
      deregister: Crypto.Ed25519KeyHashHex[]
    ) => {
      await firstValueFrom(
        stakeKeys(
          of({
            eventType,
            stakeKeys: {
              del: eventType === ChainSyncEventType.RollForward ? deregister : register,
              insert: eventType === ChainSyncEventType.RollForward ? register : deregister
            },
            store
          } as GranularSinkEvent<'stakeKeys', InMemory.WithInMemoryStore>)
        )
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
