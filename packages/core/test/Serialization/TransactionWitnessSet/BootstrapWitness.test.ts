/* eslint-disable sonarjs/no-duplicate-string */
import * as Cardano from '../../../src/Cardano';
import * as Crypto from '@cardano-sdk/crypto';
import { Base64Blob, HexBlob, InvalidStateError } from '@cardano-sdk/util';
import { BootstrapWitness } from '../../../src/Serialization';

// Test data used in the following tests was generated with the cardano-serialization-lib
const cbor = HexBlob(
  '8458203d4017c3e843895a92b70aa74d1b7ebc9c982ccf2ec4968cc0cd55f12af4660c58406291d657deec24024827e69c3abe01a30ce548a284743a445e3680d7db5ac3ac18ff9b538d16f290ae67f760984dc6594a7c15e9716ed28dc027beceea1ec40a5820000000000000000000000000000000000000000000000000000000000000000041a0'
);

const vkeyHex = '3d4017c3e843895a92b70aa74d1b7ebc9c982ccf2ec4968cc0cd55f12af4660c';
const signatureHex =
  '6291d657deec24024827e69c3abe01a30ce548a284743a445e3680d7db5ac3ac18ff9b538d16f290ae67f760984dc6594a7c15e9716ed28dc027beceea1ec40a';
const chainCode31Bytes = HexBlob('00'.repeat(31));
const chainCode33Bytes = HexBlob('00'.repeat(33));

const cborChainCode31 = HexBlob(`845820${vkeyHex}5840${signatureHex}581f${'00'.repeat(31)}41a0`);
const cborChainCode33 = HexBlob(`845820${vkeyHex}5840${signatureHex}5821${'00'.repeat(33)}41a0`);

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

  it('round trips a 32-byte chain code byte-exact', () => {
    expect(BootstrapWitness.fromCbor(cbor).toCbor()).toEqual(cbor);
    expect(BootstrapWitness.fromCore(core).toCbor()).toEqual(cbor);
  });

  // Enforcement decision (Dijkstra CDDL: chain_code : bytes .size 32): the 32-byte
  // constraint is enforced on encode paths only (toCbor, fromCore, setChainCode).
  // Upstream cardano-ledger Bootstrap.hs (commit 9b81d994) rejects non-32-byte chain
  // codes in DecCBOR only whenDecoderVersionAtLeast 12, so the constraint has not
  // always been enforced on decode; fromCbor stays permissive so historical chain
  // data remains readable.
  describe('chain_code size enforcement', () => {
    it('fromCore throws for 31-byte and 33-byte chain codes with a specific error message', () => {
      expect(() => BootstrapWitness.fromCore({ ...core, chainCode: chainCode31Bytes })).toThrowError(
        new InvalidStateError('chainCode is expected to be 32 bytes in size, but got 31')
      );
      expect(() => BootstrapWitness.fromCore({ ...core, chainCode: chainCode33Bytes })).toThrowError(
        new InvalidStateError('chainCode is expected to be 32 bytes in size, but got 33')
      );
    });

    it('setChainCode throws for 31-byte and 33-byte chain codes', () => {
      const witness = BootstrapWitness.fromCbor(cbor);
      expect(() => witness.setChainCode(chainCode31Bytes)).toThrowError(
        new InvalidStateError('chainCode is expected to be 32 bytes in size, but got 31')
      );
      expect(() => witness.setChainCode(chainCode33Bytes)).toThrowError(
        new InvalidStateError('chainCode is expected to be 32 bytes in size, but got 33')
      );
    });

    it('toCbor throws for 31-byte and 33-byte chain codes set via the constructor', () => {
      const key = Crypto.Ed25519PublicKeyHex(vkeyHex);
      const signature = Crypto.Ed25519SignatureHex(signatureHex);
      expect(() => new BootstrapWitness(key, signature, chainCode31Bytes, HexBlob('a0')).toCbor()).toThrowError(
        new InvalidStateError('chainCode is expected to be 32 bytes in size, but got 31')
      );
      expect(() => new BootstrapWitness(key, signature, chainCode33Bytes, HexBlob('a0')).toCbor()).toThrowError(
        new InvalidStateError('chainCode is expected to be 32 bytes in size, but got 33')
      );
    });

    it('fromCbor stays permissive for non-32-byte chain codes and round trips byte-exact', () => {
      const witness31 = BootstrapWitness.fromCbor(cborChainCode31);
      expect(witness31.chainCode()).toEqual(chainCode31Bytes);
      expect(witness31.toCbor()).toEqual(cborChainCode31);

      const witness33 = BootstrapWitness.fromCbor(cborChainCode33);
      expect(witness33.chainCode()).toEqual(chainCode33Bytes);
      expect(witness33.toCbor()).toEqual(cborChainCode33);
    });
  });
});
