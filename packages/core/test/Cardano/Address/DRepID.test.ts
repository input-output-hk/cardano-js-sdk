import { Credential, CredentialType, DRepID } from '../../../src/Cardano';
import { InvalidStringError } from '@cardano-sdk/util';

const CIP105_PUB_KEY_HASH_ID = 'drep15cfxz9exyn5rx0807zvxfrvslrjqfchrd4d47kv9e0f46uedqtc';
const CIP129_PUB_KEY_HASH_ID = 'drep1y2npycghycjwsveualcfseydjruwgp8zudk4kh6esh9axhgfcvqjs';
const KEY_HASH = 'a61261172624e8333ceff098648d90f8e404e2e36d5b5f5985cbd35d';

const CIP105_SCRIPT_HASH_ID = 'drep_script1rxdd99vu338y659qfg8nmpemdyhlsmaudgv4m4zdz7m5vz8uzt6';
const CIP129_SCRIPT_HASH_ID = 'drep1yvve4554njxyun2s5p9q70v88d5jl7r0h34pjhw5f5tmw3sjtrutp';
const SCRIPT_HASH = '199ad2959c8c4e4d50a04a0f3d873b692ff86fbc6a195dd44d17b746';

const pubKeyHashCredential = {
  hash: KEY_HASH,
  type: CredentialType.KeyHash
} as Credential;

const scriptHashCredential = {
  hash: SCRIPT_HASH,
  type: CredentialType.ScriptHash
} as Credential;

describe('Cardano/Address/DRepID', () => {
  it('can parse both CIP-105 and CIP-129 pub key hash DRep IDs', () => {
    expect(DRepID.toCredential(DRepID(CIP105_PUB_KEY_HASH_ID))).toEqual(pubKeyHashCredential);
    expect(DRepID.toCredential(DRepID(CIP129_PUB_KEY_HASH_ID))).toEqual(pubKeyHashCredential);
  });

  it('can parse both CIP-105 and CIP-129 script hash DRep IDs', () => {
    expect(DRepID.toCredential(DRepID(CIP105_SCRIPT_HASH_ID))).toEqual(scriptHashCredential);
    expect(DRepID.toCredential(DRepID(CIP129_SCRIPT_HASH_ID))).toEqual(scriptHashCredential);
  });

  it('can create CIP-105 DRep IDs from credentials', () => {
    expect(DRepID.cip105FromCredential(pubKeyHashCredential)).toEqual(CIP105_PUB_KEY_HASH_ID);
    expect(DRepID.cip105FromCredential(scriptHashCredential)).toEqual(CIP105_SCRIPT_HASH_ID);
  });

  it('can create CIP-129 DRep IDs from credentials', () => {
    expect(DRepID.cip129FromCredential(pubKeyHashCredential)).toEqual(CIP129_PUB_KEY_HASH_ID);
    expect(DRepID.cip129FromCredential(scriptHashCredential)).toEqual(CIP129_SCRIPT_HASH_ID);
  });

  it('can convert CIP-105 DRep IDs to CIP-129 DRep IDs', () => {
    expect(DRepID.toCip129DRepID(DRepID.cip105FromCredential(pubKeyHashCredential))).toEqual(CIP129_PUB_KEY_HASH_ID);
    expect(DRepID.toCip129DRepID(DRepID.cip105FromCredential(scriptHashCredential))).toEqual(CIP129_SCRIPT_HASH_ID);
  });

  it('can convert CIP-129 DRep IDs to CIP-105 DRep IDs', () => {
    expect(DRepID.toCip105DRepID(DRepID.cip129FromCredential(pubKeyHashCredential))).toEqual(CIP105_PUB_KEY_HASH_ID);
    expect(DRepID.toCip105DRepID(DRepID.cip129FromCredential(scriptHashCredential))).toEqual(CIP105_SCRIPT_HASH_ID);
  });

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
