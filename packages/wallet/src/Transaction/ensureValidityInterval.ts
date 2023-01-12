import { Cardano, Seconds } from '@cardano-sdk/core';

const twoHours = Seconds(2 * 3600);

/**
 * Calculate the slot number after {@link seconds} time offset, given a {@link startSlot} and a {@link slotLength}.
 *
 * @param {Cardano.Slot} startSlot slot number to start the calculation from.
 * @param {Seconds} seconds time offset expressed in seconds.
 * @param {Seconds} slotLength duration of a slot expressed in seconds.
 * @returns slot number after the {@link seconds} time  will have passed.
 */
export const calcTimeOffsetSlotNumber = (
  startSlot: Cardano.Slot,
  seconds: Seconds,
  slotLength: Seconds
): Cardano.Slot => Cardano.Slot(startSlot.valueOf() + seconds.valueOf() * slotLength.valueOf());

/**
 * Configures {@link Cardano.ValidityInterval.invalidHereafter} to the slot number equivalent to
 * two hours from the {@link currentSlot} number.
 *
 * @param {Cardano.Slot} currentSlot current slot number.
 * @param {Cardano.CompactGenesis} compactGenesis genesis configuration containing `slotLength`.
 * @param {Seconds} compactGenesis.slotLength duration of a slot in seconds.
 * @param {Cardano.ValidityInterval} validityInterval optional object to be amended with the calculated
 *   `invalidHereafter` slot number. If this object has `invalidHereafter` configured, its value takes
 *    precedence, ignoring the calculated value.
 * @returns the optional {@link validityInterval} provided value, amended with the calculated `invalidHereafter`
 *    if it was not already included in the {@link validityInterval} user configured object.
 */
export const ensureValidityInterval = (
  currentSlot: Cardano.Slot,
  { slotLength }: Pick<Cardano.CompactGenesis, 'slotLength'>,
  validityInterval?: Cardano.ValidityInterval
): Cardano.ValidityInterval => ({
  invalidHereafter: calcTimeOffsetSlotNumber(currentSlot, twoHours, slotLength),
  ...validityInterval
});
