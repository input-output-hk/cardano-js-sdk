import { BlockFrostAPI } from '@blockfrost/blockfrost-js';
import { Cardano, ProviderError, ProviderFailure, TxSubmitProvider } from '@cardano-sdk/core';

/**
 * Connect to the [Blockfrost service](https://docs.blockfrost.io/)
 *
 * @param {BlockFrostAPI} blockfrost BlockFrostAPI instance
 * @returns {TxSubmitProvider} TxSubmitProvider
 * @throws {Cardano.TxSubmissionErrors.UnknownTxSubmissionError}
 */
export const blockfrostTxSubmitProvider = (blockfrost: BlockFrostAPI): TxSubmitProvider => {
  const healthCheck: TxSubmitProvider['healthCheck'] = async () => {
    try {
      const result = await blockfrost.health();
      return { ok: result.is_healthy };
    } catch (error) {
      throw new ProviderError(ProviderFailure.Unknown, error);
    }
  };

  const submitTx: TxSubmitProvider['submitTx'] = async (signedTransaction) => {
    try {
      await blockfrost.txSubmit(signedTransaction);
    } catch (error) {
      throw new Cardano.TxSubmissionErrors.UnknownTxSubmissionError(error);
    }
  };

  return {
    healthCheck,
    submitTx
  };
};
