import { getRandomPort } from 'get-port-please';
import { listenPromise, serverClosePromise } from '../../src/util/http';
import express from 'express';
import http from 'http';

describe('http utils', () => {
  let port: number;
  beforeAll(async () => {
    port = await getRandomPort();
  });
  describe('listenPromise', () => {
    let server: http.Server;

    afterEach(() => {
      server.close();
    });

    it('promisifies express app.listen', async () => {
      const app = express();
      expect((server = await listenPromise(app, { port }))).toBeInstanceOf(http.Server);
      await expect(listenPromise(app, { port })).rejects.toThrow();
    });

    it('promisifies server.listen', async () => {
      server = http.createServer();
      server = await listenPromise(server, { port });
      expect(server).toBeInstanceOf(http.Server);
      await expect(listenPromise(server, { port })).rejects.toThrow();
    });
  });

  describe('serverClosePromise', () => {
    let server: http.Server;

    it('promisifies server.close', async () => {
      server = http.createServer();
      const spy = jest.fn();
      await listenPromise(server, { port });
      server.on('close', spy);
      await expect(await serverClosePromise(server)).resolves;
      expect(spy).toHaveBeenCalled();
    });
  });
});
