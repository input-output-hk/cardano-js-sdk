import * as Crypto from '@cardano-sdk/crypto';
import { AsyncKeyAgent, GroupedAddress, SignBlobResult, util } from '@cardano-sdk/key-management';
import { BehaviorSubject, firstValueFrom } from 'rxjs';
import { Cardano } from '@cardano-sdk/core';
import { generateRandomHexString } from './dataGeneration';

const NOT_IMPLEMENTED = 'Method not implemented';

export class StubKeyAgent implements AsyncKeyAgent {
  knownAddresses$ = new BehaviorSubject<GroupedAddress[]>([]);

  constructor(private inputResolver: Cardano.InputResolver) {}

  deriveAddress(): Promise<GroupedAddress> {
    throw new Error(NOT_IMPLEMENTED);
  }
  derivePublicKey(): Promise<Crypto.Ed25519PublicKeyHex> {
    throw new Error(NOT_IMPLEMENTED);
  }
  signBlob(): Promise<SignBlobResult> {
    throw new Error(NOT_IMPLEMENTED);
  }
  async signTransaction(txInternals: Cardano.TxBodyWithHash): Promise<Cardano.Signatures> {
    const signatures = new Map<Crypto.Ed25519PublicKeyHex, Crypto.Ed25519SignatureHex>();
    const knownAddresses = await firstValueFrom(this.knownAddresses$);
    for (const _ of await util.ownSignatureKeyPaths(txInternals.body, knownAddresses, this.inputResolver)) {
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
