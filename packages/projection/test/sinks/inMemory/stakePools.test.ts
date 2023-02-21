import { Cardano, ChainSyncEventType } from '@cardano-sdk/core';
import { InMemory } from '../../../src';
import { PoolRetirement, PoolUpdate, WithCertificateSource } from '../../../src/operators';
import { defaultIfEmpty, firstValueFrom } from 'rxjs';
import { stakePools } from '../../../src/sinks/inMemory/stakePools';

describe('sinks/inMemory/stakePools', () => {
  it('adds pool updates and retirements on RollRorward, removes on RollBackward', async () => {
    const store = InMemory.createStore();
    const sink = async (
      eventType: ChainSyncEventType,
      slotNo: number,
      updates: Map<Cardano.PoolId, PoolUpdate[]>,
      retirements: Map<Cardano.PoolId, PoolRetirement[]>
    ) => {
      await firstValueFrom(
        stakePools
          .sink({
            block: {
              header: {
                slot: slotNo
              }
            },
            eventType,
            stakePools: { retirements, updates },
            store
            // eslint-disable-next-line @typescript-eslint/no-explicit-any
          } as any)
          .pipe(defaultIfEmpty(null))
      );
    };
    const poolUpdateAtSlot1 = new Map([
      [
        Cardano.PoolId('pool1n3s8unkvmre59uzt4ned0903f9q2p8dhscw5v9eeyc0sw0m439t'),
        [
          {
            issuedAtEpochNo: Cardano.EpochNo(1),
            poolParameters: {} as Cardano.PoolParameters,
            source: { slot: Cardano.Slot(1) } as WithCertificateSource['source']
          }
        ]
      ]
    ]);
    const poolRetirementAtSlot2 = new Map([
      [
        Cardano.PoolId('pool1n3s8unkvmre59uzt4ned0903f9q2p8dhscw5v9eeyc0sw0m439t'),
        [
          {
            retireAtEpoch: Cardano.EpochNo(3),
            source: { slot: Cardano.Slot(2) } as WithCertificateSource['source']
          }
        ]
      ]
    ]);
    const storedStakePool = () =>
      store.stakePools.get(Cardano.PoolId('pool1n3s8unkvmre59uzt4ned0903f9q2p8dhscw5v9eeyc0sw0m439t'));

    await sink(ChainSyncEventType.RollForward, 1, poolUpdateAtSlot1, new Map());
    expect(store.stakePools.size).toBe(1);
    expect(storedStakePool()?.updates.length).toBe(1);
    await sink(ChainSyncEventType.RollForward, 2, new Map(), poolRetirementAtSlot2);
    expect(storedStakePool()?.retirements.length).toBe(1);
    await sink(ChainSyncEventType.RollBackward, 2, new Map(), poolRetirementAtSlot2);
    expect(storedStakePool()?.retirements.length).toBe(0);
    await sink(ChainSyncEventType.RollBackward, 1, poolUpdateAtSlot1, new Map());
    expect(storedStakePool()?.updates.length).toBe(0);
  });
});
