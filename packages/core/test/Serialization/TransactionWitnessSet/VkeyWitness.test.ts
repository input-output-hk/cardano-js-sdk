/* eslint-disable sonarjs/no-duplicate-string */
import * as Crypto from '@cardano-sdk/crypto';
import { HexBlob } from '@cardano-sdk/util';
import { VkeyWitness } from '../../../src/Serialization/index.js';

// Test data used in the following tests was generated with the cardano-serialization-lib
const cbor = HexBlob(
  '8258203d4017c3e843895a92b70aa74d1b7ebc9c982ccf2ec4968cc0cd55f12af4660c58406291d657deec24024827e69c3abe01a30ce548a284743a445e3680d7db5ac3ac18ff9b538d16f290ae67f760984dc6594a7c15e9716ed28dc027beceea1ec40a'
);

const vkey = Crypto.Ed25519PublicKeyHex('3d4017c3e843895a92b70aa74d1b7ebc9c982ccf2ec4968cc0cd55f12af4660c');
const signature = Crypto.Ed25519SignatureHex(
  '6291d657deec24024827e69c3abe01a30ce548a284743a445e3680d7db5ac3ac18ff9b538d16f290ae67f760984dc6594a7c15e9716ed28dc027beceea1ec40a'
);

describe('VkeyWitness', () => {
  it('can decode VkeyWitness from CBOR', () => {
    const witness = VkeyWitness.fromCbor(cbor);

    expect(witness.vkey()).toEqual('3d4017c3e843895a92b70aa74d1b7ebc9c982ccf2ec4968cc0cd55f12af4660c');
    expect(witness.signature()).toEqual(
      '6291d657deec24024827e69c3abe01a30ce548a284743a445e3680d7db5ac3ac18ff9b538d16f290ae67f760984dc6594a7c15e9716ed28dc027beceea1ec40a'
    );
  });

  it('can decode VkeyWitness from Core', () => {
    const witness = VkeyWitness.fromCore([vkey, signature]);

    expect(witness.vkey()).toEqual('3d4017c3e843895a92b70aa74d1b7ebc9c982ccf2ec4968cc0cd55f12af4660c');
    expect(witness.signature()).toEqual(
      '6291d657deec24024827e69c3abe01a30ce548a284743a445e3680d7db5ac3ac18ff9b538d16f290ae67f760984dc6594a7c15e9716ed28dc027beceea1ec40a'
    );
  });

  it('can encode VkeyWitness to CBOR', () => {
    const witness = VkeyWitness.fromCore([vkey, signature]);
    expect(witness.toCbor()).toEqual(cbor);
  });

  it('can encode VkeyWitness to Core', () => {
    const witness = VkeyWitness.fromCbor(cbor);
    expect(witness.toCore()).toEqual([vkey, signature]);
  });
});
