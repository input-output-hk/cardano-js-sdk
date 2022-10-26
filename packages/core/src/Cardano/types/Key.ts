import { CML } from '../../CML/CML';
import { Hash28ByteBase16, HexBlob, OpaqueString, castHexBlob, typedHex } from '../util/primitives';
import { RewardAccount } from './RewardAccount';
import { usingAutoFree } from '@cardano-sdk/util';

/**
 * BIP32 public key as hex string
 */
export type Bip32PublicKey = OpaqueString<'Bip32PublicKey'>;
export const Bip32PublicKey = (key: string): Bip32PublicKey => typedHex(key, 128);
Bip32PublicKey.fromHexBlob = (value: HexBlob) => castHexBlob<Bip32PublicKey>(value, 128);

/**
 * BIP32 private key as hex string
 */
export type Bip32PrivateKey = OpaqueString<'Bip32PrivateKey'>;
export const Bip32PrivateKey = (key: string): Bip32PrivateKey => typedHex(key, 192);
Bip32PrivateKey.fromHexBlob = (value: HexBlob) => castHexBlob<Bip32PrivateKey>(value, 192);

/**
 * Ed25519 public key as hex string
 */
export type Ed25519PublicKey = OpaqueString<'Ed25519PublicKey'>;

/**
 * @param {string} value Ed25519 public key as hex string
 * @throws InvalidStringError
 */
export const Ed25519PublicKey = (value: string): Ed25519PublicKey => typedHex(value, 64);
Ed25519PublicKey.fromHexBlob = (value: HexBlob) => castHexBlob<Ed25519PublicKey>(value, 64);

/**
 * Ed25519 private key as hex string
 */
export type Ed25519PrivateKey = OpaqueString<'Ed25519PrivateKey'>;

/**
 * @param {string} value Ed25519 private key as hex string
 * @throws InvalidStringError
 */
export const Ed25519PrivateKey = (value: string): Ed25519PrivateKey => typedHex(value, 128);
Ed25519PrivateKey.fromHexBlob = (value: HexBlob) => castHexBlob<Ed25519PrivateKey>(value, 128);

/**
 * 28 byte ED25519 key hash as hex string
 */
export type Ed25519KeyHash = OpaqueString<'Ed25519KeyHash'>;
export const Ed25519KeyHash = (value: string): Ed25519KeyHash => Hash28ByteBase16(value);
Ed25519KeyHash.fromRewardAccount = (rewardAccount: RewardAccount): Ed25519KeyHash =>
  usingAutoFree((scope) => {
    const bech32 = scope.manage(CML.Address.from_bech32(rewardAccount.toString()));
    const rewardAddress = scope.manage(CML.RewardAddress.from_address(bech32)!);
    const paymentCred = scope.manage(rewardAddress.payment_cred()!);
    const keyHash = scope.manage(paymentCred.to_keyhash()!);

    return Ed25519KeyHash(Buffer.from(keyHash.to_bytes()).toString('hex'));
  });

Ed25519KeyHash.fromKey = (pubKey: Ed25519PublicKey): Ed25519KeyHash =>
  usingAutoFree((scope) => {
    const cmlPubKey = scope.manage(CML.PublicKey.from_bytes(Buffer.from(pubKey, 'hex')));
    const keyHash = scope.manage(cmlPubKey.hash()).to_bytes();

    return Ed25519KeyHash(Buffer.from(keyHash!).toString('hex'));
  });
