import { Cardano, ChainSyncEventType, Seconds } from '@cardano-sdk/core';
import { InMemory } from '../../src/index.js';
import { firstValueFrom, from } from 'rxjs';
import { genesisToEraSummary } from '@cardano-sdk/util-dev';
import { stubBlockId } from '../util.js';
import type { UnifiedExtChainSyncEvent, WithNetworkInfo } from '../../src/index.js';

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

  describe('getBlock', () => {
    it('emits the block when it exists in the buffer', async () => {
      buffer
        .handleEvents()(from([event(1, ChainSyncEventType.RollForward)]))
        .subscribe();
      await expect(firstValueFrom(buffer.getBlock(stubBlockId(1)))).resolves.not.toBeNull();
    });

    it('emits `null` when block does not exist in the buffer', async () => {
      buffer
        .handleEvents()(from([event(1, ChainSyncEventType.RollForward), event(1, ChainSyncEventType.RollBackward)]))
        .subscribe();
      await expect(firstValueFrom(buffer.getBlock(stubBlockId(1)))).resolves.toBeNull();
    });
  });
});
