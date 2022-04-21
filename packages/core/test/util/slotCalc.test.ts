/* eslint-disable unicorn/consistent-function-scoping */
/* eslint-disable sonarjs/no-duplicate-string */
import {
  Cardano,
  EpochInfo,
  SlotEpochCalc,
  SlotEpochInfoCalc,
  SlotTimeCalc,
  TimeSettings,
  TimeSettingsError,
  createSlotEpochCalc,
  createSlotEpochInfoCalc,
  createSlotTimeCalc,
  testnetTimeSettings
} from '../../src';

describe('slotCalc utils', () => {
  describe('slotTimeCalc', () => {
    describe('testnet', () => {
      const slotTimeCalc: SlotTimeCalc = createSlotTimeCalc(testnetTimeSettings);

      it('correctly computes date of the 1st block', () =>
        expect(slotTimeCalc(1031)).toEqual(new Date(1_564_020_236_000)));

      it('correctly computes date of the genesis block', () =>
        expect(slotTimeCalc(0)).toEqual(new Date(1_563_999_616_000)));

      it('correctly computes date of some Byron block', () =>
        expect(slotTimeCalc(1_209_592)).toEqual(new Date(1_588_191_456_000)));

      it('correctly computes date of the last Byron block', () =>
        expect(slotTimeCalc(1_598_399)).toEqual(new Date(1_595_967_596_000)));

      it('correctly computes date of the 1st Shelley block', () =>
        expect(slotTimeCalc(1_598_400)).toEqual(new Date(1_595_964_016_000)));

      it('correctly computes date of the 2nd Shelley block', () =>
        expect(slotTimeCalc(1_598_420)).toEqual(new Date(1_595_964_036_000)));

      it('correctly computes date of some Shelley block', () =>
        expect(slotTimeCalc(8_078_371)).toEqual(new Date(1_602_443_987_000)));

      it('throws with invalid slot', () => expect(() => slotTimeCalc(-1)).toThrowError(TimeSettingsError));
    });

    it('throws with invalid TimeSettings', () => {
      const slotTimeCalc = createSlotTimeCalc([
        { ...testnetTimeSettings[0], fromSlotDate: new Date(), fromSlotNo: 5, slotLength: 1 }
      ]);
      expect(() => slotTimeCalc(4)).toThrowError(TimeSettingsError);
    });
  });

  describe('slotEpochCalc', () => {
    describe('testnet', () => {
      const slotEpochCalc: SlotEpochCalc = createSlotEpochCalc(testnetTimeSettings);

      it('correctly computes epoch of the 1st block', () => expect(slotEpochCalc(1031)).toEqual(0));

      it('correctly computes epoch of the genesis block', () => expect(slotEpochCalc(0)).toBe(0));

      it('correctly computes epoch of some Byron block', () => expect(slotEpochCalc(1_209_592)).toBe(55));

      it('correctly computes epoch of the last Byron block', () => expect(slotEpochCalc(1_598_399)).toBe(73));

      it('correctly computes epoch of the 1st Shelley block', () => expect(slotEpochCalc(1_598_400)).toBe(74));

      it('correctly computes epoch of the 2nd Shelley block', () => expect(slotEpochCalc(1_598_420)).toBe(74));

      it('correctly computes epoch of some Shelley block', () => expect(slotEpochCalc(8_078_371)).toBe(88));

      it('throws with invalid slot', () => expect(() => slotEpochCalc(-1)).toThrowError(TimeSettingsError));
    });

    it('throws with invalid TimeSettings', () => {
      const slotEpochCalc = createSlotEpochCalc([{ ...testnetTimeSettings[0], fromSlotNo: 5 }]);
      expect(() => slotEpochCalc(4)).toThrowError(TimeSettingsError);
    });
  });

  describe('slotEpochInfoCalc ', () => {
    describe('testnet', () => {
      const slotEpochInfoCalc: SlotEpochInfoCalc = createSlotEpochInfoCalc(testnetTimeSettings);
      const byronTimeSettings = {
        ...testnetTimeSettings[0],
        firstEpoch: 0
      };
      const shelleyTimeSettings = {
        ...testnetTimeSettings[1],
        firstEpoch: 74
      };

      const assertNthEpochInfoValid = (
        expectedEpochNo: Cardano.Epoch,
        { epochNo, firstSlot, lastSlot }: EpochInfo,
        epochTimeSettings: TimeSettings & { firstEpoch: number }
      ) => {
        expect(epochNo).toEqual(expectedEpochNo);
        const relativeEpoch = expectedEpochNo - epochTimeSettings.firstEpoch;
        expect(firstSlot).toEqual({
          date: new Date(
            epochTimeSettings.fromSlotDate.getTime() +
              epochTimeSettings.epochLength * epochTimeSettings.slotLength * relativeEpoch
          ),
          slot: epochTimeSettings.fromSlotNo + epochTimeSettings.epochLength * relativeEpoch
        });
        expect(lastSlot).toEqual({
          date: new Date(
            epochTimeSettings.fromSlotDate.getTime() +
              epochTimeSettings.epochLength * epochTimeSettings.slotLength * (relativeEpoch + 1) -
              epochTimeSettings.slotLength
          ),
          slot: epochTimeSettings.fromSlotNo + epochTimeSettings.epochLength * (relativeEpoch + 1) - 1
        });
      };

      it('correctly computes epoch info of the 1st block', () => {
        assertNthEpochInfoValid(0, slotEpochInfoCalc(1031), byronTimeSettings);
      });

      it('correctly computes epoch info of the genesis block', () => {
        assertNthEpochInfoValid(0, slotEpochInfoCalc(0), byronTimeSettings);
      });

      it('correctly computes epoch info of some Byron block', () => {
        assertNthEpochInfoValid(55, slotEpochInfoCalc(1_209_592), byronTimeSettings);
      });

      it('correctly computes epoch info of the last Byron block', () => {
        assertNthEpochInfoValid(73, slotEpochInfoCalc(1_598_399), byronTimeSettings);
      });

      it('correctly computes epoch info of the 1st Shelley block', () => {
        assertNthEpochInfoValid(74, slotEpochInfoCalc(1_598_400), shelleyTimeSettings);
      });

      it('correctly computes epoch info of the 2nd Shelley block', () => {
        assertNthEpochInfoValid(74, slotEpochInfoCalc(1_598_420), shelleyTimeSettings);
      });

      it('correctly computes epoch of info some Shelley block', () => {
        assertNthEpochInfoValid(88, slotEpochInfoCalc(8_078_371), shelleyTimeSettings);
      });

      it('throws with invalid slot', () => expect(() => slotEpochInfoCalc(-1)).toThrowError(TimeSettingsError));
    });

    it('throws with invalid TimeSettings', () => {
      const slotEpochInfoCalc = createSlotEpochInfoCalc([{ ...testnetTimeSettings[0], fromSlotNo: 5 }]);
      expect(() => slotEpochInfoCalc(4)).toThrowError(TimeSettingsError);
    });
  });
});
