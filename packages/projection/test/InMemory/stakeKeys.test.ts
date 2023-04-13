import * as Crypto from '@cardano-sdk/crypto';
import { ChainSyncEventType } from '@cardano-sdk/core';
import { InMemory, Operators, ProjectionEvent } from '../../src';
import { firstValueFrom, of } from 'rxjs';

describe('InMemory.storeStakeKeys', () => {
  it('adds a key on registration, removes on deregistration and inverses operations on rollbacks', async () => {
    const store = InMemory.createStore();
    const project = async (
      eventType: ChainSyncEventType,
      register: Crypto.Ed25519KeyHashHex[],
      deregister: Crypto.Ed25519KeyHashHex[]
    ) => {
      await firstValueFrom(
        InMemory.storeStakeKeys()(
          of({
            eventType,
            stakeKeys: {
              del: eventType === ChainSyncEventType.RollForward ? deregister : register,
              insert: eventType === ChainSyncEventType.RollForward ? register : deregister
            },
            store
          } as ProjectionEvent<InMemory.WithInMemoryStore & Operators.WithStakeKeys>)
        )
      );
    };
    await project(
      ChainSyncEventType.RollForward,
      [Crypto.Ed25519KeyHashHex('3b62970858d61cf667701c1f34abef41659516b191d7d374e8b0857b')],
      []
    );
    await project(
      ChainSyncEventType.RollForward,
      [Crypto.Ed25519KeyHashHex('3b62970858d61cf667701c1f34abef41659516b191d7d374e8b0857c')],
      []
    );
    expect(store.stakeKeys.size).toBe(2);
    await project(
      ChainSyncEventType.RollForward,
      [],
      [Crypto.Ed25519KeyHashHex('3b62970858d61cf667701c1f34abef41659516b191d7d374e8b0857c')]
    );
    expect(store.stakeKeys.size).toBe(1);
    await project(
      ChainSyncEventType.RollBackward,
      [Crypto.Ed25519KeyHashHex('3b62970858d61cf667701c1f34abef41659516b191d7d374e8b0857b')],
      []
    );
    expect(store.stakeKeys.size).toBe(0);
    await project(
      ChainSyncEventType.RollBackward,
      [],
      [Crypto.Ed25519KeyHashHex('3b62970858d61cf667701c1f34abef41659516b191d7d374e8b0857b')]
    );
    expect(store.stakeKeys.size).toBe(1);
  });
});
