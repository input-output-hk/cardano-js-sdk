/* eslint-disable sonarjs/no-duplicate-string */
import * as Crypto from '@cardano-sdk/crypto';
import { Base64Blob, HexBlob } from '@cardano-sdk/util';
import { Cardano } from '../../../src';
import { RedeemerPurpose } from '../../../src/Cardano';
import { TransactionWitnessSet } from '../../../src/Serialization';

// Test data used in the following tests was generated with the cardano-serialization-lib
const cbor = HexBlob(
  'a700838258204a352f53eb4311d552aa9e1c6f0125846a3b607011d691f0e774d893d940b8525840c4f13cc397a50193061ce899b3eda906ad1adf3f3d515b52248ea5aa142781cd9c2ccc52ac62b2e1b5226de890104ec530bda4c38a19b691946da9addb3213f5825820290c08454c58a8c7fad6351e65a652460bd4f80f485f1ccfc350ff6a4d5bd4de5840026f47bab2f24da9690746bdb0e55d53a5eef45a969e3dd2873a3e6bb8ef3316d9f80489bacfd2f543108e284a40847ae7ce33fa358fcfe439a37990ad3107e98258204d953d6a9d556da3f3e26622c725923130f5733d1a3c4013ef8c34d15a070fd75840f9218e5a569c5ace38b1bb81e1f1c0b2d7fea2fe7fb913fdd06d79906436103345347a81494b83f83bf43466b0cebdbbdcef15384f67c255e826c249336ce2c701848204038205098202818200581c3542acb3a64d80c29302260d62c3b87a742ad14abf855ebc6733081e830300818200581cb5ae663aaea8e500157bdf4baafd6f5ba0ce5759f7cd4101fc132f5402828458203d4017c3e843895a92b70aa74d1b7ebc9c982ccf2ec4968cc0cd55f12af4660c58406291d657deec24024827e69c3abe01a30ce548a284743a445e3680d7db5ac3ac18ff9b538d16f290ae67f760984dc6594a7c15e9716ed28dc027beceea1ec40a5820000000000000000000000000000000000000000000000000000000000000000041a08458203d4017c3e863895a92b70aa74d1b7ebc9c982ccf2ec4968cc0cd55f12af4660c58406291d657deec24024827e69c3abe01a30ce548a284743a445e3680d7db5ac3ac18ff9b538d16f290ae67f760984dc6594a7c15e9716ed28dc027beceea1ec40a5820ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff41a00384474601000022001047460100002200114746010000220012474601000022001304833bffffffffffffffff3bffffffffffffffff3bffffffffffffffff0584840000d8799f0102030405ff821b000086788ffc4e831b00015060e9e46451840100d8799f0102030405ff821b000086788ffc4e831b00015060e9e46451840200d8799f0102030405ff821b000086788ffc4e831b00015060e9e46451840300d8799f0102030405ff821b000086788ffc4e831b00015060e9e4645106844746010000220010474601000022001147460100002200124746010000220013'
);

