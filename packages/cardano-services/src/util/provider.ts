import express from 'express';

/**
 * Parse provider method arguments, as sent by createHttpClient<T>.
 * Arguments themselves are not validated.
 */
export const providerHandler =
  <A1, A2 = unknown>(
    handler: (args: [A1, A2], req: express.Request, _res: express.Response, _next: express.NextFunction) => void
  ) =>
  (req: express.Request, res: express.Response, next: express.NextFunction) => {
    if (!Array.isArray(req.body?.args)) {
      return res.status(400).send('Must use application/json Content-Type header and have {args} in body');
    }
    handler(req.body?.args, req, res, next);
  };
