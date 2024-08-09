import { BlockfrostProvider } from '../../util/BlockfrostProvider/BlockfrostProvider';
import { SubmitTxArgs, TxSubmitProvider } from '@cardano-sdk/core';
import { blockfrostToProviderError } from '../../util';

export class BlockfrostTxSubmitProvider extends BlockfrostProvider implements TxSubmitProvider {
  async submitTx({ signedTransaction }: SubmitTxArgs): Promise<void> {
    // @ todo handle context and resolutions
    try {
      await this.blockfrost.txSubmit(signedTransaction);
    } catch (error) {
      throw blockfrostToProviderError(error);
    }
  }
}