const cborWithSets = HexBlob(
  'a700d90102838258204a352f53eb4311d552aa9e1c6f0125846a3b607011d691f0e774d893d940b8525840c4f13cc397a50193061ce899b3eda906ad1adf3f3d515b52248ea5aa142781cd9c2ccc52ac62b2e1b5226de890104ec530bda4c38a19b691946da9addb3213f5825820290c08454c58a8c7fad6351e65a652460bd4f80f485f1ccfc350ff6a4d5bd4de5840026f47bab2f24da9690746bdb0e55d53a5eef45a969e3dd2873a3e6bb8ef3316d9f80489bacfd2f543108e284a40847ae7ce33fa358fcfe439a37990ad3107e98258204d953d6a9d556da3f3e26622c725923130f5733d1a3c4013ef8c34d15a070fd75840f9218e5a569c5ace38b1bb81e1f1c0b2d7fea2fe7fb913fdd06d79906436103345347a81494b83f83bf43466b0cebdbbdcef15384f67c255e826c249336ce2c701d90102848204038205098202818200581c3542acb3a64d80c29302260d62c3b87a742ad14abf855ebc6733081e830300818200581cb5ae663aaea8e500157bdf4baafd6f5ba0ce5759f7cd4101fc132f5402d90102828458203d4017c3e843895a92b70aa74d1b7ebc9c982ccf2ec4968cc0cd55f12af4660c58406291d657deec24024827e69c3abe01a30ce548a284743a445e3680d7db5ac3ac18ff9b538d16f290ae67f760984dc6594a7c15e9716ed28dc027beceea1ec40a5820000000000000000000000000000000000000000000000000000000000000000041a08458203d4017c3e863895a92b70aa74d1b7ebc9c982ccf2ec4968cc0cd55f12af4660c58406291d657deec24024827e69c3abe01a30ce548a284743a445e3680d7db5ac3ac18ff9b538d16f290ae67f760984dc6594a7c15e9716ed28dc027beceea1ec40a5820ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff41a003d9010284474601000022001047460100002200114746010000220012474601000022001304d90102833bffffffffffffffff3bffffffffffffffff3bffffffffffffffff05a482000082d8799f0102030405ff821b000086788ffc4e831b00015060e9e4645182010082d8799f0102030405ff821b000086788ffc4e831b00015060e9e4645182020082d8799f0102030405ff821b000086788ffc4e831b00015060e9e4645182030082d8799f0102030405ff821b000086788ffc4e831b00015060e9e4645106d90102844746010000220010474601000022001147460100002200124746010000220013'
);

const simpleWitnessCbor = HexBlob(
  'a100838258204a352f53eb4311d552aa9e1c6f0125846a3b607011d691f0e774d893d940b8525840c4f13cc397a50193061ce899b3eda906ad1adf3f3d515b52248ea5aa142781cd9c2ccc52ac62b2e1b5226de890104ec530bda4c38a19b691946da9addb3213f5825820290c08454c58a8c7fad6351e65a652460bd4f80f485f1ccfc350ff6a4d5bd4de5840026f47bab2f24da9690746bdb0e55d53a5eef45a969e3dd2873a3e6bb8ef3316d9f80489bacfd2f543108e284a40847ae7ce33fa358fcfe439a37990ad3107e98258204d953d6a9d556da3f3e26622c725923130f5733d1a3c4013ef8c34d15a070fd75840f9218e5a569c5ace38b1bb81e1f1c0b2d7fea2fe7fb913fdd06d79906436103345347a81494b83f83bf43466b0cebdbbdcef15384f67c255e826c249336ce2c7'
);

