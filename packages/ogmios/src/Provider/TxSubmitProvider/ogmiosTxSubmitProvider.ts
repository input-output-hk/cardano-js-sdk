import { Cardano, ProviderError, ProviderFailure, TxSubmitProvider } from '@cardano-sdk/core';
import {
  ConnectionConfig,
  // eslint-disable-next-line @typescript-eslint/ban-ts-comment
  // @ts-ignore
  TxSubmission,
  createConnectionObject,
  createTxSubmissionClient,
  getServerHealth
} from '@cardano-ogmios/client';
import { Logger } from 'ts-log';
import { contextLogger } from '@cardano-sdk/util';
import { createInteractionContextWithLogger } from '../../util';

/**
 * Connect to an [Ogmios](https://ogmios.dev/) instance
 *
 * @param {ConnectionConfig} connectionConfig Ogmios connection configuration
 * @param {Logger} logger object implementing the Logger abstract class
 * @returns {TxSubmitProvider} TxSubmitProvider
 * @throws {TxSubmission.errors}
 */
export const ogmiosTxSubmitProvider = (connectionConfig: ConnectionConfig, logger: Logger): TxSubmitProvider => ({
  async healthCheck() {
    try {
      const { networkSynchronization, lastKnownTip } = await getServerHealth({
        connection: createConnectionObject(connectionConfig)
      });
      return {
        localNode: {
          ledgerTip: lastKnownTip,
          networkSync: networkSynchronization
        },
        ok: networkSynchronization > 0.99
      };
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
    } catch (error: any) {
      if (error.name === 'FetchError') {
        return { ok: false };
      }
      throw new ProviderError(ProviderFailure.Unknown, error);
    }
  },
  submitTx: async ({ signedTransaction }) => {
    // The Ogmios client supports opening a long-running ws connection,
    // however as the provider interface doesn't include shutdown handling,
    // we're using the one time interaction type for now.
    try {
      const txSubmissionClient = await createTxSubmissionClient(
        await createInteractionContextWithLogger(contextLogger(logger, 'ogmiosTxSubmitProvider'), {
          connection: connectionConfig,
          interactionType: 'OneTime'
        })
      );
      await txSubmissionClient.submitTx(signedTransaction);
    } catch (error) {
      throw Cardano.util.asTxSubmissionError(error) || new Cardano.UnknownTxSubmissionError(error);
    }
  }
});
