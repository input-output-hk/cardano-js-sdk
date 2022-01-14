import { SlotTimeCalc, TimeSettingsError, createSlotTimeCalc, testnetTimeSettings } from '../../src';

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
    const slotTimeCalc = createSlotTimeCalc([{ fromSlotDate: new Date(), fromSlotNo: 5, slotLength: 1 }]);
    expect(() => slotTimeCalc(4)).toThrowError(TimeSettingsError);
  });
});
