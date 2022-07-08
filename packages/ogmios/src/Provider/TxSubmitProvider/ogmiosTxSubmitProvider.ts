import { Buffer } from 'buffer';
import { Cardano, ProviderError, ProviderFailure, TxSubmitProvider } from '@cardano-sdk/core';
import {
  ConnectionConfig,
  // eslint-disable-next-line @typescript-eslint/ban-ts-comment
  // @ts-ignore
  TxSubmission,
  createConnectionObject,
  createInteractionContext,
  createTxSubmissionClient,
  getServerHealth
} from '@cardano-ogmios/client';
import { Logger, dummyLogger } from 'ts-log';

/**
 * Connect to an [Ogmios](https://ogmios.dev/) instance
 *
 * @param {ConnectionConfig} connectionConfig Ogmios connection configuration
 * @param {Logger} logger object implementing the Logger abstract class
 * @returns {TxSubmitProvider} TxSubmitProvider
 * @throws {TxSubmission.errors}
 */
export const ogmiosTxSubmitProvider = (
  connectionConfig: ConnectionConfig,
  logger: Logger = dummyLogger
): TxSubmitProvider => ({
  async healthCheck() {
    try {
      const serverHealth = await getServerHealth({ connection: createConnectionObject(connectionConfig) });
      return { ok: serverHealth.networkSynchronization > 0.99 };
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
    } catch (error: any) {
      if (error.name === 'FetchError') {
        return { ok: false };
      }
      throw new ProviderError(ProviderFailure.Unknown, error);
    }
  },
  submitTx: async (signedTransaction) => {
    // The Ogmios client supports opening a long-running ws connection,
    // however as the provider interface doesn't include shutdown handling,
    // we're using the one time interaction type for now.
    try {
      const interactionContext = await createInteractionContext(
        (error) => {
          logger.error({ error: error.name, module: 'ogmiosTxSubmitProvider' }, error.message);
        },
        logger.info,
        {
          connection: connectionConfig,
          interactionType: 'OneTime'
        }
      );
      const txSubmissionClient = await createTxSubmissionClient(interactionContext);
      const txHex = Buffer.from(signedTransaction).toString('hex');
      await txSubmissionClient.submitTx(txHex);
    } catch (error) {
      throw Cardano.util.asTxSubmissionError(error) || new Cardano.UnknownTxSubmissionError(error);
    }
  }
});
