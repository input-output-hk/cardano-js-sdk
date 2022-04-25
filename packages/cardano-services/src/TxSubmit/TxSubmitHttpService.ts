import { Cardano, ProviderError, ProviderFailure, TxSubmitProvider } from '@cardano-sdk/core';
import { HttpServer, HttpService } from '../Http';
import { Logger, dummyLogger } from 'ts-log';
import { providerHandler } from '../util';
import bodyParser from 'body-parser';
import express from 'express';

export interface TxSubmitHttpServiceDependencies {
  logger?: Logger;
  txSubmitProvider: TxSubmitProvider;
}

export class TxSubmitHttpService extends HttpService {
  #txSubmitProvider: TxSubmitProvider;

  private constructor(
    { logger = dummyLogger, txSubmitProvider }: TxSubmitHttpServiceDependencies,
    router: express.Router
  ) {
    super('tx-submit', router, logger);
    this.#txSubmitProvider = txSubmitProvider;
  }

  async healthCheck() {
    return this.#txSubmitProvider.healthCheck();
  }

  static async create({ logger = dummyLogger, txSubmitProvider }: TxSubmitHttpServiceDependencies) {
    const router = express.Router();
    if (!(await txSubmitProvider.healthCheck()).ok) {
      throw new ProviderError(ProviderFailure.Unhealthy);
    }
    router.use(bodyParser.raw());
    router.post(
      '/submit',
      providerHandler<[Uint8Array], void>(async ([tx], _, res) => {
        try {
          return HttpServer.sendJSON(res, await txSubmitProvider.submitTx(tx));
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
    return new TxSubmitHttpService({ logger, txSubmitProvider }, router);
  }
}
