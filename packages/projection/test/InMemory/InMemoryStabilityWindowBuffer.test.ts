import { Cardano, ChainSyncEventType, Seconds } from '@cardano-sdk/core';
import { InMemory, UnifiedExtChainSyncEvent, WithNetworkInfo } from '../../src';
import { firstValueFrom, from, take, toArray } from 'rxjs';
import { genesisToEraSummary } from '@cardano-sdk/util-dev';
import { stubBlockId } from '../util';

const genesisParameters = {
  // stability window = 2 blocks
  activeSlotsCoefficient: 2,
  securityParameter: 2,
  // slotLength is only needed for test setup (genesisToEraSummary)
  slotLength: Seconds(1)
} as Cardano.CompactGenesis;

const event = (slotNo: number, eventType?: ChainSyncEventType) =>
  ({
    block: {
      header: {
        hash: stubBlockId(slotNo),
        slot: Cardano.Slot(slotNo)
      }
    },
    eraSummaries: [genesisToEraSummary(genesisParameters)],
    eventType,
    genesisParameters
  } as UnifiedExtChainSyncEvent<WithNetworkInfo>);

describe('InMemory.InMemoryStabilityWindowBuffer', () => {
  let buffer: InMemory.InMemoryStabilityWindowBuffer;

  beforeEach(() => {
    buffer = new InMemory.InMemoryStabilityWindowBuffer();
  });

  it('emits tip$ and tail$ when adding and deleting blocks', async () => {
    const tips = firstValueFrom(buffer.tip$.pipe(take(10), toArray()));
    const tails = firstValueFrom(buffer.tail$.pipe(take(5), toArray()));
    buffer
      .handleEvents()(
        from([
          event(1, ChainSyncEventType.RollForward),
          event(1, ChainSyncEventType.RollBackward),
          event(1, ChainSyncEventType.RollForward),
          event(2, ChainSyncEventType.RollForward),
          event(2, ChainSyncEventType.RollBackward),
          event(2, ChainSyncEventType.RollForward),
          event(3, ChainSyncEventType.RollForward),
          event(4, ChainSyncEventType.RollForward),
          event(5, ChainSyncEventType.RollForward)
        ])
      )
      .subscribe();
    expect(await tips).toEqual([
      'origin',
      event(1).block,
      'origin',
      event(1).block,
      event(2).block,
      event(1).block,
      event(2).block,
      event(3).block,
      event(4).block,
      event(5).block
    ]);
    expect(await tails).toEqual(['origin', event(1).block, 'origin', event(1).block, event(2).block]);
  });
});
