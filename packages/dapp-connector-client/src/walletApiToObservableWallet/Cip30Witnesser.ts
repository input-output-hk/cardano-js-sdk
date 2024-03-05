import { Cardano, Serialization } from '@cardano-sdk/core';
import { Cip30WalletDependencyBase } from './Cip30WalletDependencyBase';
import { HexBlob } from '@cardano-sdk/util';
import type { AccountKeyDerivationPath, SignBlobResult, SignDataContext, Witnesser } from '@cardano-sdk/key-management';

export class Cip30Witnesser extends Cip30WalletDependencyBase implements Witnesser {
  async witness(transaction: Serialization.Transaction): Promise<Cardano.Witness> {
    const witnessSetCbor = await this.api.signTx(transaction.toCbor());
    return Serialization.TransactionWitnessSet.fromCbor(HexBlob(witnessSetCbor)).toCore();
  }
  signBlob(
    _derivationPath: AccountKeyDerivationPath,
    _blob: HexBlob,
    _context: SignDataContext
  ): Promise<SignBlobResult> {
    throw new Error('TODO: Method not implemented.');
  }
}
