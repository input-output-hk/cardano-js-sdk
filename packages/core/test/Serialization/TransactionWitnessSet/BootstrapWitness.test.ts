/* eslint-disable sonarjs/no-duplicate-string */
import * as Crypto from '@cardano-sdk/crypto';
import { Base64Blob, HexBlob, InvalidStateError } from '@cardano-sdk/util';
import { BootstrapWitness } from '../../../src/Serialization/index.js';
import type * as Cardano from '../../../src/Cardano/index.js';

// Test data used in the following tests was generated with the cardano-serialization-lib
const cbor = HexBlob(
  '8458203d4017c3e843895a92b70aa74d1b7ebc9c982ccf2ec4968cc0cd55f12af4660c58406291d657deec24024827e69c3abe01a30ce548a284743a445e3680d7db5ac3ac18ff9b538d16f290ae67f760984dc6594a7c15e9716ed28dc027beceea1ec40a5820000000000000000000000000000000000000000000000000000000000000000041a0'
);

const core: Cardano.BootstrapWitness = {
  addressAttributes: Base64Blob('oA=='),
  chainCode: HexBlob('0000000000000000000000000000000000000000000000000000000000000000'),
  key: Crypto.Ed25519PublicKeyHex('3d4017c3e843895a92b70aa74d1b7ebc9c982ccf2ec4968cc0cd55f12af4660c'),
  signature: Crypto.Ed25519SignatureHex(
    '6291d657deec24024827e69c3abe01a30ce548a284743a445e3680d7db5ac3ac18ff9b538d16f290ae67f760984dc6594a7c15e9716ed28dc027beceea1ec40a'
  )
};

describe('BootstrapWitness', () => {
  it('can decode BootstrapWitness from CBOR', () => {
    const witness = BootstrapWitness.fromCbor(cbor);

    expect(witness.chainCode()).toEqual('0000000000000000000000000000000000000000000000000000000000000000');
    expect(witness.signature()).toEqual(
      '6291d657deec24024827e69c3abe01a30ce548a284743a445e3680d7db5ac3ac18ff9b538d16f290ae67f760984dc6594a7c15e9716ed28dc027beceea1ec40a'
    );
    expect(witness.vkey()).toEqual('3d4017c3e843895a92b70aa74d1b7ebc9c982ccf2ec4968cc0cd55f12af4660c');
    expect(witness.attributes()).toEqual('a0');
  });

  it('can decode BootstrapWitness from Core', () => {
    const witness = BootstrapWitness.fromCore(core);

    expect(witness.chainCode()).toEqual('0000000000000000000000000000000000000000000000000000000000000000');
    expect(witness.signature()).toEqual(
      '6291d657deec24024827e69c3abe01a30ce548a284743a445e3680d7db5ac3ac18ff9b538d16f290ae67f760984dc6594a7c15e9716ed28dc027beceea1ec40a'
    );
    expect(witness.vkey()).toEqual('3d4017c3e843895a92b70aa74d1b7ebc9c982ccf2ec4968cc0cd55f12af4660c');
    expect(witness.attributes()).toEqual('a0');
  });

  it('can encode BootstrapWitness to CBOR', () => {
    const witness = BootstrapWitness.fromCore(core);
    expect(witness.toCbor()).toEqual(cbor);
  });

  it('can encode BootstrapWitness to Core', () => {
    const witness = BootstrapWitness.fromCbor(cbor);
    expect(witness.toCore()).toEqual(core);
  });

  it('encodes attributes as empty byte string if field not present', () => {
    const witness = BootstrapWitness.fromCore({
      chainCode: HexBlob('0000000000000000000000000000000000000000000000000000000000000000'),
      key: Crypto.Ed25519PublicKeyHex('3d4017c3e843895a92b70aa74d1b7ebc9c982ccf2ec4968cc0cd55f12af4660c'),
      signature: Crypto.Ed25519SignatureHex(
        '6291d657deec24024827e69c3abe01a30ce548a284743a445e3680d7db5ac3ac18ff9b538d16f290ae67f760984dc6594a7c15e9716ed28dc027beceea1ec40a'
      )
    });
    expect(witness.toCbor()).toEqual(cbor);
    expect(witness.chainCode()).toEqual('0000000000000000000000000000000000000000000000000000000000000000');
    expect(witness.signature()).toEqual(
      '6291d657deec24024827e69c3abe01a30ce548a284743a445e3680d7db5ac3ac18ff9b538d16f290ae67f760984dc6594a7c15e9716ed28dc027beceea1ec40a'
    );
    expect(witness.vkey()).toEqual('3d4017c3e843895a92b70aa74d1b7ebc9c982ccf2ec4968cc0cd55f12af4660c');
    expect(witness.attributes()).toEqual('a0');
  });

  it('throws if chainCode is not present', () => {
    expect(() =>
      BootstrapWitness.fromCore({
        key: Crypto.Ed25519PublicKeyHex('3d4017c3e843895a92b70aa74d1b7ebc9c982ccf2ec4968cc0cd55f12af4660c'),
        signature: Crypto.Ed25519SignatureHex(
          '6291d657deec24024827e69c3abe01a30ce548a284743a445e3680d7db5ac3ac18ff9b538d16f290ae67f760984dc6594a7c15e9716ed28dc027beceea1ec40a'
        )
      })
    ).toThrowError(InvalidStateError);
  });

  it('throws if chainCode is not 32 bytes long', () => {
    expect(() =>
      BootstrapWitness.fromCore({
        chainCode: HexBlob('00000000000000000000000000000000000000000000000000000000'),
        key: Crypto.Ed25519PublicKeyHex('3d4017c3e843895a92b70aa74d1b7ebc9c982ccf2ec4968cc0cd55f12af4660c'),
        signature: Crypto.Ed25519SignatureHex(
          '6291d657deec24024827e69c3abe01a30ce548a284743a445e3680d7db5ac3ac18ff9b538d16f290ae67f760984dc6594a7c15e9716ed28dc027beceea1ec40a'
        )
      })
    ).toThrowError(InvalidStateError);
  });
});
