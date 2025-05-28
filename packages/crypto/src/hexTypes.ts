import { HexBlob, OpaqueString, castHexBlob, typedHex } from '@cardano-sdk/util';

export const BIP32_PUBLIC_KEY_HASH_LENGTH = 28;

/** 28 byte hash as hex string */
export type Hash28ByteBase16 = OpaqueString<'Hash28ByteBase16'> & HexBlob;
/**
 * @param {string} value 28 byte hash as hex string
 * @throws InvalidStringError
 */
export const Hash28ByteBase16 = (value: string): Hash28ByteBase16 => typedHex<Hash28ByteBase16>(value, 56);

/** 32 byte hash as hex string */
export type Hash32ByteBase16 = OpaqueString<'Hash32ByteBase16'> & HexBlob;
/**
 * @param {string} value 32 byte hash as hex string
 * @throws InvalidStringError
 */
export const Hash32ByteBase16 = (value: string): Hash32ByteBase16 => typedHex<Hash32ByteBase16>(value, 64);
Hash32ByteBase16.fromHexBlob = <T>(value: HexBlob) => castHexBlob<T>(value, 64);

/** Ed25519 signature as hex string */
export type Ed25519SignatureHex = OpaqueString<'Ed25519SignatureHex'> & HexBlob;
export const Ed25519SignatureHex = (value: string): Ed25519SignatureHex => typedHex(value, 128);

/** BIP32 public key as hex string */
export type Bip32PublicKeyHex = OpaqueString<'Bip32PublicKeyHex'> & HexBlob;
export const Bip32PublicKeyHex = (key: string): Bip32PublicKeyHex => typedHex(key, 128);

/** BIP32 private key as hex string */
export type Bip32PrivateKeyHex = OpaqueString<'Bip32PrivateKeyHex'> & HexBlob;
export const Bip32PrivateKeyHex = (key: string): Bip32PrivateKeyHex => typedHex(key, 192);

/** Ed25519 public key as hex string */
export type Ed25519PublicKeyHex = OpaqueString<'Ed25519PublicKeyHex'> & HexBlob;
export const Ed25519PublicKeyHex = (value: string): Ed25519PublicKeyHex => typedHex(value, 64);

/** Ed25519 private extended key as hex string */
export type Ed25519PrivateExtendedKeyHex = OpaqueString<'Ed25519PrivateKeyHex'> & HexBlob;
export const Ed25519PrivateExtendedKeyHex = (value: string): Ed25519PrivateExtendedKeyHex => typedHex(value, 128);

/** Ed25519 private normal key as hex string */
export type Ed25519PrivateNormalKeyHex = OpaqueString<'Ed25519PrivateKeyHex'> & HexBlob;
export const Ed25519PrivateNormalKeyHex = (value: string): Ed25519PrivateNormalKeyHex => typedHex(value, 64);

/** 28 byte ED25519 key hash as hex string */
export type Ed25519KeyHashHex = OpaqueString<'Ed25519KeyHashHex'> & Hash28ByteBase16 & HexBlob;
export const Ed25519KeyHashHex = (value: string): Ed25519KeyHashHex => typedHex(value, 56);

/** 28 byte BIP32 public key hash as hex string */
export type Bip32PublicKeyHashHex = OpaqueString<'Bip32PublicKeyHashHex'> & HexBlob;
export const Bip32PublicKeyHashHex = (value: string): Bip32PublicKeyHashHex =>
  typedHex(value, BIP32_PUBLIC_KEY_HASH_LENGTH * 2);
