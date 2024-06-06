import { TxSubmission, ensureSocketIsOpen, safeJSON } from '@cardano-ogmios/client';
import { baseRequest } from '@cardano-ogmios/client/dist/Request';
import { nanoid } from 'nanoid';
import type { InteractionContext } from '@cardano-ogmios/client';
import type { Ogmios, TxId } from '@cardano-ogmios/schema';
import type { WebSocket } from '@cardano-ogmios/client/dist/IsomorphicWebSocket';

/** See also {@link createTxSubmissionClient} for creating a client. */
export interface TxSubmissionClient {
  context: InteractionContext;
  submitTx: (bytes: string) => Promise<TxId>;
  shutdown: () => Promise<void>;
}

/**
 * Waits for a response with the reflection property requestId matching the one we send in the mirror
 * property of the request.
 *
 * @param socket The websocket object.
 * @param requestId The requestId, this will be used to filter our response.
 * @param resolve The original promise resolve callback.
 * @param reject The original promise reject callback.
 */
const waitForResponse =
  (
    socket: WebSocket,
    requestId: string,
    resolve: { (value: string | PromiseLike<string>): void; (arg0: string): void },
    reject: { (reason?: never): void; (arg0: Error[]): void }
  ) =>
  (message: string) => {
    const submitTxRes: Ogmios['SubmitTxResponse'] = safeJSON.parse(message);

    if ((submitTxRes.type as string) !== 'jsonwsp/fault' && submitTxRes.methodname !== 'SubmitTx') {
      return;
    }

    if (!submitTxRes.reflection || submitTxRes.reflection.requestId !== requestId) return;

    // This is the response we are waiting for, we can unregister our callback from the socket.
    socket.removeListener('message', waitForResponse(socket, requestId, resolve, reject));

    const response = TxSubmission.handleSubmitTxResponse(submitTxRes);

    if (TxSubmission.isTxId(response)) {
      resolve(response);
    } else {
      reject(response);
    }
  };

/** Create a client for submitting signed transactions to underlying Cardano chain. */
export const createTxSubmissionClient = async (context: InteractionContext): Promise<TxSubmissionClient> =>
  Promise.resolve({
    context,
    shutdown: () =>
      new Promise((resolve) => {
        ensureSocketIsOpen(context.socket);
        context.socket.once('close', resolve);
        context.socket.close();
      }),
    submitTx: async (bytes) => {
      ensureSocketIsOpen(context.socket);
      const requestId = nanoid(5);
      return new Promise<string>((resolve, reject) => {
        context.socket.on('message', waitForResponse(context.socket, requestId, resolve, reject));

        context.socket.send(
          safeJSON.stringify({
            ...baseRequest,
            args: { submit: bytes },
            methodname: 'SubmitTx',
            mirror: { requestId }
          } as Ogmios['SubmitTx'])
        );
      });
    }
  } as TxSubmissionClient);
