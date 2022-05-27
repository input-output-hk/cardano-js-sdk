/* eslint-disable @typescript-eslint/no-explicit-any */
import { Awaited } from '../types';
import { Logger } from 'ts-log';
import { ProviderError } from '@cardano-sdk/core';
import express from 'express';

export type ProviderHandler<Args = any, ResponseBody = any, Handler extends (...args: any) => any = any> = (
  args: Args,
  req: express.Request,
  _res: express.Response<ResponseBody | ProviderError>,
  _next: express.NextFunction,
  handler: Handler
) => void;

/**
 * Parse provider method arguments, as sent by createHttpClient<T>.
 * Arguments themselves are not validated.
 */
export const providerHandler =
  <Handler extends (...args: any) => any>(handlerFn: Handler) =>
  <Args = Parameters<Handler>, ResponseBody = Awaited<ReturnType<Handler>>>(
    handler: ProviderHandler<Args, ResponseBody, Handler>,
    logger: Logger
  ) =>
  (req: express.Request, res: express.Response, next: express.NextFunction) => {
    logger.debug(req.method, req.path, { ip: req.ip });
    if (!Array.isArray(req.body?.args)) {
      return res.status(400).send('Must use application/json Content-Type header and have {args} in body');
    }
    handler(req.body?.args, req, res, next, handlerFn);
  };
