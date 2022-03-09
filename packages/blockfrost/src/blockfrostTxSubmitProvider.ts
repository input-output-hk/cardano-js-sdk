import { BlockFrostAPI } from '@blockfrost/blockfrost-js';
import { Cardano, TxSubmitProvider } from '@cardano-sdk/core';
import { Options } from '@blockfrost/blockfrost-js/lib/types';

/**
 * Connect to the [Blockfrost service](https://docs.blockfrost.io/)
 *
 * @param {Options} options BlockFrostAPI options
 * @returns {TxSubmitProvider} TxSubmitProvider
 * @throws {Cardano.TxSubmissionErrors.UnknownTxSubmissionError}
 */
export const blockfrostTxSubmitProvider = (options: Options): TxSubmitProvider => {
  const blockfrost = new BlockFrostAPI(options);

  const submitTx: TxSubmitProvider['submitTx'] = async (signedTransaction) => {
    try {
      await blockfrost.txSubmit(signedTransaction);
    } catch (error) {
      throw new Cardano.TxSubmissionErrors.UnknownTxSubmissionError(error);
    }
  };

  return {
    submitTx
  };
};
