import { Cardano, ProviderError, ProviderFailure, TxSubmitProvider } from '@cardano-sdk/core';
import { HttpServer, HttpServerConfig, HttpServerDependencies } from '../Http';
import { Logger, dummyLogger } from 'ts-log';
import { providerHandler } from '../util';
import bodyParser from 'body-parser';
import express from 'express';

export interface TxSubmitServerDependencies {
  logger?: Logger;
  txSubmitProvider: TxSubmitProvider;
}

export class TxSubmitHttpServer extends HttpServer {
  #txSubmitProvider: TxSubmitProvider;

  private constructor(
    { txSubmitProvider }: TxSubmitServerDependencies,
    httpServerDependencies: HttpServerDependencies,
    { listen, metrics }: HttpServerConfig
  ) {
    super({ listen, metrics, name: 'TxSubmitServer' }, httpServerDependencies);
    this.#txSubmitProvider = txSubmitProvider;
  }
  static create({ txSubmitProvider, logger = dummyLogger }: TxSubmitServerDependencies, config: HttpServerConfig) {
    const router = express.Router();
    router.use(bodyParser.raw());

    router.post(
      '/submit',
      providerHandler<[Uint8Array], void>(async ([tx], _, res) => {
        try {
          return this.sendJSON(res, await txSubmitProvider.submitTx(tx));
        } catch (error) {
          logger.error(error);
          const firstError = Array.isArray(error) ? error[0] : error;
          // TODO: once all providers implement Provider,
          // move this check to a base class method
          let isHealthy;
          try {
            isHealthy = await (await txSubmitProvider.healthCheck()).ok;
          } catch {
            isHealthy = false;
          }

          if (!isHealthy) {
            return this.sendJSON(res, new ProviderError(ProviderFailure.Unhealthy, firstError), 503);
          }
          if (Cardano.util.asTxSubmissionError(error)) {
            return this.sendJSON(res, new ProviderError(ProviderFailure.BadRequest, firstError), 400);
          }
          return this.sendJSON(res, new ProviderError(ProviderFailure.Unknown, firstError), 500);
        }
      }, logger)
    );
    return new TxSubmitHttpServer(
      { logger, txSubmitProvider },
      { healthCheck: () => txSubmitProvider.healthCheck(), logger, router },
      config
    );
  }

  async initializeImpl(): Promise<void> {
    if (!(await this.#txSubmitProvider.healthCheck()).ok) {
      throw new ProviderError(ProviderFailure.Unhealthy);
    }
    await super.initializeImpl();
  }
}
