/* eslint-disable @typescript-eslint/no-explicit-any */
import { dummyLogger } from 'ts-log';
import { providerHandler } from '../../src/util';

describe('util/provider', () => {
  describe('providerHandler', () => {
    it('calls handler with {args} from request body, doesnt send any response', () => {
      const handler = jest.fn().mockImplementation((args) => {
        expect(args[0]).toBe('arg');
      });
      const fn = jest.fn();
      const req = { body: { args: ['arg'] } };
      const res = { send: jest.fn(), status: jest.fn() };
      const next = {} as any;
      providerHandler(fn)(handler, dummyLogger)(req as any, res as any, next);
      expect(handler).toBeCalledTimes(1);
      expect(handler).toBeCalledWith(['arg'], req, res, next, fn);
      expect(res.send).not.toBeCalled();
      expect(res.status).not.toBeCalled();
    });

    it('given invalid request, sends 400 and does not call handler', () => {
      const handler = jest.fn();
      const req = { body: { args: {} } };
      const res: any = {
        send: jest.fn(),
        status: jest.fn().mockImplementation(() => res)
      };
      const next = {} as any;
      providerHandler(jest.fn())(handler, dummyLogger)(req as any, res as any, next);
      expect(handler).not.toBeCalled();
      expect(res.status).toBeCalledTimes(1);
      expect(res.status).toBeCalledWith(400);
      expect(res.send).toBeCalledTimes(1);
    });
  });
});
