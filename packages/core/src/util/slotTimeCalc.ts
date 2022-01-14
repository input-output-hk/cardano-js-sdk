import { CustomError } from 'ts-custom-error';
import { orderBy } from 'lodash-es';

export interface TimeSettings {
  /**
   * 1st slot date (of the epoch when these settings take effect)
   */
  fromSlotDate: Date;
  /**
   * 1st slot number (of the epoch when these settings take effect)
   */
  fromSlotNo: number;
  /**
   * Slot length in milliseconds
   */
  slotLength: number;
}

export class TimeSettingsError extends CustomError {}

/**
 * Were valid at 2022-01-14
 */
export const testnetTimeSettings: TimeSettings[] = [
  { fromSlotDate: new Date(1_563_999_616_000), fromSlotNo: 0, slotLength: 20_000 },
  { fromSlotDate: new Date(1_595_964_016_000), fromSlotNo: 1_598_400, slotLength: 1000 }
];

export const createSlotTimeCalc = (timeSettings: TimeSettings[]) => {
  const timeSettingsDesc = orderBy(timeSettings, ({ fromSlotNo }) => fromSlotNo, 'desc');

  return (slotNo: number): Date => {
    const activeTimeSettings = timeSettingsDesc.find(({ fromSlotNo }) => fromSlotNo <= slotNo);
    if (!activeTimeSettings) {
      throw new TimeSettingsError(`No TimeSettings for slot ${slotNo} found`);
    }
    return new Date(
      activeTimeSettings.fromSlotDate.getTime() +
        (slotNo - activeTimeSettings.fromSlotNo) * activeTimeSettings.slotLength
    );
  };
};

/**
 * @throws TimeSettingsError
 * @returns {Date} date of the slot
 */
export type SlotTimeCalc = ReturnType<typeof createSlotTimeCalc>;
