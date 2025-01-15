import * as Crypto from '../../src';
import { InvalidStringError } from '@cardano-sdk/util';
import { testVectorMessageZeroLength } from './Ed25519TestVectors';

describe('Ed25519Signature', () => {
  beforeAll(() => Crypto.ready());

  it('can create an instance from a valid Ed25519 signature hex representation', () => {
    const signature = Crypto.Ed25519Signature.fromHex(
      Crypto.Ed25519SignatureHex(testVectorMessageZeroLength.signature)
    );
    expect(signature.hex()).toBe(testVectorMessageZeroLength.signature);
  });

  test('can create an instance from a valid Ed25519 signature raw binary representation', () => {
    const sigBytes = Buffer.from(testVectorMessageZeroLength.signature, 'hex');
    const signature = Crypto.Ed25519Signature.fromBytes(sigBytes);
    expect(signature.bytes()).toBe(sigBytes);
  });

  test('throws if a signature of invalid size is given.', () => {
    expect(() => Crypto.Ed25519Signature.fromHex(Crypto.Ed25519SignatureHex('1f'))).toThrow(InvalidStringError);
    expect(() =>
      Crypto.Ed25519Signature.fromHex(Crypto.Ed25519SignatureHex(`${testVectorMessageZeroLength.signature}1f2f3f`))
    ).toThrow(InvalidStringError);
  });
});
