import { Cardano } from '@cardano-sdk/core';
import { InMemoryStabilityWindowBuffer } from '../../../src/sinks';
import { firstValueFrom, take, toArray } from 'rxjs';
import { sinks } from '../../../src';
import { stubBlockId } from '../../util';

const block = (slotNo: number) =>
  ({
    header: {
      hash: stubBlockId(slotNo),
      slot: Cardano.Slot(slotNo)
    }
  } as Cardano.Block);

describe('InMemoryStabilityWindowBuffer', () => {
  const networkInfo = {
    // stability window = 3 slots
    genesisParameters: {
      activeSlotsCoefficient: 1,
      securityParameter: 1
    } as Cardano.CompactGenesis
  };
  let buffer: sinks.InMemoryStabilityWindowBuffer;

  beforeEach(() => {
    buffer = new InMemoryStabilityWindowBuffer(networkInfo);
  });

  it('emits tip$ and tail$ when adding and deleting blocks', async () => {
    const tips = firstValueFrom(buffer.tip$.pipe(take(10), toArray()));
    const tails = firstValueFrom(buffer.tail$.pipe(take(5), toArray()));
    buffer.addStabilityWindowBlock(block(1));
    buffer.deleteStabilityWindowBlock(block(1));
    buffer.addStabilityWindowBlock(block(1));
    buffer.addStabilityWindowBlock(block(2));
    buffer.deleteStabilityWindowBlock(block(2));
    buffer.addStabilityWindowBlock(block(2));
    buffer.addStabilityWindowBlock(block(3));
    buffer.addStabilityWindowBlock(block(4));
    buffer.addStabilityWindowBlock(block(5));
    expect(await tips).toEqual([
      'origin',
      block(1),
      'origin',
      block(1),
      block(2),
      block(1),
      block(2),
      block(3),
      block(4),
      block(5)
    ]);
    expect(await tails).toEqual(['origin', block(1), 'origin', block(1), block(2)]);
  });
});
