import * as Crypto from '../../src/index.js';
import { Ed25519KeyHashHex } from '../../src/index.js';
import { InvalidStringError } from '@cardano-sdk/util';

describe('Ed25519KeyHash', () => {
  const kEY_HASH = 'b275b08c999097247f7c17e77007c7010cd19f20cc086ad99d398538';

  it('can create an instance from a valid key hash hex representation', () => {
    const signature = Crypto.Ed25519KeyHash.fromHex(Ed25519KeyHashHex(kEY_HASH));
    expect(signature.hex()).toBe(kEY_HASH);
  });

  test('can create an instance from a valid key hash raw binary representation', () => {
    const sigBytes = Buffer.from(kEY_HASH, 'hex');
    const signature = Crypto.Ed25519KeyHash.fromBytes(sigBytes);
    expect(signature.bytes()).toBe(sigBytes);
  });

  test('throws if a key hash of invalid size is given.', () => {
    expect(() => Crypto.Ed25519KeyHash.fromHex(Ed25519KeyHashHex('1f'))).toThrow(InvalidStringError);
    expect(() => Crypto.Ed25519KeyHash.fromHex(Ed25519KeyHashHex(`${kEY_HASH}1f2f3f`))).toThrow(InvalidStringError);
  });
});
