import { Serialization } from '@cardano-sdk/core';

// COSE algorithm identifiers
export const ALGORITHM_EDDSA = -8;
export const KEY_TYPE_OKP = 1;
export const CURVE_ED25519 = 6;

// COSE key map labels (RFC 8152)
export const COSE_KEY_KTY = 1;
export const COSE_KEY_KID = 2;
export const COSE_KEY_ALG = 3;
export const COSE_KEY_CRV = -1;
export const COSE_KEY_X = -2;

// COSE header labels
export const COSE_HEADER_ALG = 1;

/** Creates CBOR-encoded protected headers for CIP-8 signing (alg + address). */
export const createProtectedHeadersCbor = (addressBytes: Uint8Array): Uint8Array => {
  const writer = new Serialization.CborWriter();
  writer.writeStartMap(2);
  writer.writeInt(COSE_HEADER_ALG);
  writer.writeInt(ALGORITHM_EDDSA);
  writer.writeTextString('address');
  writer.writeByteString(addressBytes);
  return writer.encode();
};

/** Creates a CBOR-encoded COSE_Sign1 structure. */
export const createCoseSign1Cbor = (
  protectedHeadersBytes: Uint8Array,
  payloadBytes: Uint8Array,
  signatureBytes: Uint8Array,
  isHashed: boolean
): Uint8Array => {
  const writer = new Serialization.CborWriter();
  writer.writeStartArray(4);
  writer.writeByteString(protectedHeadersBytes);
  writer.writeStartMap(1);
  writer.writeTextString('hashed');
  writer.writeBoolean(isHashed);
  writer.writeByteString(payloadBytes);
  writer.writeByteString(signatureBytes);
  return writer.encode();
};

/** Creates a CBOR-encoded COSE_Key structure for Ed25519. */
export const createCoseKeyCbor = (addressBytes: Uint8Array, publicKeyHex: string): Uint8Array => {
  const writer = new Serialization.CborWriter();
  writer.writeStartMap(5);
  writer.writeInt(COSE_KEY_KTY);
  writer.writeInt(KEY_TYPE_OKP);
  writer.writeInt(COSE_KEY_KID);
  writer.writeByteString(addressBytes);
  writer.writeInt(COSE_KEY_ALG);
  writer.writeInt(ALGORITHM_EDDSA);
  writer.writeInt(COSE_KEY_CRV);
  writer.writeInt(CURVE_ED25519);
  writer.writeInt(COSE_KEY_X);
  writer.writeByteString(Buffer.from(publicKeyHex, 'hex'));
  return writer.encode();
};
