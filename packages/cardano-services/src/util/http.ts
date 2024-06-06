import type { Application } from 'express';
import type { ListenOptions } from 'net';
import type http from 'http';

export const listenPromise = (
  serverLike: http.Server | Application,
  listenOptions: ListenOptions = {}
): Promise<http.Server> =>
  new Promise((resolve, reject) => {
    const server = serverLike.listen(listenOptions, () => resolve(server)) as http.Server;
    server.on('error', reject);
  });

export const serverClosePromise = (server: http.Server): Promise<void> =>
  new Promise((resolve, reject) => {
    server.once('close', resolve);
    server.close((error) => (error ? reject(error) : null));
  });
