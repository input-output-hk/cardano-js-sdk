import { BIP32Path } from '../types';
import { Bip32Ed25519 } from '../Bip32Ed25519';
import {
  Bip32PrivateKeyHex,
  Bip32PublicKeyHex,
  Ed25519KeyHashHex,
  Ed25519PrivateExtendedKeyHex,
  Ed25519PrivateNormalKeyHex,
  Ed25519PublicKeyHex,
  Ed25519SignatureHex
} from '../hexTypes';
import { CardanoMultiplatformLib } from './CML';
import { HexBlob, usingAutoFree } from '@cardano-sdk/util';

const EXTENDED_KEY_HEX_LENGTH = 128;

export class CmlBip32Ed25519 implements Bip32Ed25519 {
  #CML: CardanoMultiplatformLib;

  constructor(CML: CardanoMultiplatformLib) {
    this.#CML = CML;
  }

  public fromBip39Entropy(entropy: Buffer, passphrase: string): Bip32PrivateKeyHex {
    const hexKey = usingAutoFree((scope) => {
      const cmlKey = scope.manage(this.#CML.Bip32PrivateKey.from_bip39_entropy(entropy, Buffer.from(passphrase)));
      return cmlKey.as_bytes();
    });

    return Bip32PrivateKeyHex(Buffer.from(hexKey).toString('hex'));
  }

  public getPublicKey(
    privateKey: Ed25519PrivateExtendedKeyHex | Ed25519PrivateNormalKeyHex
  ): Promise<Ed25519PublicKeyHex> {
    return usingAutoFree((scope) => {
      const cmlPrivateKey =
        privateKey.length === EXTENDED_KEY_HEX_LENGTH
          ? scope.manage(this.#CML.PrivateKey.from_extended_bytes(Buffer.from(privateKey, 'hex')))
          : scope.manage(this.#CML.PrivateKey.from_normal_bytes(Buffer.from(privateKey, 'hex')));

      const pubKeyBytes = scope.manage(cmlPrivateKey.to_public()).as_bytes();

      return Promise.resolve(Ed25519PublicKeyHex(Buffer.from(pubKeyBytes).toString('hex')));
    });
  }

  public getPubKeyHash(publicKey: Ed25519PublicKeyHex): Promise<Ed25519KeyHashHex> {
    return usingAutoFree((scope) => {
      const cmlPubKey = scope.manage(this.#CML.PublicKey.from_bytes(Buffer.from(publicKey, 'hex')));
      const keyHash = scope.manage(cmlPubKey.hash()).to_bytes();

      return Promise.resolve(Ed25519KeyHashHex(Buffer.from(keyHash).toString('hex')));
    });
  }

  public getRawPrivateKey(bip32PrivateKey: Bip32PrivateKeyHex): Promise<Ed25519PrivateExtendedKeyHex> {
    return usingAutoFree((scope) => {
      const cmlPrivateKey = scope.manage(this.#CML.Bip32PrivateKey.from_bytes(Buffer.from(bip32PrivateKey, 'hex')));
      const bytes = scope.manage(cmlPrivateKey.to_raw_key()).as_bytes();
      return Promise.resolve(Ed25519PrivateExtendedKeyHex(Buffer.from(bytes).toString('hex')));
    });
  }

  public getRawPublicKey(bip32PublicKey: Bip32PublicKeyHex): Promise<Ed25519PublicKeyHex> {
    return usingAutoFree((scope) => {
      const cmlPublicKey = scope.manage(this.#CML.Bip32PublicKey.from_bytes(Buffer.from(bip32PublicKey, 'hex')));
      const bytes = scope.manage(cmlPublicKey.to_raw_key()).as_bytes();
      return Promise.resolve(Ed25519PublicKeyHex(Buffer.from(bytes).toString('hex')));
    });
  }

  public getBip32PublicKey(privateKey: Bip32PrivateKeyHex): Promise<Bip32PublicKeyHex> {
    return usingAutoFree((scope) => {
      const cmlPrivateKey = scope.manage(this.#CML.Bip32PrivateKey.from_bytes(Buffer.from(privateKey, 'hex')));
      const pubKeyBytes = scope.manage(cmlPrivateKey.to_public()).as_bytes();
      return Promise.resolve(Bip32PublicKeyHex(Buffer.from(pubKeyBytes).toString('hex')));
    });
  }

  public derivePrivateKey(parentKey: Bip32PrivateKeyHex, derivationIndices: BIP32Path): Promise<Bip32PrivateKeyHex> {
    return usingAutoFree((scope) => {
      let cmlKey = scope.manage(this.#CML.Bip32PrivateKey.from_bytes(Buffer.from(parentKey, 'hex')));

      for (const index of derivationIndices) {
        cmlKey = scope.manage(cmlKey.derive(index));
      }

      return Promise.resolve(Bip32PrivateKeyHex(Buffer.from(cmlKey.as_bytes()).toString('hex')));
    });
  }

  public derivePublicKey(parentKey: Bip32PublicKeyHex, derivationIndices: BIP32Path): Promise<Bip32PublicKeyHex> {
    return usingAutoFree((scope) => {
      let cmlKey = scope.manage(this.#CML.Bip32PublicKey.from_bytes(Buffer.from(parentKey, 'hex')));

      for (const index of derivationIndices) {
        cmlKey = scope.manage(cmlKey.derive(index));
      }

      return Promise.resolve(Bip32PublicKeyHex(Buffer.from(cmlKey.as_bytes()).toString('hex')));
    });
  }

  public async sign(
    privateKey: Ed25519PrivateExtendedKeyHex | Ed25519PrivateNormalKeyHex,
    message: HexBlob
  ): Promise<Ed25519SignatureHex> {
    return usingAutoFree((scope) => {
      const cmlPrivateKey =
        privateKey.length === EXTENDED_KEY_HEX_LENGTH
          ? scope.manage(this.#CML.PrivateKey.from_extended_bytes(Buffer.from(privateKey, 'hex')))
          : scope.manage(this.#CML.PrivateKey.from_normal_bytes(Buffer.from(privateKey, 'hex')));
      const signature = scope.manage(cmlPrivateKey.sign(Buffer.from(message, 'hex'))).to_bytes();
      return Promise.resolve(Ed25519SignatureHex(Buffer.from(signature).toString('hex')));
    });
  }

  public async verify(
    signature: Ed25519SignatureHex,
    message: HexBlob,
    publicKey: Ed25519PublicKeyHex
  ): Promise<boolean> {
    return usingAutoFree((scope) => {
      const cmlKey = scope.manage(this.#CML.PublicKey.from_bytes(Buffer.from(publicKey, 'hex')));
      const cmlSignature = scope.manage(this.#CML.Ed25519Signature.from_bytes(Buffer.from(signature, 'hex')));
      return Promise.resolve(cmlKey.verify(Buffer.from(message, 'hex'), cmlSignature));
    });
  }
}
