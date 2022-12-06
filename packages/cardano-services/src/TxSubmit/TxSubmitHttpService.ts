import * as OpenApiValidator from 'express-openapi-validator';
import { Cardano, ProviderError, ProviderFailure, TxSubmitProvider } from '@cardano-sdk/core';
import { HttpServer, HttpService } from '../Http';
import { Logger } from 'ts-log';
import { ServiceNames } from '../Program/ServiceNames';
import { providerHandler } from '../util';
import bodyParser from 'body-parser';
import express from 'express';
import path from 'path';

export interface TxSubmitHttpServiceDependencies {
  logger: Logger;
  txSubmitProvider: TxSubmitProvider;
}

export class TxSubmitHttpService extends HttpService {
  constructor(
    { logger, txSubmitProvider }: TxSubmitHttpServiceDependencies,
    router: express.Router = express.Router()
  ) {
    super(ServiceNames.TxSubmit, txSubmitProvider, router, logger);

    router.use(bodyParser.raw());
    const apiSpec = path.join(__dirname, 'openApi.json');
    router.use(
      OpenApiValidator.middleware({
        apiSpec,
        ignoreUndocumented: true,
        validateRequests: true,
        validateResponses: true
      })
    );
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

          if (!isHealthy) {
            return HttpServer.sendJSON(res, new ProviderError(ProviderFailure.Unhealthy, firstError), 503);
          }
          if (Cardano.util.asTxSubmissionError(error)) {
            return HttpServer.sendJSON(res, new ProviderError(ProviderFailure.BadRequest, firstError), 400);
          }
          return HttpServer.sendJSON(res, new ProviderError(ProviderFailure.Unknown, firstError), 500);
        }
      }, logger)
    );
  }
}
