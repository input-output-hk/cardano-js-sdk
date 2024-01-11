/* eslint-disable unicorn/consistent-function-scoping */
/* eslint-disable sonarjs/no-duplicate-string */
import {
  Cardano,
  EpochInfo,
  EraSummary,
  EraSummaryError,
  Milliseconds,
  SlotEpochCalc,
  SlotEpochInfoCalc,
  SlotTimeCalc,
  createSlotEpochCalc,
  createSlotEpochInfoCalc,
  createSlotTimeCalc,
  epochSlotsCalc
} from '../../src';
import { fromSerializableObject } from '@cardano-sdk/util';

import merge from 'lodash/merge';

// Era summaries copied from util-dev package.
// Importing directly from util-dev reports Milliseconds types incompatible.
// Type 'import("core/dist/cjs/util/time").Milliseconds' is not assignable to type
// 'import("core/src/util/time").Milliseconds'.
// Property '__opaqueNumber' is protected but type 'OpaqueNumber<T>' is not a class derived from 'OpaqueNumber<T>'.
// Duplicating the test era summaries here to work around it.

export const testnetEraSummaries: EraSummary[] = [
  {
    parameters: { epochLength: 21_600, slotLength: Milliseconds(20_000) },
    start: { slot: 0, time: new Date(1_563_999_616_000) }
  },
  {
    parameters: { epochLength: 432_000, slotLength: Milliseconds(1000) },
    start: { slot: 1_598_400, time: new Date(1_595_967_616_000) }
  }
];

// Valid at 2023-03
const preprodEraSummaries: EraSummary[] = [
  {
    parameters: { epochLength: 21_600, slotLength: Milliseconds(20_000) },
    start: { slot: 0, time: new Date('2022-06-01T00:00:00.000Z') }
  },
  {
    parameters: { epochLength: 432_000, slotLength: Milliseconds(1000) },
    start: { slot: 86_400, time: new Date('2022-06-21T00:00:00.000Z') }
  },
  {
    parameters: { epochLength: 432_000, slotLength: Milliseconds(1000) },
    start: { slot: 518_400, time: new Date('2022-06-26T00:00:00.000Z') }
  },
  {
    parameters: { epochLength: 432_000, slotLength: Milliseconds(1000) },
    start: { slot: 950_400, time: new Date('2022-07-01T00:00:00.000Z') }
  },
  {
    parameters: { epochLength: 432_000, slotLength: Milliseconds(1000) },
    start: { slot: 1_382_400, time: new Date('2022-07-06T00:00:00.000Z') }
  },
  {
    parameters: { epochLength: 432_000, slotLength: Milliseconds(1000) },
    start: { slot: 3_542_400, time: new Date('2022-07-31T00:00:00.000Z') }
  }
];

// Produced on 2023-12-19
export const previewEraSummaries = fromSerializableObject<EraSummary[]>([
  {
    parameters: { epochLength: 4320, slotLength: 20_000 },
    start: { slot: 0, time: { __type: 'Date', value: 1_666_656_000_000 } }
  },
  {
    parameters: { epochLength: 86_400, slotLength: 1000 },
    start: { slot: 0, time: { __type: 'Date', value: 1_666_656_000_000 } }
  },
  {
    parameters: { epochLength: 86_400, slotLength: 1000 },
    start: { slot: 0, time: { __type: 'Date', value: 1_666_656_000_000 } }
  },
  {
    parameters: { epochLength: 86_400, slotLength: 1000 },
    start: { slot: 0, time: { __type: 'Date', value: 1_666_656_000_000 } }
  },
  {
    parameters: { epochLength: 86_400, slotLength: 1000 },
    start: { slot: 0, time: { __type: 'Date', value: 1_666_656_000_000 } }
  },
  {
    parameters: { epochLength: 86_400, slotLength: 1000 },
    start: { slot: 259_200, time: { __type: 'Date', value: 1_666_915_200_000 } }
  }
]);

const SomeByronSlot = Cardano.Slot(1_209_592);

