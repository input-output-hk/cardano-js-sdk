import { AccountKeyDerivationPath, AsyncKeyAgent, SignBlobResult, WitnessOptions, Witnesser } from '../types';
import { Cardano } from '@cardano-sdk/core';
import { HexBlob } from '@cardano-sdk/util';

/** A witnesser that uses a {@link KeyAgent} to generate witness data for a transaction. */
export class Bip32Ed25519Witnesser implements Witnesser {
  #keyAgent: AsyncKeyAgent;

  constructor(keyAgent: AsyncKeyAgent) {
    this.#keyAgent = keyAgent;
  }

  async witness(txInternals: Cardano.TxBodyWithHash, options?: WitnessOptions): Promise<Cardano.Witness> {
    return { signatures: await this.#keyAgent.signTransaction(txInternals, options) };
  }

  async signBlob(derivationPath: AccountKeyDerivationPath, blob: HexBlob): Promise<SignBlobResult> {
    return this.#keyAgent.signBlob(derivationPath, blob);
  }
}

export const createBip32Ed25519Witnesser = (keyAgent: AsyncKeyAgent): Bip32Ed25519Witnesser =>
  new Bip32Ed25519Witnesser(keyAgent);
