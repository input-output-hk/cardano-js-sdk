import { Cardano, Seconds } from '@cardano-sdk/core';
import { sinks, RollForwardEvent } from '../../../src';
import { WithNetworkInfo } from '../../../src/operators';
import { firstValueFrom, take, toArray } from 'rxjs';
import { genesisToEraSummary } from '../../events/genesisToEraSummary';
import { stubBlockId } from '../../util';

const genesisParameters = {
  // stability window = 2 blocks
  activeSlotsCoefficient: 2,
  securityParameter: 2,
  // slotLength is only needed for test setup (genesisToEraSummary)
  slotLength: Seconds(1)
} as Cardano.CompactGenesis;

const event = (slotNo: number) =>
  ({
    block: {
      header: {
        hash: stubBlockId(slotNo),
        slot: Cardano.Slot(slotNo)
      }
    },
    eraSummaries: [genesisToEraSummary(genesisParameters)],
    genesisParameters
  } as RollForwardEvent<WithNetworkInfo>);

describe('InMemoryStabilityWindowBuffer', () => {
  let buffer: sinks.InMemoryStabilityWindowBuffer<WithNetworkInfo>;

  beforeEach(() => {
    buffer = new sinks.InMemoryStabilityWindowBuffer<WithNetworkInfo>();
  });

  it('emits tip$ and tail$ when adding and deleting blocks', async () => {
    const tips = firstValueFrom(buffer.tip$.pipe(take(10), toArray()));
    const tails = firstValueFrom(buffer.tail$.pipe(take(5), toArray()));
    buffer.rollForward(event(1));
    buffer.deleteBlock(event(1).block);
    buffer.rollForward(event(1));
    buffer.rollForward(event(2));
    buffer.deleteBlock(event(2).block);
    buffer.rollForward(event(2));
    buffer.rollForward(event(3));
    buffer.rollForward(event(4));
    buffer.rollForward(event(5));
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
