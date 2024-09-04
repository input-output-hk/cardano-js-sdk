import {
  AsyncKeyAgent,
  SignTransactionContext,
  SignTransactionOptions,
  WitnessOptions,
  WitnessedTx,
  Witnesser
} from '../types';
import { Cip30DataSignature } from '@cardano-sdk/dapp-connector';
import { Cip30SignDataRequest } from '../cip8';
import { Serialization } from '@cardano-sdk/core';
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
        : await Bip32Ed25519Witnesser.getSignatures(this.#keyAgent, tx.body(), context, options);

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
      cbor: Serialization.TxCBOR.serialize(transaction),
      context: {
        handleResolutions: context.handleResolutions ?? []
      },
      tx: transaction
    };
  }

  async signData(props: Cip30SignDataRequest): Promise<Cip30DataSignature> {
    return this.#keyAgent.signCip8Data(props);
  }

  static async getSignatures(
    keyAgent: AsyncKeyAgent,
    txBody: Serialization.TransactionBody,
    context: SignTransactionContext,
    options?: SignTransactionOptions
  ) {
    const signatures = await keyAgent.signTransaction(txBody, context, options);

    if (options?.extraSigners) {
      for (const extraSigner of options?.extraSigners) {
        const extraSignature = await extraSigner.sign(txBody);
        signatures.set(extraSignature.pubKey, extraSignature.signature);
      }
    }
    return signatures;
  }
}

export const createBip32Ed25519Witnesser = (keyAgent: AsyncKeyAgent): Bip32Ed25519Witnesser =>
  new Bip32Ed25519Witnesser(keyAgent);
