/* eslint-disable sonarjs/no-duplicate-string */
import * as Crypto from '@cardano-sdk/crypto';
import { HexBlob } from '@cardano-sdk/util';
import { TransactionWitnessSet, VkeyWitness } from '../../../src/Serialization';

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

  it('should preserve original CBOR encoding of properties that do not change', () => {
    const combinedWitnesses = HexBlob(
      'a40081825820cb845bb836d4baf4edffb9f76198072cbc70f0d8bb5402644ffd4db17e65259f5840af14dccbdbb1fc9d122ba240df264336a6543a44cd2207bc3e7f3c671c3ecb156a4e9902dc1f15277a933d8ce57dc77960eaf0f58e0b1581aa1810dd6300170c03814e4d01000033222220051200120011049f4b7375706572736563726574ff0581840000d87980821a006acfc01ab2d05e00'
    );

    const witnessWithDatum = TransactionWitnessSet.fromCbor(
      HexBlob(
        'a303814e4d01000033222220051200120011049f4b7375706572736563726574ff0581840000d87980821a006acfc01ab2d05e00'
      )
    );

    const vkWitness = TransactionWitnessSet.fromCbor(
      HexBlob(
        'a10081825820cb845bb836d4baf4edffb9f76198072cbc70f0d8bb5402644ffd4db17e65259f5840af14dccbdbb1fc9d122ba240df264336a6543a44cd2207bc3e7f3c671c3ecb156a4e9902dc1f15277a933d8ce57dc77960eaf0f58e0b1581aa1810dd6300170c'
      )
    );

    witnessWithDatum.setVkeys(vkWitness.vkeys()!);

    expect(witnessWithDatum.toCbor()).toEqual(combinedWitnesses);
  });
});
