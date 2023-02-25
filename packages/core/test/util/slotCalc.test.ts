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
  createSlotTimeCalc
} from '../../src';

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

describe('slotCalc utils', () => {
  describe('slotTimeCalc', () => {
    describe('testnet', () => {
      const slotTimeCalc: SlotTimeCalc = createSlotTimeCalc(testnetEraSummaries);

      it('correctly computes date of the 1st block', () =>
        expect(slotTimeCalc(Cardano.Slot(1031))).toEqual(new Date(1_564_020_236_000)));

      it('correctly computes date of the genesis block', () =>
        expect(slotTimeCalc(Cardano.Slot(0))).toEqual(new Date(1_563_999_616_000)));

      it('correctly computes date of some Byron block', () =>
        expect(slotTimeCalc(Cardano.Slot(1_209_592))).toEqual(new Date(1_588_191_456_000)));

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
