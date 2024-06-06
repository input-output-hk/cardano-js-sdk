/* eslint-disable @typescript-eslint/no-explicit-any */
import { logger } from '@cardano-sdk/util-dev';
import { providerHandler } from '../../src/util/index.js';

describe('util/provider', () => {
  describe('providerHandler', () => {
    it('calls handler with request body, doesnt send any response', () => {
      const body = {
        field: 'value'
      };
      const handler = jest.fn().mockImplementation((args) => {
        expect(args).toBe(body);
      });
      const fn = jest.fn();
      const req = { body };
      const res = { send: jest.fn(), status: jest.fn() };
      const next = {} as any;
      providerHandler(fn)(handler, logger)(req as any, res as any, next);
      expect(handler).toBeCalledTimes(1);
      expect(handler).toBeCalledWith(body, req, res, next, fn);
      expect(res.send).not.toBeCalled();
      expect(res.status).not.toBeCalled();
    });

    it('given invalid request, sends 400 and does not call handler', () => {
      const handler = jest.fn();
      const req = { body: 'invalidBody' };
      const res: any = {
        send: jest.fn(),
        status: jest.fn().mockImplementation(() => res)
      };
      const next = {} as any;
      providerHandler(jest.fn())(handler, logger)(req as any, res as any, next);
      expect(handler).not.toBeCalled();
      expect(res.status).toBeCalledTimes(1);
      expect(res.status).toBeCalledWith(400);
      expect(res.send).toBeCalledTimes(1);
    });
  });
});