const core: Cardano.Witness = {
  bootstrap: [
    {
      addressAttributes: Base64Blob('oA=='),
      chainCode: HexBlob('0000000000000000000000000000000000000000000000000000000000000000'),
      key: Crypto.Ed25519PublicKeyHex('3d4017c3e843895a92b70aa74d1b7ebc9c982ccf2ec4968cc0cd55f12af4660c'),
      signature: Crypto.Ed25519SignatureHex(
        '6291d657deec24024827e69c3abe01a30ce548a284743a445e3680d7db5ac3ac18ff9b538d16f290ae67f760984dc6594a7c15e9716ed28dc027beceea1ec40a'
      )
    },
    {
      addressAttributes: Base64Blob('oA=='),
      chainCode: HexBlob('ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff'),
      key: Crypto.Ed25519PublicKeyHex('3d4017c3e863895a92b70aa74d1b7ebc9c982ccf2ec4968cc0cd55f12af4660c'),
      signature: Crypto.Ed25519SignatureHex(
        '6291d657deec24024827e69c3abe01a30ce548a284743a445e3680d7db5ac3ac18ff9b538d16f290ae67f760984dc6594a7c15e9716ed28dc027beceea1ec40a'
      )
    }
  ],
  datums: [-18_446_744_073_709_551_616n, -18_446_744_073_709_551_616n, -18_446_744_073_709_551_616n],
  redeemers: [
    {
      data: {
        cbor: HexBlob('d8799f0102030405ff'),
        constructor: 0n,
        fields: { cbor: HexBlob('9f0102030405ff'), items: [1n, 2n, 3n, 4n, 5n] }
      },
      executionUnits: { memory: 147_852_369_874_563, steps: 369_852_147_852_369 },
      index: 0,
      purpose: RedeemerPurpose.spend
    },
    {
      data: {
        cbor: HexBlob('d8799f0102030405ff'),
        constructor: 0n,
        fields: { cbor: HexBlob('9f0102030405ff'), items: [1n, 2n, 3n, 4n, 5n] }
      },
      executionUnits: { memory: 147_852_369_874_563, steps: 369_852_147_852_369 },
      index: 0,
      purpose: RedeemerPurpose.mint
    },
    {
      data: {
        cbor: HexBlob('d8799f0102030405ff'),
        constructor: 0n,
        fields: { cbor: HexBlob('9f0102030405ff'), items: [1n, 2n, 3n, 4n, 5n] }
      },
      executionUnits: { memory: 147_852_369_874_563, steps: 369_852_147_852_369 },
      index: 0,
      purpose: RedeemerPurpose.certificate
    },
    {
      data: {
        cbor: HexBlob('d8799f0102030405ff'),
        constructor: 0n,
        fields: { cbor: HexBlob('9f0102030405ff'), items: [1n, 2n, 3n, 4n, 5n] }
      },
      executionUnits: { memory: 147_852_369_874_563, steps: 369_852_147_852_369 },
      index: 0,
      purpose: RedeemerPurpose.withdrawal
    }
  ],
  scripts: [
    {
      __type: Cardano.ScriptType.Plutus,
      bytes: HexBlob('46010000220010'),
      version: Cardano.PlutusLanguageVersion.V1
    },
    {
      __type: Cardano.ScriptType.Plutus,
      bytes: HexBlob('46010000220011'),
      version: Cardano.PlutusLanguageVersion.V1
    },
    {
      __type: Cardano.ScriptType.Plutus,
      bytes: HexBlob('46010000220012'),
      version: Cardano.PlutusLanguageVersion.V1
    },
    {
      __type: Cardano.ScriptType.Plutus,
      bytes: HexBlob('46010000220013'),
      version: Cardano.PlutusLanguageVersion.V1
    },
    {
      __type: Cardano.ScriptType.Plutus,
      bytes: HexBlob('46010000220010'),
      version: Cardano.PlutusLanguageVersion.V2
    },
    {
      __type: Cardano.ScriptType.Plutus,
      bytes: HexBlob('46010000220011'),
      version: Cardano.PlutusLanguageVersion.V2
    },
    {
      __type: Cardano.ScriptType.Plutus,
      bytes: HexBlob('46010000220012'),
      version: Cardano.PlutusLanguageVersion.V2
    },
    { __type: Cardano.ScriptType.Plutus, bytes: HexBlob('46010000220013'), version: Cardano.PlutusLanguageVersion.V2 },
    { __type: Cardano.ScriptType.Native, kind: 4, slot: Cardano.Slot(3) },
    { __type: Cardano.ScriptType.Native, kind: 5, slot: Cardano.Slot(9) },
    {
      __type: Cardano.ScriptType.Native,
      kind: Cardano.NativeScriptKind.RequireAnyOf,
      scripts: [
        {
          __type: Cardano.ScriptType.Native,
          keyHash: Crypto.Ed25519KeyHashHex('3542acb3a64d80c29302260d62c3b87a742ad14abf855ebc6733081e'),
          kind: Cardano.NativeScriptKind.RequireSignature
        }
      ]
    },
    {
      __type: Cardano.ScriptType.Native,
      kind: Cardano.NativeScriptKind.RequireNOf,
      required: 0,
      scripts: [
        {
          __type: Cardano.ScriptType.Native,
          keyHash: Crypto.Ed25519KeyHashHex('b5ae663aaea8e500157bdf4baafd6f5ba0ce5759f7cd4101fc132f54'),
          kind: Cardano.NativeScriptKind.RequireSignature
        }
      ]
    }
  ],
  signatures: new Map([
    [
      Crypto.Ed25519PublicKeyHex('4a352f53eb4311d552aa9e1c6f0125846a3b607011d691f0e774d893d940b852'),
      Crypto.Ed25519SignatureHex(
        'c4f13cc397a50193061ce899b3eda906ad1adf3f3d515b52248ea5aa142781cd9c2ccc52ac62b2e1b5226de890104ec530bda4c38a19b691946da9addb3213f5'
      )
    ],
    [
      Crypto.Ed25519PublicKeyHex('290c08454c58a8c7fad6351e65a652460bd4f80f485f1ccfc350ff6a4d5bd4de'),
      Crypto.Ed25519SignatureHex(
        '026f47bab2f24da9690746bdb0e55d53a5eef45a969e3dd2873a3e6bb8ef3316d9f80489bacfd2f543108e284a40847ae7ce33fa358fcfe439a37990ad3107e9'
      )
    ],
    [
      Crypto.Ed25519PublicKeyHex('4d953d6a9d556da3f3e26622c725923130f5733d1a3c4013ef8c34d15a070fd7'),
      Crypto.Ed25519SignatureHex(
        'f9218e5a569c5ace38b1bb81e1f1c0b2d7fea2fe7fb913fdd06d79906436103345347a81494b83f83bf43466b0cebdbbdcef15384f67c255e826c249336ce2c7'
      )
    ]
  ])
};

