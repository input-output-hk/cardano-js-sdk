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

export class StubKeyAgent implements KeyAgent {
  readonly #knownAddresses: GroupedAddress[];

  constructor(groupedAddress: GroupedAddress) {
    this.#knownAddresses = [groupedAddress];
  }

  get knownAddresses(): GroupedAddress[] {
    return this.#knownAddresses;
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

  get extendedAccountPublicKey(): Cardano.Bip32PublicKey {
    throw new NotImplementedError('extendedAccountPublicKey');
  }

  deriveAddress(_derivationPath: AccountAddressDerivationPath): Promise<GroupedAddress> {
    throw new NotImplementedError('deriveAddress');
  }

  derivePublicKey(_derivationPath: AccountKeyDerivationPath): Promise<Cardano.Ed25519PublicKey> {
    throw new NotImplementedError('derivePublicKey');
  }

  signBlob(_derivationPath: AccountKeyDerivationPath, _blob: Cardano.util.HexBlob): Promise<SignBlobResult> {
    throw new NotImplementedError('signBlob');
  }

  signTransaction(
    _txInternals: Cardano.TxBodyWithHash,
    _options?: SignTransactionOptions | undefined
  ): Promise<Cardano.Signatures> {
    throw new NotImplementedError('signTransaction');
  }

  exportRootPrivateKey(): Promise<Cardano.Bip32PrivateKey> {
    throw new NotImplementedError('exportRootPrivateKey');
  }
}
