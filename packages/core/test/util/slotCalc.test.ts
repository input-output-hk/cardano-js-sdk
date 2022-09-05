/* eslint-disable unicorn/consistent-function-scoping */
/* eslint-disable sonarjs/no-duplicate-string */
import {
  Cardano,
  EpochInfo,
  EraSummary,
  EraSummaryError,
  SlotEpochCalc,
  SlotEpochInfoCalc,
  SlotTimeCalc,
  createSlotEpochCalc,
  createSlotEpochInfoCalc,
  createSlotTimeCalc,
  testnetEraSummaries
} from '../../src';

import merge from 'lodash/merge';

describe('slotCalc utils', () => {
  describe('slotTimeCalc', () => {
    describe('testnet', () => {
      const slotTimeCalc: SlotTimeCalc = createSlotTimeCalc(testnetEraSummaries);

      it('correctly computes date of the 1st block', () =>
        expect(slotTimeCalc(1031)).toEqual(new Date(1_564_020_236_000)));

      it('correctly computes date of the genesis block', () =>
        expect(slotTimeCalc(0)).toEqual(new Date(1_563_999_616_000)));

      it('correctly computes date of some Byron block', () =>
        expect(slotTimeCalc(1_209_592)).toEqual(new Date(1_588_191_456_000)));

      it('correctly computes date of the last Byron block', () =>
        expect(slotTimeCalc(1_598_399)).toEqual(new Date(1_595_967_596_000)));

      it('correctly computes date of the 1st Shelley block', () =>
        expect(slotTimeCalc(1_598_400)).toEqual(new Date('2020/07/28 20:20:16 UTC')));

      it('correctly computes date of the 2nd Shelley block', () =>
        expect(slotTimeCalc(1_598_420)).toEqual(new Date('2020/07/28 20:20:36 UTC')));

      it('correctly computes date of some Shelley block', () =>
        expect(slotTimeCalc(8_078_371)).toEqual(new Date(new Date('2020/10/11 20:19:47 UTC'))));

      it('correctly computes date of some Alonzo block', () =>
        expect(slotTimeCalc(67_951_416)).toEqual(new Date('2022-09-04 19:43:52 UTC')));

      it('throws with invalid slot', () => expect(() => slotTimeCalc(-1)).toThrowError(EraSummaryError));
    });

    it('throws with invalid EraSummary', () => {
      const slotTimeCalc = createSlotTimeCalc([
        merge({}, testnetEraSummaries[0], { parameters: { slotLength: 1 }, start: { slot: 5, time: new Date() } })
      ]);
      expect(() => slotTimeCalc(4)).toThrowError(EraSummaryError);
    });
  });

  describe('slotEpochCalc', () => {
    describe('testnet with auto-upgrading eras', () => {
      it('correctly computes epoch with multiple summaries starting from genesis', () => {
        const eraSummaries: EraSummary[] = [
          {
            parameters: { epochLength: 100, slotLength: 3 },
            start: { slot: 0, time: new Date(1_563_999_616_000) }
          },
          { parameters: { epochLength: 200, slotLength: 10 }, start: { slot: 0, time: new Date(1_563_999_616_000) } },
          { parameters: { epochLength: 200, slotLength: 1 }, start: { slot: 0, time: new Date(1_563_999_616_000) } }
        ];
        const slotEpochCalc: SlotEpochCalc = createSlotEpochCalc(eraSummaries);

        expect(slotEpochCalc(1031)).toEqual(5);
      });
      it('correctly computes epoch with summaries indicating an upgrade after genesis, from the same slotNo', () => {
        const eraSummaries: EraSummary[] = [
          {
            parameters: { epochLength: 100, slotLength: 3 },
            start: { slot: 0, time: new Date(1_563_999_616_000) }
          },
          {
            parameters: { epochLength: 200, slotLength: 10 },
            start: { slot: 301, time: new Date(1_563_999_716_000) }
          },
          {
            parameters: { epochLength: 200, slotLength: 1 },
            start: { slot: 301, time: new Date(1_563_999_716_000) }
          }
        ];
        const slotEpochCalc: SlotEpochCalc = createSlotEpochCalc(eraSummaries);

        expect(slotEpochCalc(1031)).toEqual(6);
      });
    });
    describe('testnet', () => {
      const slotEpochCalc: SlotEpochCalc = createSlotEpochCalc(testnetEraSummaries);

      it('correctly computes epoch of the 1st block', () => expect(slotEpochCalc(1031)).toEqual(0));

      it('correctly computes epoch of the genesis block', () => expect(slotEpochCalc(0)).toBe(0));

      it('correctly computes epoch of some Byron block', () => expect(slotEpochCalc(1_209_592)).toBe(55));

      it('correctly computes epoch of the last Byron block', () => expect(slotEpochCalc(1_598_399)).toBe(73));

      it('correctly computes epoch of the 1st Shelley block', () => expect(slotEpochCalc(1_598_400)).toBe(74));

      it('correctly computes epoch of the 2nd Shelley block', () => expect(slotEpochCalc(1_598_420)).toBe(74));

      it('correctly computes epoch of some Shelley block', () => expect(slotEpochCalc(8_078_371)).toBe(88));

      it('throws with invalid slot', () => expect(() => slotEpochCalc(-1)).toThrowError(EraSummaryError));
    });

    it('throws with invalid EraSummary', () => {
      const slotEpochCalc = createSlotEpochCalc([merge({}, testnetEraSummaries[0], { start: { slot: 5 } })]);
      expect(() => slotEpochCalc(4)).toThrowError(EraSummaryError);
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
        assertNthEpochInfoValid(0, slotEpochInfoCalc(1031), byronEraSummary);
      });

      it('correctly computes epoch info of the genesis block', () => {
        assertNthEpochInfoValid(0, slotEpochInfoCalc(0), byronEraSummary);
      });

      it('correctly computes epoch info of some Byron block', () => {
        assertNthEpochInfoValid(55, slotEpochInfoCalc(1_209_592), byronEraSummary);
      });

      it('correctly computes epoch info of the last Byron block', () => {
        assertNthEpochInfoValid(73, slotEpochInfoCalc(1_598_399), byronEraSummary);
      });

      it('correctly computes epoch info of the 1st Shelley block', () => {
        assertNthEpochInfoValid(74, slotEpochInfoCalc(1_598_400), shelleyEraSummary);
      });

      it('correctly computes epoch info of the 2nd Shelley block', () => {
        assertNthEpochInfoValid(74, slotEpochInfoCalc(1_598_420), shelleyEraSummary);
      });

      it('correctly computes epoch of info some Shelley block', () => {
        assertNthEpochInfoValid(88, slotEpochInfoCalc(8_078_371), shelleyEraSummary);
      });

      it('throws with invalid slot', () => expect(() => slotEpochInfoCalc(-1)).toThrowError(EraSummaryError));
    });

    it('throws with invalid EraSummary', () => {
      const slotEpochInfoCalc = createSlotEpochInfoCalc([merge({}, testnetEraSummaries[0], { start: { slot: 5 } })]);
      expect(() => slotEpochInfoCalc(4)).toThrowError(EraSummaryError);
    });
  });
});