const simpleCore: Cardano.Witness = {
  signatures: new Map([
    [
      Crypto.Ed25519PublicKeyHex('4a352f53eb4311d552aa9e1c6f0125846a3b607011d691f0e774d893d940b852'),
      Crypto.Ed25519SignatureHex(
        'c4f13cc397a50193061ce899b3eda906ad1adf3f3d515b52248ea5aa142781cd9c2ccc52ac62b2e1b5226de890104ec530bda4c38a19b691946da9addb3213f5'
      )
    ],
    [
      Crypto.Ed25519PublicKeyHex('290c08454c58a8c7fad6351e65a652460bd4f80f485f1ccfc350ff6a4d5bd4de'),
      Crypto.Ed25519SignatureHex(
        '026f47bab2f24da9690746bdb0e55d53a5eef45a969e3dd2873a3e6bb8ef3316d9f80489bacfd2f543108e284a40847ae7ce33fa358fcfe439a37990ad3107e9'
      )
    ],
    [
      Crypto.Ed25519PublicKeyHex('4d953d6a9d556da3f3e26622c725923130f5733d1a3c4013ef8c34d15a070fd7'),
      Crypto.Ed25519SignatureHex(
        'f9218e5a569c5ace38b1bb81e1f1c0b2d7fea2fe7fb913fdd06d79906436103345347a81494b83f83bf43466b0cebdbbdcef15384f67c255e826c249336ce2c7'
      )
    ]
  ])
};

describe('TransactionWitnessSet', () => {
  it('can encode TransactionWitnessSet to CBOR', () => {
    const witness = TransactionWitnessSet.fromCore(core);
    expect(witness.toCbor()).toEqual(cbor);
  });

  it('can encode TransactionWitnessSet to Core', () => {
    const witness = TransactionWitnessSet.fromCbor(cbor);
    expect(witness.toCore()).toEqual(core);
  });

  it('can encode TransactionWitnessSet with 6.248 tags to Core', () => {
    const witness = TransactionWitnessSet.fromCbor(cborWithSets);
    expect(witness.toCore()).toEqual(core);
  });

  it('can encode simple TransactionWitnessSet to CBOR', () => {
    const witness = TransactionWitnessSet.fromCore(simpleCore);
    expect(witness.toCbor()).toEqual(simpleWitnessCbor);
  });

  it('can encode simple TransactionWitnessSet to Core', () => {
    const witness = TransactionWitnessSet.fromCbor(simpleWitnessCbor);
    expect(witness.toCore()).toEqual(simpleCore);
  });
});
