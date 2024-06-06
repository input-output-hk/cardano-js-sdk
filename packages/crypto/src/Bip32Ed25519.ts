import type { BIP32Path } from './types.js';
import type {
  Bip32PrivateKeyHex,
  Bip32PublicKeyHex,
  Ed25519KeyHashHex,
  Ed25519PrivateExtendedKeyHex,
  Ed25519PrivateNormalKeyHex,
  Ed25519PublicKeyHex,
  Ed25519SignatureHex
} from './hexTypes.js';
import type { HexBlob } from '@cardano-sdk/util';

/**
 * Ed25519 is the EdDSA signature scheme used in Cardano, it uses SHA-512 (SHA-2) as its hashing algorithm
 * and Curve25519 curve parameters.
 *
 * This class Provides a set of high level primitives to perform Ed25519 signature generation/verification,
 * import private keys from BIP39 mnemonics and derive BIP32-Ed25519 extended signing keys.
 */
export interface Bip32Ed25519 {
  /**
   * Turns an initial entropy into a secure cryptographic master key.
   *
   * The resulting extended Ed25519 secret key composed if of:
   *   - 32 bytes: Ed25519 curve scalar from which few bits have been tweaked according to ED25519-BIP32
   *   - 32 bytes: Ed25519 binary blob used as IV for signing
   *
   * @param entropy Random stream of bytes generated from a BIP39 seed phrase.
   * @param passphrase The second factor authentication passphrase for the mnemonic phrase.
   * @returns The secret extended key.
   */
  fromBip39Entropy(entropy: Buffer, passphrase: string): Promise<Bip32PrivateKeyHex>;

  /**
   * The function computes a public key from the provided private key.
   *
   * @param privateKey The private key to generate the public key from.
   * @returns The matching public key.
   */
  getPublicKey(privateKey: Ed25519PrivateExtendedKeyHex | Ed25519PrivateNormalKeyHex): Promise<Ed25519PublicKeyHex>;

  /**
   * Computes the hash of the given public key.
   *
   * @param publicKey The public key to compute the hash from.
   * @returns The public key hash.
   */
  getPubKeyHash(publicKey: Ed25519PublicKeyHex): Promise<Ed25519KeyHashHex>;

  /** Gets the Ed25519 raw private key. This key can be used for cryptographically signing messages. */
  getRawPrivateKey(bip32PrivateKey: Bip32PrivateKeyHex): Promise<Ed25519PrivateExtendedKeyHex>;

  /**
   * Gets the Ed25519 raw public key. This key can be used for cryptographically verifying messages
   * previously signed with the matching Ed25519 raw private key.
   */
  getRawPublicKey(bip32PublicKey: Bip32PublicKeyHex): Promise<Ed25519PublicKeyHex>;

  /**
   * The function computes the BIP-32 public key from the provided BIP-32 private key.
   *
   * @param privateKey The extended private key to generate the public key from.
   * @returns The extended public key.
   */
  getBip32PublicKey(privateKey: Bip32PrivateKeyHex): Promise<Bip32PublicKeyHex>;

  /**
   * Given a parent extended key and a set of indices, this function computes the corresponding child extended key.
   *
   * @param parentKey The parent extended key.
   * @param derivationIndices The list of derivation indices.
   * @returns The child extended private key.
   */
  derivePrivateKey(parentKey: Bip32PrivateKeyHex, derivationIndices: BIP32Path): Promise<Bip32PrivateKeyHex>;

  /**
   * Given a parent extended key and a set of indices, this function computes the corresponding child extended key.
   *
   * @param parentKey The parent extended key.
   * @param derivationIndices The list of derivation indices.
   * @returns The child extended public key.
   */
  derivePublicKey(parentKey: Bip32PublicKeyHex, derivationIndices: BIP32Path): Promise<Bip32PublicKeyHex>;

  /**
   * Generates an Ed25519 signature using an extended private key.
   *
   * @param privateKey The extended private key to generate the signature with.
   * @param message The message to be signed.
   * @returns The Ed25519 digital signature.
   */
  sign(
    privateKey: Ed25519PrivateExtendedKeyHex | Ed25519PrivateNormalKeyHex,
    message: HexBlob
  ): Promise<Ed25519SignatureHex>;

  /**
   * Verifies that the passed-in signature was generated with a extended private key that matches
   * the given extended public key.
   *
   * @param signature The signature bytes to be verified.
   * @param message The original message the signature was computed from.
   * @param publicKey The Ed25519 public key that validates the given signature.
   * @returns true if the signature is valid; otherwise; false.
   */
  verify(signature: Ed25519SignatureHex, message: HexBlob, publicKey: Ed25519PublicKeyHex): Promise<boolean>;
}
