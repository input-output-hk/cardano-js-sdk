import { Cardano, Seconds } from '@cardano-sdk/core';
import { calcTimeOffsetSlotNumber, ensureValidityInterval } from '../src/index.js';

describe('calcTimeOffsetSlotNumber', () => {
  it('can calculate using 1 second slot length', () => {
    const expectedSlotOffset = 100 + 50;
    expect(calcTimeOffsetSlotNumber(Cardano.Slot(100), Seconds(50), Seconds(1))).toEqual(expectedSlotOffset);
  });

  it('can calculate using 10 seconds slot length', () => {
    const expectedSlotOffset = 100 + 50;
    expect(calcTimeOffsetSlotNumber(Cardano.Slot(100), Seconds(5), Seconds(10))).toEqual(expectedSlotOffset);
  });

  it('can calculate using 1/10 seconds slot length', () => {
    const expectedSlotOffset = 100 + 50;
    expect(calcTimeOffsetSlotNumber(Cardano.Slot(100), Seconds(500), Seconds(0.1))).toEqual(expectedSlotOffset);
  });
});

describe('ensureValidityInterval', () => {
  const twoHours = Seconds(2 * 3600);

  it('configures invalidHereafter to 2h by default', () => {
    const currentSlot = Cardano.Slot(1);
    const validityInterval = ensureValidityInterval(currentSlot, { slotLength: Seconds(1) });
    expect(validityInterval.invalidHereafter).toEqual(Cardano.Slot(twoHours + currentSlot));
  });

  it('uses calculated invalidHereafter value when user provides a partial ValidityInterval', () => {
    const currentSlot = Cardano.Slot(1);
    const validityInterval = ensureValidityInterval(
      currentSlot,
      { slotLength: Seconds(1) },
      { invalidBefore: currentSlot }
    );
    expect(validityInterval).toEqual({
      invalidBefore: currentSlot,
      invalidHereafter: Cardano.Slot(twoHours + currentSlot)
    });
  });

  it('ignores calculated invalidHereafter value when user provides a complete ValidityInterval', () => {
    const currentSlot = Cardano.Slot(1);
    const userProvided: Cardano.ValidityInterval = { invalidBefore: currentSlot, invalidHereafter: Cardano.Slot(13) };
    const validityInterval = ensureValidityInterval(currentSlot, { slotLength: Seconds(1) }, userProvided);
    expect(validityInterval).toEqual(userProvided);
  });
});
