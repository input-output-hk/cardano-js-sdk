import { CustomError } from 'ts-custom-error';
import { EpochNo, NetworkMagics, Slot } from '../Cardano';
import { EraSummary } from '../CardanoNode';
import groupBy from 'lodash/groupBy';
import last from 'lodash/last';
import memoize from 'lodash/memoize';
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

export type EraSummariesMap = { [key in NetworkMagics]: EraSummary[] };

const createSlotEpochCalcImpl = (eraSummaries: EraSummary[]) => {
  // It's possible to configure when particular eras are upgraded, without an upgrade proposal, in
  // testnet cardano-node configuration, including the specification of multiple eras in the same
  // epoch. Era summaries therefore need to be filtered to remove eras that are being skipped,
  // which is evidenced by a later era starting in the same slot.
  const eraSummariesWithoutSkippedEras = Object.values(groupBy(eraSummaries, 'start.slot')).map(last) as EraSummary[];
  const eraSummariesAsc = orderBy(eraSummariesWithoutSkippedEras, ({ start }) => start.slot);
  return (slotNo: Slot) => {
    const relevantEraSummariesAsc = orderBy(
      eraSummariesAsc.filter(({ start }) => start.slot <= slotNo.valueOf()),
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
        ((nextEraSummary?.start.slot || slotNo.valueOf()) - currentEraSummary.start.slot) /
          currentEraSummary.parameters.epochLength
      );
    }
    return { epochEraSummary: currentEraSummary!, epochNo };
  };
};

/**
 * @returns {SlotEpochCalc} function that computes epoch # given a slot #
 */
export const createSlotEpochCalc: (eraSummaries: EraSummary[]) => (slotNo: Slot) => EpochNo = memoize(
  (eraSummaries: EraSummary[]) => {
    const calc = createSlotEpochCalcImpl(eraSummaries);

    /**
     * @throws EraSummaryError
     * @returns {EpochNo} epoch of the slot
     */
    return (slotNo: Slot): EpochNo => EpochNo(calc(slotNo).epochNo);
  }
);

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
    const activeEraSummary = eraSummariesDesc.find(({ start }) => start.slot <= slotNo.valueOf());
    if (!activeEraSummary) {
      throw new EraSummaryError(`No EraSummary for slot ${slotNo} found`);
    }
    return new Date(
      activeEraSummary.start.time.getTime() +
        (slotNo.valueOf() - activeEraSummary.start.slot) * activeEraSummary.parameters.slotLength.valueOf()
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
      Math.floor((slot.valueOf() - epochEraSummary.start.slot) / epochEraSummary.parameters.epochLength) *
        epochEraSummary.parameters.epochLength;
    const lastSlot = firstSlot + epochEraSummary.parameters.epochLength - 1;
    return {
      epochNo: EpochNo(epochNo),
      firstSlot: {
        date: slotTimeCalc(Slot(firstSlot)),
        slot: Slot(firstSlot)
      },
      lastSlot: {
        date: slotTimeCalc(Slot(lastSlot)),
        slot: Slot(lastSlot)
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
