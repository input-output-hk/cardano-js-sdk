import { CustomError } from 'ts-custom-error';
import { Epoch, Slot } from '../Cardano';
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
  /**
   * Epoch length in slots
   */
  epochLength: number;
}

export class TimeSettingsError extends CustomError {}

/**
 * Were valid at 2022-01-14
 */
export const testnetTimeSettings: TimeSettings[] = [
  { epochLength: 21_600, fromSlotDate: new Date(1_563_999_616_000), fromSlotNo: 0, slotLength: 20_000 },
  { epochLength: 432_000, fromSlotDate: new Date(1_595_964_016_000), fromSlotNo: 1_598_400, slotLength: 1000 }
];

/**
 * @returns {SlotEpochCalc} function that computes epoch # given a slot #
 */
export const createSlotEpochCalc = (timeSettings: TimeSettings[]) => {
  const timeSettingsAsc = orderBy(timeSettings, ({ fromSlotNo }) => fromSlotNo);

  /**
   * @throws TimeSettingsError
   * @returns {Epoch} epoch of the slot
   */
  return (slotNo: Slot): Epoch => {
    const relevantTimeSettingsAsc = orderBy(
      timeSettingsAsc.filter(({ fromSlotNo }) => fromSlotNo <= slotNo),
      ({ fromSlotNo }) => fromSlotNo
    );
    if (relevantTimeSettingsAsc.length === 0) {
      throw new TimeSettingsError(`No TimeSettings for slot ${slotNo} found`);
    }
    let epoch = 0;
    for (let i = 0; i < relevantTimeSettingsAsc.length; i++) {
      const currentTimeSettings = relevantTimeSettingsAsc[i];
      const nextTimeSettings: TimeSettings | undefined = relevantTimeSettingsAsc[i + 1];
      epoch += Math.floor(
        ((nextTimeSettings?.fromSlotNo || slotNo) - currentTimeSettings.fromSlotNo) / currentTimeSettings.epochLength
      );
    }
    return epoch;
  };
};

/**
 * @returns {SlotTimeCalc} function that computes date/time of a given slot #
 */
export const createSlotTimeCalc = (timeSettings: TimeSettings[]) => {
  const timeSettingsDesc = orderBy(timeSettings, ({ fromSlotNo }) => fromSlotNo, 'desc');

  /**
   * @throws TimeSettingsError
   * @returns {Date} date of the slot
   */
  return (slotNo: Slot): Date => {
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

/**
 * @throws TimeSettingsError
 * @returns {Epoch} epoch of the slot
 */
export type SlotEpochCalc = ReturnType<typeof createSlotEpochCalc>;
