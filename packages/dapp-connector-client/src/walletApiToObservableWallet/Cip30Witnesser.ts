import {
  type AccountKeyDerivationPath,
  type SignBlobResult,
  type SignDataContext,
  type SignTransactionContext,
  type SignTransactionOptions,
  type WitnessedTx,
  type Witnesser,
  util // Review: this creates a dependency on 'key-management' package.
} from '@cardano-sdk/key-management';
import { Cip30WalletDependencyBase } from './Cip30WalletDependencyBase';
import { HexBlob } from '@cardano-sdk/util';
import { Serialization } from '@cardano-sdk/core';

export class Cip30Witnesser extends Cip30WalletDependencyBase implements Witnesser {
  async #stubOrCip30Witness(
    transaction: Serialization.Transaction,
    context: SignTransactionContext,
    options?: SignTransactionOptions | undefined
  ): Promise<Serialization.TransactionWitnessSet> {
    if (options?.stubSign) {
      const coreTxBody = transaction.body().toCore();
      const signatures = await util.stubSignTransaction({
        context,
        signTransactionOptions: options,
        txBody: coreTxBody
      });
      return Serialization.TransactionWitnessSet.fromCore({ signatures });
    }

    const witnessSetCbor = await this.api.signTx(transaction.toCbor());
    return Serialization.TransactionWitnessSet.fromCbor(HexBlob(witnessSetCbor));
  }

  async witness(
    transaction: Serialization.Transaction,
    context: SignTransactionContext,
    options?: SignTransactionOptions | undefined
  ): Promise<WitnessedTx> {
    const witnessSet = await this.#stubOrCip30Witness(transaction, context, options);
    const signedTx = new Serialization.Transaction(transaction.body(), witnessSet, transaction.auxiliaryData());
    return {
      cbor: signedTx.toCbor(),
      context: { handleResolutions: context.handleResolutions || [] },
      tx: signedTx.toCore()
    };
  }

  signBlob(
    _derivationPath: AccountKeyDerivationPath,
    _blob: HexBlob,
    _context: SignDataContext
  ): Promise<SignBlobResult> {
    throw new Error('TODO: Method not implemented.');
  }
}
