/* eslint-disable max-len */
import { Cardano } from '../../../src';

jest.mock('../../../src/Cardano/util/primitives', () => {
  const actual = jest.requireActual('../../../src/Cardano/util/primitives');
  return {
    Hash32ByteBase16: jest.fn().mockImplementation((...args) => actual.Hash32ByteBase16(...args)),
    typedHex: jest.fn().mockImplementation((...args) => actual.typedHex(...args))
  };
});

describe('Cardano/types/Key', () => {
  it('Ed25519PublicKey() accepts a valid public key hex string and is implemented using util.typedHex', () => {
    expect(() =>
      Cardano.Ed25519PublicKey('6199186adb51974690d7247d2646097d2c62763b767b528816fb7ed3f9f55d39')
    ).not.toThrow();
    expect(Cardano.util.typedHex).toBeCalledWith(
      '6199186adb51974690d7247d2646097d2c62763b767b528816fb7ed3f9f55d39',
      64
    );
  });

  it('Ed25519KeyHash() accepts a key hash hex string and is implemented using util.Hash32ByteBase16', () => {
    expect(() =>
      Cardano.Ed25519KeyHash('6199186adb51974690d7247d2646097d2c62763b767b528816fb7ed3f9f55d39')
    ).not.toThrow();
    expect(Cardano.util.Hash32ByteBase16).toBeCalledWith(
      '6199186adb51974690d7247d2646097d2c62763b767b528816fb7ed3f9f55d39'
    );
  });

  it('Bip32PublicKey() accepts a valid public key hex string and is implemented using util.typedHex', () => {
    expect(() =>
      Cardano.Bip32PublicKey(
        '6199186adb51974690d7247d2646097d2c62763b767b528816fb7ed3f9f55d396199186adb51974690d7247d2646097d2c62763b767b528816fb7ed3f9f55d39'
      )
    ).not.toThrow();
    expect(Cardano.util.typedHex).toBeCalledWith(
      '6199186adb51974690d7247d2646097d2c62763b767b528816fb7ed3f9f55d396199186adb51974690d7247d2646097d2c62763b767b528816fb7ed3f9f55d39',
      128
    );
  });

  it('Bip32PrivateKey() accepts a valid public key hex string and is implemented using util.typedHex', () => {
    expect(() =>
      Cardano.Bip32PrivateKey(
        '6199186adb51974690d7247d2646097d2c62763b767b528816fb7ed3f9f55d36199186adb51974690d7247d2646097d2c62763b767b528816fb7ed3f9f55d3996199186adb51974690d7247d2646097d2c62763b767b528816fb7ed3f9f55d39'
      )
    ).not.toThrow();
    expect(Cardano.util.typedHex).toBeCalledWith(
      '6199186adb51974690d7247d2646097d2c62763b767b528816fb7ed3f9f55d36199186adb51974690d7247d2646097d2c62763b767b528816fb7ed3f9f55d3996199186adb51974690d7247d2646097d2c62763b767b528816fb7ed3f9f55d39',
      192
    );
  });
});
