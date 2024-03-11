import {
  AccountKeyDerivationPath,
  AsyncKeyAgent,
  SignBlobResult,
  SignDataContext,
  SignTransactionContext,
  SignTransactionOptions,
  WitnessOptions,
  WitnessedTx,
  Witnesser
} from '../types';
import { Cardano, Serialization, TxCBOR } from '@cardano-sdk/core';
import { HexBlob } from '@cardano-sdk/util';
import { stubSignTransaction } from './stubSignTransaction';

/** A witnesser that uses a {@link KeyAgent} to generate witness data for a transaction. */
export class Bip32Ed25519Witnesser implements Witnesser {
  #keyAgent: AsyncKeyAgent;

  constructor(keyAgent: AsyncKeyAgent) {
    this.#keyAgent = keyAgent;
  }

  async witness(
    tx: Serialization.Transaction,
    context: SignTransactionContext,
    options?: WitnessOptions
  ): Promise<WitnessedTx> {
    const coreTx = tx.toCore();
    const hash = tx.getId();
    const signatures =
      options?.stubSign !== undefined && options.stubSign
        ? await stubSignTransaction({
            context,
            signTransactionOptions: options,
            txBody: coreTx.body
          })
        : await Bip32Ed25519Witnesser.getSignatures(this.#keyAgent, { body: coreTx.body, hash }, context, options);

    const transaction = {
      auxiliaryData: coreTx.auxiliaryData,
      body: coreTx.body,
      id: hash,
      isValid: tx.isValid(),
      witness: {
        ...coreTx.witness,
        signatures: new Map([...signatures.entries(), ...(coreTx.witness?.signatures?.entries() || [])])
      }
    };

    return {
      cbor: TxCBOR.serialize(transaction),
      context: {
        handleResolutions: context.handleResolutions ?? []
      },
      tx: transaction
    };
  }

  async signBlob(
    derivationPath: AccountKeyDerivationPath,
    blob: HexBlob,
    _context: SignDataContext
  ): Promise<SignBlobResult> {
    return this.#keyAgent.signBlob(derivationPath, blob);
  }

  static async getSignatures(
    keyAgent: AsyncKeyAgent,
    txInternals: Cardano.TxBodyWithHash,
    context: SignTransactionContext,
    options?: SignTransactionOptions
  ) {
    const signatures = await keyAgent.signTransaction(
      {
        body: txInternals.body,
        hash: txInternals.hash
      },
      context,
      options
    );

    if (options?.extraSigners) {
      for (const extraSigner of options?.extraSigners) {
        const extraSignature = await extraSigner.sign(txInternals);
        signatures.set(extraSignature.pubKey, extraSignature.signature);
      }
    }
    return signatures;
  }
}

export const createBip32Ed25519Witnesser = (keyAgent: AsyncKeyAgent): Bip32Ed25519Witnesser =>
  new Bip32Ed25519Witnesser(keyAgent);
