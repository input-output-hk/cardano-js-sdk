import { HexBlob } from '@cardano-sdk/util';
import { createCoseKeyCbor, createCoseSign1Cbor, createProtectedHeadersCbor } from '../../src/cip8/coseUtils';

// Test vectors generated with @emurgo/cardano-message-signing-nodejs WASM library
// to ensure our pure TypeScript implementation produces identical CBOR output.

const CBOR_MATCHING_WASM_OUTPUT = 'produces CBOR matching WASM output';

const vectors = {
  // Enterprise address (short, 29 bytes)
  vector1: {
    addressHex: '6199eb65b21702e0872e41b90ff1bfe237b64f23c53bee9074ef38ca5c',
    expected: {
      coseKey:
        'a5010102581d6199eb65b21702e0872e41b90ff1bfe237b64f23c53bee9074ef38ca5c03272006215820deadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeef',
      coseSign1:
        '84582aa201276761646472657373581d6199eb65b21702e0872e41b90ff1bfe237b64f23c53bee9074ef38ca5ca166686173686564f44548656c6c6f5840bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb',
      protectedHeaders: 'a201276761646472657373581d6199eb65b21702e0872e41b90ff1bfe237b64f23c53bee9074ef38ca5c'
    },
    payloadHex: '48656c6c6f',
    publicKeyHex: 'deadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeef',
    signatureHex:
      'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb'
  },
  // Base address (longer, 57 bytes)
  vector2: {
    addressHex:
      '00d73b4d5548f4d00a1947e9284ccdcdc565dd4b85b36e88533c54ed9bfa2e192363674c755f5efe81c620f18bddf8cf63f181d1366fffef34',
    expected: {
      coseKey:
        'a5010102583900d73b4d5548f4d00a1947e9284ccdcdc565dd4b85b36e88533c54ed9bfa2e192363674c755f5efe81c620f18bddf8cf63f181d1366fffef34032720062158203fe822fca223192577130a288b766fcac5b2b8972d89fc229bbc00af60aeaf67',
      coseSign1:
        '845846a201276761646472657373583900d73b4d5548f4d00a1947e9284ccdcdc565dd4b85b36e88533c54ed9bfa2e192363674c755f5efe81c620f18bddf8cf63f181d1366fffef34a166686173686564f443abc1235840aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
      coseSign1Hashed:
        '845846a201276761646472657373583900d73b4d5548f4d00a1947e9284ccdcdc565dd4b85b36e88533c54ed9bfa2e192363674c755f5efe81c620f18bddf8cf63f181d1366fffef34a166686173686564f543abc1235840aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
      protectedHeaders:
        'a201276761646472657373583900d73b4d5548f4d00a1947e9284ccdcdc565dd4b85b36e88533c54ed9bfa2e192363674c755f5efe81c620f18bddf8cf63f181d1366fffef34'
    },
    payloadHex: 'abc123',
    publicKeyHex: '3fe822fca223192577130a288b766fcac5b2b8972d89fc229bbc00af60aeaf67',
    signatureHex:
      'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'
  }
};

describe('coseUtils', () => {
  describe('createProtectedHeadersCbor', () => {
    it(`${CBOR_MATCHING_WASM_OUTPUT} for enterprise address`, () => {
      const { addressHex, expected } = vectors.vector1;
      const result = createProtectedHeadersCbor(Buffer.from(addressHex, 'hex'));
      expect(HexBlob.fromBytes(result)).toBe(expected.protectedHeaders);
    });

    it(`${CBOR_MATCHING_WASM_OUTPUT} for base address`, () => {
      const { addressHex, expected } = vectors.vector2;
      const result = createProtectedHeadersCbor(Buffer.from(addressHex, 'hex'));
      expect(HexBlob.fromBytes(result)).toBe(expected.protectedHeaders);
    });
  });

  describe('createCoseSign1Cbor', () => {
    it(`${CBOR_MATCHING_WASM_OUTPUT} (hashed=false)`, () => {
      const { addressHex, payloadHex, signatureHex, expected } = vectors.vector2;
      const protectedHeaders = createProtectedHeadersCbor(Buffer.from(addressHex, 'hex'));
      const result = createCoseSign1Cbor(
        protectedHeaders,
        Buffer.from(payloadHex, 'hex'),
        Buffer.from(signatureHex, 'hex'),
        false
      );
      expect(HexBlob.fromBytes(result)).toBe(expected.coseSign1);
    });

    it(`${CBOR_MATCHING_WASM_OUTPUT} (hashed=true)`, () => {
      const { addressHex, payloadHex, signatureHex, expected } = vectors.vector2;
      const protectedHeaders = createProtectedHeadersCbor(Buffer.from(addressHex, 'hex'));
      const result = createCoseSign1Cbor(
        protectedHeaders,
        Buffer.from(payloadHex, 'hex'),
        Buffer.from(signatureHex, 'hex'),
        true
      );
      expect(HexBlob.fromBytes(result)).toBe(expected.coseSign1Hashed);
    });

    it(`${CBOR_MATCHING_WASM_OUTPUT} for enterprise address`, () => {
      const { addressHex, payloadHex, signatureHex, expected } = vectors.vector1;
      const protectedHeaders = createProtectedHeadersCbor(Buffer.from(addressHex, 'hex'));
      const result = createCoseSign1Cbor(
        protectedHeaders,
        Buffer.from(payloadHex, 'hex'),
        Buffer.from(signatureHex, 'hex'),
        false
      );
      expect(HexBlob.fromBytes(result)).toBe(expected.coseSign1);
    });
  });

  describe('createCoseKeyCbor', () => {
    it(`${CBOR_MATCHING_WASM_OUTPUT} for enterprise address`, () => {
      const { addressHex, publicKeyHex, expected } = vectors.vector1;
      const result = createCoseKeyCbor(Buffer.from(addressHex, 'hex'), publicKeyHex);
      expect(HexBlob.fromBytes(result)).toBe(expected.coseKey);
    });

    it(`${CBOR_MATCHING_WASM_OUTPUT} for base address`, () => {
      const { addressHex, publicKeyHex, expected } = vectors.vector2;
      const result = createCoseKeyCbor(Buffer.from(addressHex, 'hex'), publicKeyHex);
      expect(HexBlob.fromBytes(result)).toBe(expected.coseKey);
    });
  });
});
