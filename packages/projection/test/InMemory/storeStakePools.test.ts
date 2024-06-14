import { Cardano, ChainSyncEventType } from '@cardano-sdk/core';
import { InMemory, Mappers, ProjectionEvent } from '../../src';
import { firstValueFrom, of } from 'rxjs';

describe('InMemory.storeStakePools', () => {
  it('adds pool updates and retirements on RollForward, removes on RollBackward', async () => {
    const store = InMemory.createStore();
    const project = async (
      eventType: ChainSyncEventType,
      slotNo: number,
      updates: Mappers.PoolUpdate[],
      retirements: Mappers.PoolRetirement[]
    ) => {
      await firstValueFrom(
        InMemory.storeStakePools()(
          of({
            block: {
              header: {
                slot: slotNo
              }
            },
            eventType,
            stakePools: { retirements, updates },
            store
          } as ProjectionEvent<InMemory.WithInMemoryStore & Mappers.WithStakePools>)
        )
      );
    };
    const poolUpdateAtSlot1 = [
      {
        poolParameters: {
          id: Cardano.PoolId('pool1n3s8unkvmre59uzt4ned0903f9q2p8dhscw5v9eeyc0sw0m439t')
        } as Cardano.PoolParameters,
        source: { slot: Cardano.Slot(1) } as Mappers.WithCertificateSource['source']
      }
    ];
    const poolRetirementAtSlot2 = [
      {
        epoch: Cardano.EpochNo(123),
        poolId: Cardano.PoolId('pool1n3s8unkvmre59uzt4ned0903f9q2p8dhscw5v9eeyc0sw0m439t'),
        source: { slot: Cardano.Slot(2) } as Mappers.WithCertificateSource['source']
      }
    ];
    const storedStakePool = () =>
      store.stakePools.get(Cardano.PoolId('pool1n3s8unkvmre59uzt4ned0903f9q2p8dhscw5v9eeyc0sw0m439t'));

    await project(ChainSyncEventType.RollForward, 1, poolUpdateAtSlot1, []);
    expect(store.stakePools.size).toBe(1);
    expect(storedStakePool()?.updates.length).toBe(1);
    await project(ChainSyncEventType.RollForward, 2, [], poolRetirementAtSlot2);
    expect(storedStakePool()?.retirements.length).toBe(1);
    await project(ChainSyncEventType.RollBackward, 2, [], poolRetirementAtSlot2);
    expect(storedStakePool()?.retirements.length).toBe(0);
    await project(ChainSyncEventType.RollBackward, 1, poolUpdateAtSlot1, []);
    expect(storedStakePool()?.updates.length).toBe(0);
  });
});
