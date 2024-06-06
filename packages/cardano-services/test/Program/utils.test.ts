import { Programs, WrongOption, serviceSetHas, stringOptionToBoolean } from '../../src/index.js';

describe('Program/utils', () => {
  describe('serviceSetHas', () => {
    enum Services {
      One,
      Two,
      Three,
      Four
    }
    const limitedServices = new Set([Services.One, Services.Three]);
    it('returns true if a single provided service is contained within the provided set', () => {
      expect(serviceSetHas([Services.One], limitedServices)).toBe(true);
    });
    it('returns true if at least one provided service is contained within the provided set', () => {
      expect(serviceSetHas([Services.One, Services.Two], limitedServices)).toBe(true);
    });
    it('returns false if a single provided service is not contained within the provided set', () => {
      expect(serviceSetHas([Services.Two], limitedServices)).toBe(false);
    });
    it('returns false if multiple provided services are not contained within the provided set', () => {
      expect(serviceSetHas([Services.Two, Services.Four], limitedServices)).toBe(false);
    });
  });
  describe('stringOptionToBoolean', () => {
    // eslint-disable-next-line unicorn/consistent-function-scoping
    const runTest = (inputs: string[], expectation: boolean) => {
      for (const input of inputs) {
        expect(stringOptionToBoolean(input, Programs.ProviderServer, 'some-option')).toBe(expectation);
      }
    };
    it('converts falsey strings to false boolean', () => {
      runTest(['0', 'f', 'false'], false);
    });
    it('converts thruthy strings to true boolean', () => {
      runTest(['1', 't', 'true'], true);
    });
    it('throws if provided string is not a match', () => {
      expect(() => stringOptionToBoolean('invalidString', Programs.ProviderServer, 'some-option')).toThrow(WrongOption);
    });
  });
});
