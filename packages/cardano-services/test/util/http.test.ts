import { getPort } from 'get-port-please';
import { listenPromise, serverClosePromise } from '../../src/util/http.js';
import express from 'express';
import http from 'http';

describe('http utils', () => {
  describe('listenPromise', () => {
    let port: number;
    let server: http.Server;

    afterEach(() => {
      server.close();
    });

    it('promisifies express app.listen', async () => {
      const app = express();
      port = await getPort();
      expect((server = await listenPromise(app, { port }))).toBeInstanceOf(http.Server);
      await expect(listenPromise(app, { port })).rejects.toThrow();
    });

    it('promisifies server.listen', async () => {
      server = http.createServer();
      port = await getPort();
      server = await listenPromise(server, { port });
      expect(server).toBeInstanceOf(http.Server);
      await expect(listenPromise(server, { port })).rejects.toThrow();
    });
  });

  describe('serverClosePromise', () => {
    let port: number;
    let server: http.Server;

    it('promisifies server.close', async () => {
      server = http.createServer();
      port = await getPort();
      const spy = jest.fn();
      await listenPromise(server, { port });
      server.on('close', spy);
      await expect(await serverClosePromise(server)).resolves;
      expect(spy).toHaveBeenCalled();
    });
  });
});
