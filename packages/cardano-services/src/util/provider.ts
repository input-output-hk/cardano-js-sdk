import { Logger } from 'ts-log';
import { ProviderError } from '@cardano-sdk/core';
import express from 'express';

/**
 * Parse provider method arguments, as sent by createHttpClient<T>.
 * Arguments themselves are not validated.
 */
export const providerHandler =
  <Args, ResponseBody>(
    handler: (
      args: Args,
      req: express.Request,
      _res: express.Response<ResponseBody | ProviderError>,
      _next: express.NextFunction
    ) => void,
    logger: Logger
  ) =>
  (req: express.Request, res: express.Response, next: express.NextFunction) => {
    logger.debug(req.method, req.path, { ip: req.ip });
    if (!Array.isArray(req.body?.args)) {
      return res.status(400).send('Must use application/json Content-Type header and have {args} in body');
    }
    handler(req.body?.args, req, res, next);
  };
