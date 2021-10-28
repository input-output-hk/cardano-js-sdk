import { Cardano } from '@cardano-sdk/core';

export const ensureValidityInterval = (
  currentSlot: number,
  validityInterval?: Cardano.ValidityInterval
): Cardano.ValidityInterval =>
  // Todo: Based this on slot duration, to equal 2hrs
  ({ invalidHereafter: currentSlot + 3600, ...validityInterval });
