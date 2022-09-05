import { CardanoNetworkMagic, EpochNo, Slot } from '../Cardano';
import { CustomError } from 'ts-custom-error';
import { EraSummary } from '../CardanoNode';
import groupBy from 'lodash/groupBy';
import last from 'lodash/last';
import orderBy from 'lodash/orderBy';

export interface SlotDate {
  slot: Slot;
  date: Date;
}

export interface EpochInfo {
  epochNo: EpochNo;
  firstSlot: SlotDate;
  lastSlot: SlotDate;
}

export class EraSummaryError extends CustomError {}

/**
 * Valid at 2022-05-28
 */
export const mainnetEraSummaries: EraSummary[] = [
  { parameters: { epochLength: 21_600, slotLength: 20_000 }, start: { slot: 0, time: new Date(1_506_192_291_000) } },
  {
    parameters: { epochLength: 432_000, slotLength: 1000 },
    start: { slot: 4_492_800, time: new Date(1_596_059_091_000) }
  }
];

export const testnetEraSummaries: EraSummary[] = [
  { parameters: { epochLength: 21_600, slotLength: 20_000 }, start: { slot: 0, time: new Date(1_563_999_616_000) } },
  {
    parameters: { epochLength: 432_000, slotLength: 1000 },
    start: { slot: 1_598_400, time: new Date(1_595_964_016_000) }
  }
];

export type EraSummariesMap = { [key in CardanoNetworkMagic]: EraSummary[] };

export const eraSummariesConfig: EraSummariesMap = {
  [CardanoNetworkMagic.Mainnet]: mainnetEraSummaries,
  [CardanoNetworkMagic.Testnet]: testnetEraSummaries
};

const createSlotEpochCalcImpl = (eraSummaries: EraSummary[]) => {
  // It's possible to configure when particular eras are upgraded, without an upgrade proposal, in
  // testnet cardano-node configuration, including the specification of multiple eras in the same
  // epoch. Era summaries therefore need to be filtered to remove eras that are being skipped,
  // which is evidenced by a later era starting in the same slot.
  const eraSummariesWithoutSkippedEras = Object.values(groupBy(eraSummaries, 'start.slot')).map(last) as EraSummary[];
  const eraSummariesAsc = orderBy(eraSummariesWithoutSkippedEras, ({ start }) => start.slot);
  return (slotNo: Slot) => {
    const relevantEraSummariesAsc = orderBy(
      eraSummariesAsc.filter(({ start }) => start.slot <= slotNo),
      ({ start }) => start.slot
    );
    if (relevantEraSummariesAsc.length === 0) {
      throw new EraSummaryError(`No EraSummary for slot ${slotNo} found`);
    }
    let epochNo = 0;
    let currentEraSummary: EraSummary;
    for (let i = 0; i < relevantEraSummariesAsc.length; i++) {
      currentEraSummary = relevantEraSummariesAsc[i];
      const nextEraSummary: EraSummary | undefined = relevantEraSummariesAsc[i + 1];
      epochNo += Math.floor(
        ((nextEraSummary?.start.slot || slotNo) - currentEraSummary.start.slot) /
          currentEraSummary.parameters.epochLength
      );
    }
    return { epochEraSummary: currentEraSummary!, epochNo };
  };
};

/**
 * @returns {SlotEpochCalc} function that computes epoch # given a slot #
 */
export const createSlotEpochCalc = (eraSummaries: EraSummary[]) => {
  const calc = createSlotEpochCalcImpl(eraSummaries);

  /**
   * @throws EraSummaryError
   * @returns {EpochNo} epoch of the slot
   */
  return (slotNo: Slot): EpochNo => calc(slotNo).epochNo;
};

/**
 * @returns {SlotTimeCalc} function that computes date/time of a given slot #
 */
export const createSlotTimeCalc = (eraSummaries: EraSummary[]) => {
  const eraSummariesDesc = orderBy(eraSummaries, ({ start }) => start.slot, 'desc');

  /**
   * @throws EraSummaryError
   * @returns {Date} date of the slot
   */
  return (slotNo: Slot): Date => {
    const activeEraSummary = eraSummariesDesc.find(({ start }) => start.slot <= slotNo);
    if (!activeEraSummary) {
      throw new EraSummaryError(`No EraSummary for slot ${slotNo} found`);
    }
    return new Date(
      activeEraSummary.start.time.getTime() +
        (slotNo - activeEraSummary.start.slot) * activeEraSummary.parameters.slotLength
    );
  };
};

/**
 * @returns {SlotEpochInfoCalc} function that computes epoch of the slot and it's first/last slots
 */
export const createSlotEpochInfoCalc = (eraSummaries: EraSummary[]) => {
  const slotTimeCalc = createSlotTimeCalc(eraSummaries);
  const epochCalc = createSlotEpochCalcImpl(eraSummaries);
  /**
   * @throws EraSummaryError
   * @returns {EpochInfo} epoch of the slot and it's first/last slots
   */
  return (slot: Slot): EpochInfo => {
    const { epochNo, epochEraSummary } = epochCalc(slot);
    const firstSlot =
      epochEraSummary.start.slot +
      Math.floor((slot - epochEraSummary.start.slot) / epochEraSummary.parameters.epochLength) *
        epochEraSummary.parameters.epochLength;
    const lastSlot = firstSlot + epochEraSummary.parameters.epochLength - 1;
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
 * @throws EraSummaryError
 * @returns {Date} date of the slot
 */
export type SlotTimeCalc = ReturnType<typeof createSlotTimeCalc>;

/**
 * @throws EraSummaryError
 * @returns {EpochNo} epoch of the slot
 */
export type SlotEpochCalc = ReturnType<typeof createSlotEpochCalc>;

/**
 * @throws EraSummaryError
 * @returns {EpochInfo} epoch of the slot and it's first/last slots
 */
export type SlotEpochInfoCalc = ReturnType<typeof createSlotEpochInfoCalc>;
