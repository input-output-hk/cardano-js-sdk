import { Address } from '../../src';

jest.mock('../../src/CSL/parseCslAddress');
const { parseCslAddress } = jest.requireMock('../../src/CSL/parseCslAddress');

describe('Address', () => {
  describe('util', () => {
    describe('isAddress', () => {
      it('returns false if parseCslAddress returns null', () => {
        parseCslAddress.mockReturnValueOnce(null);
        expect(Address.util.isAddress('invalid')).toBe(false);
      });
      it('returns true if parseCslAddress returns an Address', () => {
        parseCslAddress.mockReturnValueOnce('CSL.Address object');
        expect(Address.util.isAddress('valid')).toBe(true);
      });
    });
  });
});
