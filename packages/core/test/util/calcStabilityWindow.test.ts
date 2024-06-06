import { calculateStabilityWindowSlotsCount } from '../../src/util/index.js';

describe('calculateStabilityWindowSlotsCount', () => {
  it('calculate stability window slots count', () => {
    const securityParameter = 2160;
    const activeSlotsCoefficient = 0.05;
    const expectedStabilityWindowValue = 129_600;
    expect(calculateStabilityWindowSlotsCount({ activeSlotsCoefficient, securityParameter })).toEqual(
      expectedStabilityWindowValue
    );
  });
});
