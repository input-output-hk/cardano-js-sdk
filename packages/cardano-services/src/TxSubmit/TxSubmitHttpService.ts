import { CardanoNodeUtil, ProviderError, ProviderFailure, providerFailureToStatusCodeMap } from '@cardano-sdk/core';
import { HttpServer, HttpService } from '../Http/index.js';
import { ServiceNames } from '../Program/programs/types.js';
import { providerHandler } from '../util/index.js';
import bodyParser from 'body-parser';
import express from 'express';
import type { Logger } from 'ts-log';
import type { TxSubmitProvider } from '@cardano-sdk/core';

export interface TxSubmitHttpServiceDependencies {
  logger: Logger;
  txSubmitProvider: TxSubmitProvider;
}

export class TxSubmitHttpService extends HttpService {
  constructor(
    { logger, txSubmitProvider }: TxSubmitHttpServiceDependencies,
    router: express.Router = express.Router()
  ) {
    super(ServiceNames.TxSubmit, txSubmitProvider, router, __dirname, logger);

    router.use(bodyParser.raw());
    router.post(
      '/submit',
      providerHandler(txSubmitProvider.submitTx.bind(txSubmitProvider))(async (_, _r, res, _n, handler) => {
        try {
          return HttpServer.sendJSON(res, await handler(_r.body));
        } catch (error) {
          logger.error(error);
          const firstError = Array.isArray(error) ? error[0] : error;
          // TODO: once all providers implement Provider,
          // move this check to a base class method
          let isHealthy;
          try {
            isHealthy = (await txSubmitProvider.healthCheck()).ok;
          } catch {
            isHealthy = false;
          }
          if (error instanceof ProviderError) {
            return HttpServer.sendJSON(res, error, providerFailureToStatusCodeMap[error.reason]);
          }
          if (!isHealthy) {
            return HttpServer.sendJSON(res, new ProviderError(ProviderFailure.Unhealthy, firstError), 503);
          }
          if (CardanoNodeUtil.asTxSubmissionError(error)) {
            return HttpServer.sendJSON(res, new ProviderError(ProviderFailure.BadRequest, firstError), 400);
          }
          return HttpServer.sendJSON(res, new ProviderError(ProviderFailure.Unknown, firstError), 500);
        }
      }, logger)
    );
  }
}
