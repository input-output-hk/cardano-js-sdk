import { ConnectionConfig, InteractionContext, createInteractionContext } from '@cardano-ogmios/client';
import { GeneralCardanoNodeError, GeneralCardanoNodeErrorCode } from '@cardano-sdk/core';
import { Observable, switchMap } from 'rxjs';
import { RetryBackoffConfig, retryBackoff } from 'backoff-rxjs';
import { WithLogger, contextLogger } from '@cardano-sdk/util';
import { ogmiosToCoreError } from '../queries';

export type ReconnectionConfig = Omit<RetryBackoffConfig, 'shouldRetry'>;

const defaultReconnectionConfig: ReconnectionConfig = { initialInterval: 10, maxInterval: 5000 };

export interface InteractionContextProps {
  /**
   * Subscribed when making an initial connection and
   * re-subscribed before reconnecting on connection errors.
   *
   * Emitting new value from this observable will
   * close an existing connection and open a new one.
   */
  connectionConfig$: Observable<ConnectionConfig>;
  /** Retry backoff configuration for re-subscribing to connectionConfig$ on connection error. */
  reconnectionConfig?: ReconnectionConfig;
}

/**
 * Creates an Ogmios InteractionContext upon subscription.
 * Closes the connection when unsubscribed.
 * Reconnects and emits a new InteractionContext upon connection errors.
 *
 * @throws errors with UnknownCardanoNodeError on any non-connection
 * InteractionContext error thrown by Ogmios.
 * @throws errors with CardanoNodeErrors.ConnectionError when `reconnectionConfig.maxAttempts` is reached.
 */
export const createObservableInteractionContext = (
  { connectionConfig$, reconnectionConfig = defaultReconnectionConfig }: InteractionContextProps,
  dependencies: WithLogger
) =>
  connectionConfig$.pipe(
    switchMap(
      (connection) =>
        new Observable<InteractionContext>((subscriber) => {
          const logger = contextLogger(dependencies.logger, 'InteractionContext');
          const interactionContextReady = createInteractionContext(
            (error) => {
              logger.error(error.message);
              subscriber.error(ogmiosToCoreError(error));
            },
            (code, reason) => {
              if (code === 1000) {
                logger.debug('Websocket closed with code 1000 (Normal Closure)');
                subscriber.complete();
              } else {
                const message = `Websocket unexpectedly closed with code ${code}: ${reason}`;
                logger.error(message);
                subscriber.error(
                  new GeneralCardanoNodeError(GeneralCardanoNodeErrorCode.ConnectionFailure, { code, reason }, message)
                );
              }
            },
            {
              connection
            }
          )
            .then((interactionContext) => {
              logger.debug('Created');
              subscriber.next(interactionContext);
              return interactionContext;
            })
            .catch((error) => {
              logger.error('Failed to create', error);
              subscriber.error(ogmiosToCoreError(error));
              return null;
            });
          return () => {
            // RxJS uses synchronous finalize function by design.
            // While it's great when using observables all the way,
            // it's not so great when creating an Observable from a Promise.
            // This implementation should 'eventually close' the socket
            // when unsubscribed, but we are losing track of it
            // and can't await to confirm it was closed
            // or catch any potential errors that happen while closing it.
            void interactionContextReady
              .then((interactionContext) => {
                if (
                  interactionContext &&
                  interactionContext.socket.readyState !== interactionContext.socket.CLOSING &&
                  interactionContext.socket.readyState !== interactionContext.socket.CLOSED
                ) {
                  interactionContext.socket.close();
                }
                return interactionContext;
              })
              .catch((error) => {
                logger.error('Failed to close', error);
              });
          };
        })
    ),
    retryBackoff({
      ...reconnectionConfig,
      shouldRetry: (error) =>
        error instanceof GeneralCardanoNodeError && error.code === GeneralCardanoNodeErrorCode.ConnectionFailure
    })
  );
