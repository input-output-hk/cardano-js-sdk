import { createServer } from 'http';
import { getRandomPort } from 'get-port-please';
import type { IncomingMessage, RequestListener } from 'http';

export type MockHandler = (req?: IncomingMessage) => Promise<{ body?: unknown; code?: number }>;
export type ListenerGenerator = (handler: MockHandler) => RequestListener;

/**
 * A factory to create a generic mocked HTTP server for testing purposes
 *
 * @param {ListenerGenerator} listenerGenerator Custom listener needed to instantiate the server
 * @param serverPort Optional server port
 * @returns {(handler: MockHandler) => { closeMock: () => Promise<void>; serverUrl: string }}
 * Object exposing close mock callback and server url
 */
export const createGenericMockServer =
  (listenerGenerator: ListenerGenerator, serverPort?: number) =>
  (handler: MockHandler = async () => ({})) =>
    // eslint-disable-next-line func-call-spacing
    new Promise<{ closeMock: () => Promise<void>; serverUrl: string }>(async (resolve, reject) => {
      try {
        const port = serverPort || (await getRandomPort());
        const server = createServer(listenerGenerator(handler));

        let resolver: () => void = jest.fn();
        let rejecter: (reason: unknown) => void = jest.fn();

        // eslint-disable-next-line @typescript-eslint/no-shadow
        const closePromise = new Promise<void>((resolve, reject) => {
          resolver = resolve;
          rejecter = reject;
        });

        server.on('error', rejecter);
        server.listen(port, 'localhost', () =>
          resolve({
            closeMock: () => {
              server.close((error) => (error ? rejecter(error) : resolver()));
              return closePromise;
            },
            serverUrl: `http://localhost:${port}`
          })
        );
      } catch (error) {
        reject(error);
      }
    });