describe('slotCalc utils', () => {
  describe('preview', () => {
    // following test data is taken from last block of epoch 418
    // https://preview.cexplorer.io/block/b25f4238b9d9d70a2942d277baf2312cc0562990e38b2ce5888861454e05e6c4
    const testEpoch = Cardano.EpochNo(418);
    const testSlot = Cardano.Slot(36_201_583);
    const testDate = new Date('2023-12-17T23:59:43Z');
    it('epochSlotsCalc correctly computes last slot of epoch 418', () => {
      const range = epochSlotsCalc(testEpoch, previewEraSummaries);
      expect(range.lastSlot).toBeGreaterThanOrEqual(testSlot);
    });
    it('slotEpochCalc correctly computes epoch 418 from its last slot', () => {
      const slotEpochCalc = createSlotEpochCalc(previewEraSummaries);
      expect(slotEpochCalc(testSlot)).toEqual(testEpoch);
    });
    it('slotTimeCalc correctly computes the time last slot of epoch 418', () => {
      const slotTimeCalc = createSlotTimeCalc(previewEraSummaries);
      expect(slotTimeCalc(testSlot)).toEqual(testDate);
    });
    it('slotEpochInfoCalc correctly computes info for last slot of epoch 418', () => {
      const slotEpochInfoCalc = createSlotEpochInfoCalc(previewEraSummaries);
      const result = slotEpochInfoCalc(testSlot);
      expect(result.epochNo).toEqual(testEpoch);
      expect(result.lastSlot.date.getTime()).toBeGreaterThanOrEqual(testDate.getTime());
      expect(result.lastSlot.slot).toBeGreaterThanOrEqual(testSlot);
    });
  });
  describe('epochStartCalc', () => {
    describe('preprod', () => {
      it('correctly computes 1st slot of the 0th epoch', () => {
        const { eraSummary, firstSlot, lastSlot } = epochSlotsCalc(Cardano.EpochNo(0), preprodEraSummaries);
        expect(eraSummary).toBe(preprodEraSummaries[0]);
        expect(firstSlot).toBe(0);
        expect(lastSlot).toBe(21_599);
      });

      it('correctly computes 1st slot of some Byron epoch', () => {
        const { eraSummary, firstSlot, lastSlot } = epochSlotsCalc(Cardano.EpochNo(2), preprodEraSummaries);
        expect(eraSummary).toBe(preprodEraSummaries[0]);
        expect(firstSlot).toBe(43_200);
        expect(lastSlot).toBe(64_799);
      });

      it('correctly computes 1st slot of last Byron epoch', () => {
        const { eraSummary, firstSlot, lastSlot } = epochSlotsCalc(Cardano.EpochNo(3), preprodEraSummaries);
        expect(eraSummary).toBe(preprodEraSummaries[0]);
        expect(firstSlot).toBe(64_800);
        expect(lastSlot).toBe(86_399);
      });

      it('correctly computes 1st slot of first Shelley epoch', () => {
        const { eraSummary, firstSlot, lastSlot } = epochSlotsCalc(Cardano.EpochNo(4), preprodEraSummaries);
        expect(eraSummary).toBe(preprodEraSummaries[1]);
        expect(firstSlot).toBe(86_400);
        expect(lastSlot).toBe(518_399);
      });

      it('correctly computes 1st slot of some epoch in the middle of era summaries', () => {
        const { eraSummary, firstSlot, lastSlot } = epochSlotsCalc(Cardano.EpochNo(5), preprodEraSummaries);
        expect(eraSummary).toBe(preprodEraSummaries[2]);
        expect(firstSlot).toBe(518_400);
        expect(lastSlot).toBe(950_399);
      });

      it('correctly computes 1st slot of some epoch of the last era summary and aligns with epochSlotCalc', () => {
        const epoch = Cardano.EpochNo(20);
        const expectedFirstSlot = Cardano.Slot(6_998_400);
        const expectedLastSlot = Cardano.Slot(7_430_399);
        const { eraSummary, firstSlot, lastSlot } = epochSlotsCalc(epoch, preprodEraSummaries);
        expect(eraSummary).toBe(preprodEraSummaries[5]);
        expect(firstSlot).toBe(expectedFirstSlot);
        expect(lastSlot).toBe(expectedLastSlot);
        const epochSlotCalc = createSlotEpochCalc(preprodEraSummaries);
        expect(epochSlotCalc(expectedFirstSlot)).toEqual(epoch);
        expect(epochSlotCalc(Cardano.Slot(expectedFirstSlot - 1))).toEqual(epoch - 1);
        expect(epochSlotCalc(expectedLastSlot)).toEqual(epoch);
        expect(epochSlotCalc(Cardano.Slot(expectedLastSlot + 1))).toEqual(epoch + 1);
      });
    });
  });

  describe('slotTimeCalc', () => {
    describe('testnet', () => {
      const slotTimeCalc: SlotTimeCalc = createSlotTimeCalc(testnetEraSummaries);

      it('correctly computes date of the 1st block', () =>
        expect(slotTimeCalc(Cardano.Slot(1031))).toEqual(new Date(1_564_020_236_000)));

      it('correctly computes date of the genesis block', () =>
        expect(slotTimeCalc(Cardano.Slot(0))).toEqual(new Date(1_563_999_616_000)));

      it('correctly computes date of some Byron block', () =>
        expect(slotTimeCalc(SomeByronSlot)).toEqual(new Date(1_588_191_456_000)));

      it('correctly computes date of the last Byron block', () =>
        expect(slotTimeCalc(Cardano.Slot(1_598_399))).toEqual(new Date(1_595_967_596_000)));

      it('correctly computes date of the 1st Shelley block', () =>
        expect(slotTimeCalc(Cardano.Slot(1_598_400))).toEqual(new Date('2020/07/28 20:20:16 UTC')));

      it('correctly computes date of the 2nd Shelley block', () =>
        expect(slotTimeCalc(Cardano.Slot(1_598_420))).toEqual(new Date('2020/07/28 20:20:36 UTC')));

      it('correctly computes date of some Shelley block', () =>
        expect(slotTimeCalc(Cardano.Slot(8_078_371))).toEqual(new Date(new Date('2020/10/11 20:19:47 UTC'))));

      it('correctly computes date of some Alonzo block', () =>
        expect(slotTimeCalc(Cardano.Slot(67_951_416))).toEqual(new Date('2022-09-04 19:43:52 UTC')));

      it('throws with invalid slot', () => expect(() => slotTimeCalc(Cardano.Slot(-1))).toThrowError(EraSummaryError));
    });

    it('throws with invalid EraSummary', () => {
      const slotTimeCalc = createSlotTimeCalc([
        merge({}, testnetEraSummaries[0], { parameters: { slotLength: 1 }, start: { slot: 5, time: new Date() } })
      ]);
      expect(() => slotTimeCalc(Cardano.Slot(4))).toThrowError(EraSummaryError);
    });
  });

  describe('slotEpochCalc', () => {
    describe('testnet with auto-upgrading eras', () => {
      it('correctly computes epoch with multiple summaries starting from genesis', () => {
        const eraSummaries: EraSummary[] = [
          {
            parameters: { epochLength: 100, slotLength: Milliseconds(3) },
            start: { slot: 0, time: new Date(1_563_999_616_000) }
          },
          {
            parameters: { epochLength: 200, slotLength: Milliseconds(10) },
            start: { slot: 0, time: new Date(1_563_999_616_000) }
          },
          {
            parameters: { epochLength: 200, slotLength: Milliseconds(1) },
            start: { slot: 0, time: new Date(1_563_999_616_000) }
          }
        ];
        const slotEpochCalc: SlotEpochCalc = createSlotEpochCalc(eraSummaries);

        expect(slotEpochCalc(Cardano.Slot(1031))).toEqual(5);
      });
      it('correctly computes epoch with summaries indicating an upgrade after genesis, from the same slotNo', () => {
        const eraSummaries: EraSummary[] = [
          {
            parameters: { epochLength: 100, slotLength: Milliseconds(3) },
            start: { slot: 0, time: new Date(1_563_999_616_000) }
          },
          {
            parameters: { epochLength: 200, slotLength: Milliseconds(10) },
            start: { slot: 301, time: new Date(1_563_999_716_000) }
          },
          {
            parameters: { epochLength: 200, slotLength: Milliseconds(1) },
            start: { slot: 301, time: new Date(1_563_999_716_000) }
          }
        ];
        const slotEpochCalc: SlotEpochCalc = createSlotEpochCalc(eraSummaries);

        expect(slotEpochCalc(Cardano.Slot(1031))).toEqual(6);
      });
    });
    describe('testnet', () => {
      const slotEpochCalc: SlotEpochCalc = createSlotEpochCalc(testnetEraSummaries);

      it('correctly computes epoch of the 1st block', () => expect(slotEpochCalc(Cardano.Slot(1031))).toEqual(0));

      it('correctly computes epoch of the genesis block', () => expect(slotEpochCalc(Cardano.Slot(0))).toBe(0));

      it('correctly computes epoch of some Byron block', () => expect(slotEpochCalc(Cardano.Slot(1_209_592))).toBe(55));

      it('correctly computes epoch of the last Byron block', () =>
        expect(slotEpochCalc(Cardano.Slot(1_598_399))).toBe(73));

      it('correctly computes epoch of the 1st Shelley block', () =>
        expect(slotEpochCalc(Cardano.Slot(1_598_400))).toBe(74));

      it('correctly computes epoch of the 2nd Shelley block', () =>
        expect(slotEpochCalc(Cardano.Slot(1_598_420))).toBe(74));

      it('correctly computes epoch of some Shelley block', () =>
        expect(slotEpochCalc(Cardano.Slot(8_078_371))).toBe(88));

      it('throws with invalid slot', () => expect(() => slotEpochCalc(Cardano.Slot(-1))).toThrowError(EraSummaryError));
    });

    it('throws with invalid EraSummary', () => {
      const slotEpochCalc = createSlotEpochCalc([merge({}, testnetEraSummaries[0], { start: { slot: 5 } })]);
      expect(() => slotEpochCalc(Cardano.Slot(4))).toThrowError(EraSummaryError);
    });
  });

  describe('slotEpochInfoCalc ', () => {
    describe('testnet', () => {
      const slotEpochInfoCalc: SlotEpochInfoCalc = createSlotEpochInfoCalc(testnetEraSummaries);
      const byronEraSummary = {
        ...testnetEraSummaries[0],
        firstEpoch: 0
      };
      const shelleyEraSummary = {
        ...testnetEraSummaries[1],
        firstEpoch: 74
      };

      const assertNthEpochInfoValid = (
        expectedEpochNo: Cardano.EpochNo,
        { epochNo, firstSlot, lastSlot }: EpochInfo,
        epochEraSummary: EraSummary & { firstEpoch: number }
      ) => {
        expect(epochNo).toEqual(expectedEpochNo);
        const relativeEpoch = expectedEpochNo - epochEraSummary.firstEpoch;
        expect(firstSlot).toEqual({
          date: new Date(
            epochEraSummary.start.time.getTime() +
              epochEraSummary.parameters.epochLength * epochEraSummary.parameters.slotLength * relativeEpoch
          ),
          slot: epochEraSummary.start.slot + epochEraSummary.parameters.epochLength * relativeEpoch
        });
        expect(lastSlot).toEqual({
          date: new Date(
            epochEraSummary.start.time.getTime() +
              epochEraSummary.parameters.epochLength * epochEraSummary.parameters.slotLength * (relativeEpoch + 1) -
              epochEraSummary.parameters.slotLength
          ),
          slot: epochEraSummary.start.slot + epochEraSummary.parameters.epochLength * (relativeEpoch + 1) - 1
        });
      };

      it('correctly computes epoch info of the 1st block', () => {
        assertNthEpochInfoValid(Cardano.EpochNo(0), slotEpochInfoCalc(Cardano.Slot(1031)), byronEraSummary);
      });

      it('correctly computes epoch info of the genesis block', () => {
        assertNthEpochInfoValid(Cardano.EpochNo(0), slotEpochInfoCalc(Cardano.Slot(0)), byronEraSummary);
      });

      it('correctly computes epoch info of some Byron block', () => {
        assertNthEpochInfoValid(Cardano.EpochNo(55), slotEpochInfoCalc(Cardano.Slot(1_209_592)), byronEraSummary);
      });

      it('correctly computes epoch info of the last Byron block', () => {
        assertNthEpochInfoValid(Cardano.EpochNo(73), slotEpochInfoCalc(Cardano.Slot(1_598_399)), byronEraSummary);
      });

      it('correctly computes epoch info of the 1st Shelley block', () => {
        assertNthEpochInfoValid(Cardano.EpochNo(74), slotEpochInfoCalc(Cardano.Slot(1_598_400)), shelleyEraSummary);
      });

      it('correctly computes epoch info of the 2nd Shelley block', () => {
        assertNthEpochInfoValid(Cardano.EpochNo(74), slotEpochInfoCalc(Cardano.Slot(1_598_420)), shelleyEraSummary);
      });

      it('correctly computes epoch of info some Shelley block', () => {
        assertNthEpochInfoValid(Cardano.EpochNo(88), slotEpochInfoCalc(Cardano.Slot(8_078_371)), shelleyEraSummary);
      });

      it('throws with invalid slot', () =>
        expect(() => slotEpochInfoCalc(Cardano.Slot(-1))).toThrowError(EraSummaryError));
    });

    it('throws with invalid EraSummary', () => {
      const slotEpochInfoCalc = createSlotEpochInfoCalc([merge({}, testnetEraSummaries[0], { start: { slot: 5 } })]);
      expect(() => slotEpochInfoCalc(Cardano.Slot(4))).toThrowError(EraSummaryError);
    });
  });
});
