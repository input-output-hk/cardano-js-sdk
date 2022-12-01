import { Cardano } from '@cardano-sdk/core';

export const ensureValidityInterval = (
  currentSlot: Cardano.Slot,
  validityInterval?: Cardano.ValidityInterval
): Cardano.ValidityInterval =>
  // Todo: Based this on slot duration, to equal 2hrs
  ({ invalidHereafter: Cardano.Slot(currentSlot.valueOf() + 3600), ...validityInterval });
