import { Cardano, ChainSyncEventType } from '@cardano-sdk/core';
import { GranularSinkEvent, InMemory } from '../../../src';
import { PoolRetirement, PoolUpdate, WithCertificateSource } from '../../../src/operators';
import { firstValueFrom, of } from 'rxjs';
import { stakePools } from '../../../src/sinks/inMemory/stakePools';

describe('sinks/inMemory/stakePools', () => {
  it('adds pool updates and retirements on RollRorward, removes on RollBackward', async () => {
    const store = InMemory.createStore();
    const sink = async (
      eventType: ChainSyncEventType,
      slotNo: number,
      updates: PoolUpdate[],
      retirements: PoolRetirement[]
    ) => {
      await firstValueFrom(
        stakePools(
          of({
            block: {
              header: {
                slot: slotNo
              }
            },
            eventType,
            stakePools: { retirements, updates },
            store
          } as GranularSinkEvent<'stakePools', InMemory.WithInMemoryStore>)
        )
      );
    };
    const poolUpdateAtSlot1 = [
      {
        poolParameters: {
          id: Cardano.PoolId('pool1n3s8unkvmre59uzt4ned0903f9q2p8dhscw5v9eeyc0sw0m439t')
        } as Cardano.PoolParameters,
        source: { slot: Cardano.Slot(1) } as WithCertificateSource['source']
      }
    ];
    const poolRetirementAtSlot2 = [
      {
        epoch: Cardano.EpochNo(123),
        poolId: Cardano.PoolId('pool1n3s8unkvmre59uzt4ned0903f9q2p8dhscw5v9eeyc0sw0m439t'),
        source: { slot: Cardano.Slot(2) } as WithCertificateSource['source']
      }
    ];
    const storedStakePool = () =>
      store.stakePools.get(Cardano.PoolId('pool1n3s8unkvmre59uzt4ned0903f9q2p8dhscw5v9eeyc0sw0m439t'));

    await sink(ChainSyncEventType.RollForward, 1, poolUpdateAtSlot1, []);
    expect(store.stakePools.size).toBe(1);
    expect(storedStakePool()?.updates.length).toBe(1);
    await sink(ChainSyncEventType.RollForward, 2, [], poolRetirementAtSlot2);
    expect(storedStakePool()?.retirements.length).toBe(1);
    await sink(ChainSyncEventType.RollBackward, 2, [], poolRetirementAtSlot2);
    expect(storedStakePool()?.retirements.length).toBe(0);
    await sink(ChainSyncEventType.RollBackward, 1, poolUpdateAtSlot1, []);
    expect(storedStakePool()?.updates.length).toBe(0);
  });
});
