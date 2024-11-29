import { BlockfrostClient, BlockfrostProvider } from '../blockfrost';
import { Logger } from 'ts-log';
import { SubmitTxArgs, TxSubmitProvider } from '@cardano-sdk/core';

export class BlockfrostTxSubmitProvider extends BlockfrostProvider implements TxSubmitProvider {
  constructor(client: BlockfrostClient, logger: Logger) {
    super(client, logger);
  }

  async submitTx({ signedTransaction }: SubmitTxArgs): Promise<void> {
    // @ todo handle context and resolutions
    await this.request<string>('tx/submit', {
      body: signedTransaction,
      headers: { 'Content-Type': 'application/cbor' },
      method: 'POST'
    });
  }
}
