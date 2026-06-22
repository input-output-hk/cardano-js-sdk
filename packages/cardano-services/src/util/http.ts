import { Application } from 'express';
import { ListenOptions } from 'net';
import http from 'http';

export const listenPromise = (
  serverLike: http.Server | Application,
  listenOptions: ListenOptions = {}
): Promise<http.Server> =>
  new Promise((resolve, reject) => {
    // express 5's `app.listen` forwards bind errors to the listen callback (error-first),
    // whereas raw http.Server.listen signals them via the 'error' event — handle both so a
    // failed bind (e.g. EADDRINUSE) rejects instead of resolving with an unbound server.
    const server = serverLike.listen(listenOptions, (error?: Error) =>
      error ? reject(error) : resolve(server)
    ) as http.Server;
    server.on('error', reject);
  });

export const serverClosePromise = (server: http.Server): Promise<void> =>
  new Promise((resolve, reject) => {
    server.once('close', resolve);
    server.close((error) => (error ? reject(error) : null));
  });
