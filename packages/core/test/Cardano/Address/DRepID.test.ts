import { DRepID } from '../../../src/Cardano/index.js';
import { InvalidStringError } from '@cardano-sdk/util';

describe('Cardano/Address/DRepID', () => {
  it('DRepID() accepts a valid bech32 string with drep as prefix', () => {
    expect(() => DRepID('drep1vpzcgfrlgdh4fft0p0ju70czkxxkuknw0jjztl3x7aqgm9q3hqyaz')).not.toThrow();
  });

  it('DRepID() throws an error if the bech32 string has the wrong prefix', () => {
    expect(() => DRepID('addr_test1vpudzrw5uq46qwl6h5szlc66fydr0l2rlsw4nvaaxfld40g3ys07c')).toThrowError(
      InvalidStringError
    );
  });

  describe('isValid', () => {
    it('is true if string is a valid DRepID', () => {
      expect(DRepID.isValid('drep1vpzcgfrlgdh4fft0p0ju70czkxxkuknw0jjztl3x7aqgm9q3hqyaz')).toBe(true);
    });
    it('is false if string is not a valid DRepID', () => {
      expect(DRepID.isValid('addr_test1vpudzrw5uq46qwl6h5szlc66fydr0l2rlsw4nvaaxfld40g3ys07c')).toBe(false);
    });
  });

  describe('canSign', () => {
    it('is true if DRepID is a valid type 6 address', () => {
      expect(DRepID.canSign('drep1vpzcgfrlgdh4fft0p0ju70czkxxkuknw0jjztl3x7aqgm9q3hqyaz')).toBe(true);
    });
    it('is false if DRepID is not a type 6 address', () => {
      expect(DRepID.canSign('drep1wpzcgfrlgdh4fft0p0ju70czkxxkuknw0jjztl3x7aqgm9qcluy2z')).toBe(false);
    });
  });
});
