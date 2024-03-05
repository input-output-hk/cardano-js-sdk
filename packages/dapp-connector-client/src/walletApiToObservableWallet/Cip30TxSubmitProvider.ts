import { Cip30WalletDependencyBase } from './Cip30WalletDependencyBase';
import { HealthCheckResponse, SubmitTxArgs, TxSubmitProvider } from '@cardano-sdk/core';

export class Cip30TxSubmitProvider extends Cip30WalletDependencyBase implements TxSubmitProvider {
  async submitTx({ signedTransaction }: SubmitTxArgs): Promise<void> {
    await this.api.submitTx(signedTransaction);
  }
  async healthCheck(): Promise<HealthCheckResponse> {
    return { ok: true };
  }
}
