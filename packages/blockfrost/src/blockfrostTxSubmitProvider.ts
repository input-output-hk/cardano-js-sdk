import { BlockFrostAPI } from '@blockfrost/blockfrost-js';
import { Cardano, TxSubmitProvider } from '@cardano-sdk/core';
import { healthCheck } from './util';

/**
 * Connect to the [Blockfrost service](https://docs.blockfrost.io/)
 *
 * @param {BlockFrostAPI} blockfrost BlockFrostAPI instance
 * @returns {TxSubmitProvider} TxSubmitProvider
 * @throws {Cardano.TxSubmissionErrors.UnknownTxSubmissionError}
 */
export const blockfrostTxSubmitProvider = (blockfrost: BlockFrostAPI): TxSubmitProvider => {
  const submitTx: TxSubmitProvider['submitTx'] = async ({ signedTransaction }) => {
    try {
      await blockfrost.txSubmit(signedTransaction);
    } catch (error) {
      throw new Cardano.UnknownTxSubmissionError(error);
    }
  };

  return {
    healthCheck: healthCheck.bind(undefined, blockfrost),
    submitTx
  };
};
