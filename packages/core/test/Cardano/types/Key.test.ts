/* eslint-disable max-len */
import { Cardano } from '../../../src';

describe('Cardano/types/Key', () => {
  it('Ed25519PublicKey() accepts a valid public key hex string', () => {
    expect(() =>
      Cardano.Ed25519PublicKey('6199186adb51974690d7247d2646097d2c62763b767b528816fb7ed3f9f55d39')
    ).not.toThrow();
    expect(() =>
      Cardano.Ed25519PublicKey.fromHexBlob(
        Cardano.util.HexBlob('6199186adb51974690d7247d2646097d2c62763b767b528816fb7ed3f9f55d39')
      )
    ).not.toThrow();
  });

  it('Ed25519KeyHash() accepts a key hash hex string', () => {
    expect(() =>
      Cardano.Ed25519KeyHash('6199186adb51974690d7247d2646097d2c62763b767b528816fb7ed3f9f55d39')
    ).not.toThrow();
  });

  it('Bip32PublicKey() accepts a valid public key hex string', () => {
    expect(() =>
      Cardano.Bip32PublicKey(
        '6199186adb51974690d7247d2646097d2c62763b767b528816fb7ed3f9f55d396199186adb51974690d7247d2646097d2c62763b767b528816fb7ed3f9f55d39'
      )
    ).not.toThrow();
    expect(() =>
      Cardano.Bip32PublicKey.fromHexBlob(
        Cardano.util.HexBlob(
          '6199186adb51974690d7247d2646097d2c62763b767b528816fb7ed3f9f55d396199186adb51974690d7247d2646097d2c62763b767b528816fb7ed3f9f55d39'
        )
      )
    ).not.toThrow();
  });

  it('Bip32PrivateKey() accepts a valid public key hex string', () => {
    expect(() =>
      Cardano.Bip32PrivateKey(
        '6199186adb51974690d7247d2646097d2c62763b767b528816fb7ed3f9f55d36199186adb51974690d7247d2646097d2c62763b767b528816fb7ed3f9f55d3996199186adb51974690d7247d2646097d2c62763b767b528816fb7ed3f9f55d39'
      )
    ).not.toThrow();
    expect(() =>
      Cardano.Bip32PrivateKey.fromHexBlob(
        Cardano.util.HexBlob(
          '6199186adb51974690d7247d2646097d2c62763b767b528816fb7ed3f9f55d36199186adb51974690d7247d2646097d2c62763b767b528816fb7ed3f9f55d3996199186adb51974690d7247d2646097d2c62763b767b528816fb7ed3f9f55d39'
        )
      )
    ).not.toThrow();
  });
});
