import * as Crypto from '@cardano-sdk/crypto';
import {
  AccountAddressDerivationPath,
  AccountKeyDerivationPath,
  GroupedAddress,
  KeyAgent,
  SerializableKeyAgentData,
  SignBlobResult,
  SignTransactionOptions
} from '@cardano-sdk/key-management';
import { Cardano, NotImplementedError } from '@cardano-sdk/core';
import { HexBlob } from '@cardano-sdk/util';

export class StubKeyAgent implements KeyAgent {
  readonly #knownAddresses: GroupedAddress[];

  constructor(groupedAddress: GroupedAddress) {
    this.#knownAddresses = [groupedAddress];
  }

  get knownAddresses(): GroupedAddress[] {
    return this.#knownAddresses;
  }

  get bip32Ed25519(): Crypto.Bip32Ed25519 {
    throw new NotImplementedError('bip32Ed25519');
  }

  get chainId(): Cardano.ChainId {
    throw new NotImplementedError('chainId');
  }

  get accountIndex(): number {
    throw new NotImplementedError('accountIndex');
  }

  get serializableData(): SerializableKeyAgentData {
    throw new NotImplementedError('serializableData');
  }

  get extendedAccountPublicKey(): Crypto.Bip32PublicKeyHex {
    throw new NotImplementedError('extendedAccountPublicKey');
  }

  deriveAddress(_derivationPath: AccountAddressDerivationPath): Promise<GroupedAddress> {
    throw new NotImplementedError('deriveAddress');
  }

  derivePublicKey(_derivationPath: AccountKeyDerivationPath): Promise<Crypto.Ed25519PublicKeyHex> {
    throw new NotImplementedError('derivePublicKey');
  }

  signBlob(_derivationPath: AccountKeyDerivationPath, _blob: HexBlob): Promise<SignBlobResult> {
    throw new NotImplementedError('signBlob');
  }

  signTransaction(
    _txInternals: Cardano.TxBodyWithHash,
    _options?: SignTransactionOptions | undefined
  ): Promise<Cardano.Signatures> {
    throw new NotImplementedError('signTransaction');
  }

  exportRootPrivateKey(): Promise<Crypto.Bip32PrivateKeyHex> {
    throw new NotImplementedError('exportRootPrivateKey');
  }
}
