import { Bip32PrivateKey, Bip32PublicKey } from '../Bip32/index.js';
import { Ed25519PrivateKey, Ed25519PublicKey, Ed25519Signature } from '../Ed25519e/index.js';
import type { BIP32Path } from '../types.js';
import type { Bip32Ed25519 } from '../Bip32Ed25519.js';
import type {
  Bip32PrivateKeyHex,
  Bip32PublicKeyHex,
  Ed25519KeyHashHex,
  Ed25519PrivateExtendedKeyHex,
  Ed25519PrivateNormalKeyHex,
  Ed25519PublicKeyHex,
  Ed25519SignatureHex
} from '../hexTypes.js';
import type { HexBlob } from '@cardano-sdk/util';

const EXTENDED_KEY_HEX_LENGTH = 128;

export class SodiumBip32Ed25519 implements Bip32Ed25519 {
  public async fromBip39Entropy(entropy: Buffer, passphrase: string): Promise<Bip32PrivateKeyHex> {
    return (await Bip32PrivateKey.fromBip39Entropy(entropy, passphrase)).hex();
  }

  public async getPublicKey(
    privateKey: Ed25519PrivateExtendedKeyHex | Ed25519PrivateNormalKeyHex
  ): Promise<Ed25519PublicKeyHex> {
    const key =
      privateKey.length === EXTENDED_KEY_HEX_LENGTH
        ? Ed25519PrivateKey.fromExtendedHex(privateKey)
        : Ed25519PrivateKey.fromNormalHex(privateKey);

    return (await key.toPublic()).hex();
  }

  public async getPubKeyHash(publicKey: Ed25519PublicKeyHex): Promise<Ed25519KeyHashHex> {
    const pubKey = await Ed25519PublicKey.fromHex(publicKey);

    return (await pubKey.hash()).hex();
  }

  public async getRawPrivateKey(bip32PrivateKey: Bip32PrivateKeyHex): Promise<Ed25519PrivateExtendedKeyHex> {
    return (await Bip32PrivateKey.fromHex(bip32PrivateKey)).toRawKey().hex();
  }

  public async getRawPublicKey(bip32PublicKey: Bip32PublicKeyHex): Promise<Ed25519PublicKeyHex> {
    const pubKey = await Bip32PublicKey.fromHex(bip32PublicKey);
    return (await pubKey.toRawKey()).hex();
  }

  public async getBip32PublicKey(privateKey: Bip32PrivateKeyHex): Promise<Bip32PublicKeyHex> {
    const privKey = await Bip32PrivateKey.fromHex(privateKey);
    return (await privKey.toPublic()).hex();
  }

  public async derivePrivateKey(
    parentKey: Bip32PrivateKeyHex,
    derivationIndices: BIP32Path
  ): Promise<Bip32PrivateKeyHex> {
    const privKey = await Bip32PrivateKey.fromHex(parentKey);
    return (await privKey.derive(derivationIndices)).hex();
  }

  public async derivePublicKey(parentKey: Bip32PublicKeyHex, derivationIndices: BIP32Path): Promise<Bip32PublicKeyHex> {
    const pubKey = await Bip32PublicKey.fromHex(parentKey);
    return (await pubKey.derive(derivationIndices)).hex();
  }

  public async sign(
    privateKey: Ed25519PrivateExtendedKeyHex | Ed25519PrivateNormalKeyHex,
    message: HexBlob
  ): Promise<Ed25519SignatureHex> {
    const key =
      privateKey.length === EXTENDED_KEY_HEX_LENGTH
        ? Ed25519PrivateKey.fromExtendedHex(privateKey)
        : Ed25519PrivateKey.fromNormalHex(privateKey);

    return (await key.sign(message)).hex();
  }

  public async verify(
    signature: Ed25519SignatureHex,
    message: HexBlob,
    publicKey: Ed25519PublicKeyHex
  ): Promise<boolean> {
    const key = await Ed25519PublicKey.fromHex(publicKey);

    return await key.verify(Ed25519Signature.fromHex(signature), message);
  }
}
