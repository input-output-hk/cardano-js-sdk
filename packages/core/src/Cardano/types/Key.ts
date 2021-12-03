import { Hash32ByteBase16, OpaqueString, typedHex } from '../util';

/**
 * BIP32 public key as hex string
 */
export type Bip32PublicKey = OpaqueString<'Bip32PublicKey'>;
export const Bip32PublicKey = (key: string): Bip32PublicKey => typedHex(key, 128);

/**
 * BIP32 private key as hex string
 */
export type Bip32PrivateKey = OpaqueString<'Bip32PrivateKey'>;
export const Bip32PrivateKey = (key: string): Bip32PrivateKey => typedHex(key, 192);

/**
 * Ed25519 public key as hex string
 */
export type Ed25519PublicKey = OpaqueString<'Ed25519PublicKey'>;

/**
 * @param {string} value Ed25519 public key as hex string
 * @throws InvalidStringError
 */
export const Ed25519PublicKey = (value: string): Ed25519PublicKey => typedHex(value, 64);

/**
 * 32 byte ED25519 key hash as hex string
 */
export type Ed25519KeyHash = OpaqueString<'Ed25519KeyHash'>;
export const Ed25519KeyHash = (value: string): Ed25519KeyHash => Hash32ByteBase16(value);
