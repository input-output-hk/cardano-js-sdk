import { CardanoNetworkMagic, Epoch, Slot } from '../Cardano';
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
  /**
   * Epoch length in slots
   */
  epochLength: number;
}

export interface SlotDate {
  slot: Slot;
  date: Date;
}

export interface EpochInfo {
  epochNo: Epoch;
  firstSlot: SlotDate;
  lastSlot: SlotDate;
}

export class TimeSettingsError extends CustomError {}

/**
 * Were valid at 2022-05-28
 */
export const mainnetTimeSettings: TimeSettings[] = [
  { epochLength: 21_600, fromSlotDate: new Date(1_506_192_291_000), fromSlotNo: 0, slotLength: 20_000 },
  { epochLength: 432_000, fromSlotDate: new Date(1_596_059_091_000), fromSlotNo: 4_492_800, slotLength: 1000 }
];

export const testnetTimeSettings: TimeSettings[] = [
  { epochLength: 21_600, fromSlotDate: new Date(1_563_999_616_000), fromSlotNo: 0, slotLength: 20_000 },
  { epochLength: 432_000, fromSlotDate: new Date(1_595_964_016_000), fromSlotNo: 1_598_400, slotLength: 1000 }
];

export type TimeSettingsMap = { [key in CardanoNetworkMagic]: TimeSettings[] };

export const timeSettingsConfig: TimeSettingsMap = {
  [CardanoNetworkMagic.Mainnet]: mainnetTimeSettings,
  [CardanoNetworkMagic.Testnet]: testnetTimeSettings
};

const createSlotEpochCalcImpl = (timeSettings: TimeSettings[]) => {
  const timeSettingsAsc = orderBy(timeSettings, ({ fromSlotNo }) => fromSlotNo);

  return (slotNo: Slot) => {
    const relevantTimeSettingsAsc = orderBy(
      timeSettingsAsc.filter(({ fromSlotNo }) => fromSlotNo <= slotNo),
      ({ fromSlotNo }) => fromSlotNo
    );
    if (relevantTimeSettingsAsc.length === 0) {
      throw new TimeSettingsError(`No TimeSettings for slot ${slotNo} found`);
    }
    let epochNo = 0;
    let currentTimeSettings: TimeSettings;
    for (let i = 0; i < relevantTimeSettingsAsc.length; i++) {
      currentTimeSettings = relevantTimeSettingsAsc[i];
      const nextTimeSettings: TimeSettings | undefined = relevantTimeSettingsAsc[i + 1];
      epochNo += Math.floor(
        ((nextTimeSettings?.fromSlotNo || slotNo) - currentTimeSettings.fromSlotNo) / currentTimeSettings.epochLength
      );
    }
    return { epochNo, epochTimeSettings: currentTimeSettings! };
  };
};

/**
 * @returns {SlotEpochCalc} function that computes epoch # given a slot #
 */
export const createSlotEpochCalc = (timeSettings: TimeSettings[]) => {
  const calc = createSlotEpochCalcImpl(timeSettings);

  /**
   * @throws TimeSettingsError
   * @returns {Epoch} epoch of the slot
   */
  return (slotNo: Slot): Epoch => calc(slotNo).epochNo;
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
 * @returns {SlotEpochInfoCalc} function that computes epoch of the slot and it's first/last slots
 */
export const createSlotEpochInfoCalc = (timeSettings: TimeSettings[]) => {
  const slotTimeCalc = createSlotTimeCalc(timeSettings);
  const epochCalc = createSlotEpochCalcImpl(timeSettings);
  /**
   * @throws TimeSettingsError
   * @returns {EpochInfo} epoch of the slot and it's first/last slots
   */
  return (slot: Slot): EpochInfo => {
    const { epochNo, epochTimeSettings } = epochCalc(slot);
    const firstSlot =
      epochTimeSettings.fromSlotNo +
      Math.floor((slot - epochTimeSettings.fromSlotNo) / epochTimeSettings.epochLength) * epochTimeSettings.epochLength;
    const lastSlot = firstSlot + epochTimeSettings.epochLength - 1;
    return {
      epochNo,
      firstSlot: {
        date: slotTimeCalc(firstSlot),
        slot: firstSlot
      },
      lastSlot: {
        date: slotTimeCalc(lastSlot),
        slot: lastSlot
      }
    };
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

/**
 * @throws TimeSettingsError
 * @returns {EpochInfo} epoch of the slot and it's first/last slots
 */
export type SlotEpochInfoCalc = ReturnType<typeof createSlotEpochInfoCalc>;
