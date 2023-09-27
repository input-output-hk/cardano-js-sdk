import * as Crypto from '@cardano-sdk/crypto';
import {
  AccountKeyDerivationPath,
  AsyncKeyAgent,
  GroupedAddress,
  SignBlobResult,
  util
} from '@cardano-sdk/key-management';
import { BehaviorSubject, firstValueFrom } from 'rxjs';
import { Cardano } from '@cardano-sdk/core';
import { generateRandomHexString } from './dataGeneration';

const NOT_IMPLEMENTED = 'Method not implemented';

export class StubKeyAgent implements AsyncKeyAgent {
  static readonly dRepPubKey = Crypto.Ed25519PublicKeyHex(
    '0b1c96fad4179d7910bd9485ac28c4c11368c83d18d01b29d4cf84d8ff6a06c4'
  );

  knownAddresses$ = new BehaviorSubject<GroupedAddress[]>([]);

  constructor(private inputResolver: Cardano.InputResolver) {}

  deriveAddress(): Promise<GroupedAddress> {
    throw new Error(NOT_IMPLEMENTED);
  }
  derivePublicKey(derivationPath: AccountKeyDerivationPath): Promise<Crypto.Ed25519PublicKeyHex> {
    if (derivationPath.role === util.DREP_KEY_DERIVATION_PATH.role) {
      return Promise.resolve(StubKeyAgent.dRepPubKey);
    }
    throw new Error(NOT_IMPLEMENTED);
  }
  signBlob(): Promise<SignBlobResult> {
    throw new Error(NOT_IMPLEMENTED);
  }
  async signTransaction(txInternals: Cardano.TxBodyWithHash): Promise<Cardano.Signatures> {
    const signatures = new Map<Crypto.Ed25519PublicKeyHex, Crypto.Ed25519SignatureHex>();
    const knownAddresses = await firstValueFrom(this.knownAddresses$);
    for (const _ of await util.ownSignatureKeyPaths(
      txInternals.body,
      knownAddresses,
      this.inputResolver,
      Crypto.Ed25519KeyHashHex('f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80')
    )) {
      signatures.set(
        Crypto.Ed25519PublicKeyHex(generateRandomHexString(64)),
        Crypto.Ed25519SignatureHex(generateRandomHexString(128))
      );
    }
    return signatures;
  }
  getChainId(): Promise<Cardano.ChainId> {
    throw new Error(NOT_IMPLEMENTED);
  }
  getBip32Ed25519(): Promise<Crypto.Bip32Ed25519> {
    throw new Error(NOT_IMPLEMENTED);
  }
  getExtendedAccountPublicKey(): Promise<Crypto.Bip32PublicKeyHex> {
    throw new Error(NOT_IMPLEMENTED);
  }
  async setKnownAddresses(addresses: GroupedAddress[]): Promise<void> {
    this.knownAddresses$.next(addresses);
  }
  shutdown(): void {
    throw new Error(NOT_IMPLEMENTED);
  }
}
