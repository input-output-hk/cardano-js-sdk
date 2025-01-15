import { BIP32Path } from '../types';
import { Bip32Ed25519 } from '../Bip32Ed25519';
import { Bip32PrivateKey, Bip32PublicKey } from '../Bip32';
import {
  Bip32PrivateKeyHex,
  Bip32PublicKeyHex,
  Ed25519KeyHashHex,
  Ed25519PrivateExtendedKeyHex,
  Ed25519PrivateNormalKeyHex,
  Ed25519PublicKeyHex,
  Ed25519SignatureHex
} from '../hexTypes';
import { Ed25519PrivateKey, Ed25519PublicKey, Ed25519Signature } from '../Ed25519e';
import { HexBlob } from '@cardano-sdk/util';
import sodium from 'libsodium-wrappers-sumo';

const EXTENDED_KEY_HEX_LENGTH = 128;

export class SodiumBip32Ed25519 implements Bip32Ed25519 {
  // Prevent instantiation
  private constructor() {
    // Empty
  }

  public static async create(): Promise<SodiumBip32Ed25519> {
    await sodium.ready;
    return Promise.resolve(new SodiumBip32Ed25519());
  }

  public fromBip39Entropy(entropy: Buffer, passphrase: string): Bip32PrivateKeyHex {
    return Bip32PrivateKey.fromBip39Entropy(entropy, passphrase).hex();
  }

  public getPublicKey(privateKey: Ed25519PrivateExtendedKeyHex | Ed25519PrivateNormalKeyHex): Ed25519PublicKeyHex {
    const key =
      privateKey.length === EXTENDED_KEY_HEX_LENGTH
        ? Ed25519PrivateKey.fromExtendedHex(privateKey)
        : Ed25519PrivateKey.fromNormalHex(privateKey);

    return key.toPublic().hex();
  }

  public getPubKeyHash(publicKey: Ed25519PublicKeyHex): Ed25519KeyHashHex {
    const pubKey = Ed25519PublicKey.fromHex(publicKey);

    return pubKey.hash().hex();
  }

  public getRawPrivateKey(bip32PrivateKey: Bip32PrivateKeyHex): Ed25519PrivateExtendedKeyHex {
    return Bip32PrivateKey.fromHex(bip32PrivateKey).toRawKey().hex();
  }

  public getRawPublicKey(bip32PublicKey: Bip32PublicKeyHex): Ed25519PublicKeyHex {
    const pubKey = Bip32PublicKey.fromHex(bip32PublicKey);
    return pubKey.toRawKey().hex();
  }

  public getBip32PublicKey(privateKey: Bip32PrivateKeyHex): Bip32PublicKeyHex {
    const privKey = Bip32PrivateKey.fromHex(privateKey);
    return privKey.toPublic().hex();
  }

  public derivePrivateKey(parentKey: Bip32PrivateKeyHex, derivationIndices: BIP32Path): Bip32PrivateKeyHex {
    const privKey = Bip32PrivateKey.fromHex(parentKey);
    return privKey.derive(derivationIndices).hex();
  }

  public derivePublicKey(parentKey: Bip32PublicKeyHex, derivationIndices: BIP32Path): Bip32PublicKeyHex {
    const pubKey = Bip32PublicKey.fromHex(parentKey);
    return pubKey.derive(derivationIndices).hex();
  }

  public sign(
    privateKey: Ed25519PrivateExtendedKeyHex | Ed25519PrivateNormalKeyHex,
    message: HexBlob
  ): Ed25519SignatureHex {
    const key =
      privateKey.length === EXTENDED_KEY_HEX_LENGTH
        ? Ed25519PrivateKey.fromExtendedHex(privateKey)
        : Ed25519PrivateKey.fromNormalHex(privateKey);

    return key.sign(message).hex();
  }

  public verify(signature: Ed25519SignatureHex, message: HexBlob, publicKey: Ed25519PublicKeyHex): boolean {
    const key = Ed25519PublicKey.fromHex(publicKey);

    return key.verify(Ed25519Signature.fromHex(signature), message);
  }
}
