import { Cardano, Seconds } from '@cardano-sdk/core';

const twoHours = Seconds(2 * 3600);

/**
 * Calculate the slot number after `seconds` time offset, given a `startSlot` and a `slotLength`.
 *
 * @param {Cardano.Slot} startSlot slot number to start the calculation from.
 * @param {Seconds} seconds time offset expressed in seconds.
 * @param {Seconds} slotLength duration of a slot expressed in seconds.
 * @returns slot number after the `seconds` time  will have passed.
 */
export const calcTimeOffsetSlotNumber = (
  startSlot: Cardano.Slot,
  seconds: Seconds,
  slotLength: Seconds
): Cardano.Slot => Cardano.Slot(startSlot + seconds * slotLength);

/**
 * Configures {@link "@cardano-sdk/core".Cardano.ValidityInterval.invalidHereafter} to the slot number equivalent to
 * two hours from the `currentSlot` number.
 *
 * @param {Cardano.Slot} currentSlot current slot number.
 * @param {Cardano.CompactGenesis} compactGenesis genesis configuration containing `slotLength`.
 * @param {Seconds} compactGenesis.slotLength duration of a slot in seconds.
 * @param {Cardano.ValidityInterval} validityInterval optional object to be amended with the calculated
 *   `invalidHereafter` slot number. If this object has `invalidHereafter` configured, its value takes
 *    precedence, ignoring the calculated value.
 * @returns the optional `validityInterval` provided value, amended with the calculated `invalidHereafter`
 *    if it was not already included in the `validityInterval` user configured object.
 */
export const ensureValidityInterval = (
  currentSlot: Cardano.Slot,
  { slotLength }: Pick<Cardano.CompactGenesis, 'slotLength'>,
  validityInterval?: Cardano.ValidityInterval
): Cardano.ValidityInterval => ({
  invalidHereafter: calcTimeOffsetSlotNumber(currentSlot, twoHours, slotLength),
  ...validityInterval
});
