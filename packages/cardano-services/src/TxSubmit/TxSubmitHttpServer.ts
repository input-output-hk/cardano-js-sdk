import { Cardano, ProviderError, ProviderFailure, TxSubmitProvider } from '@cardano-sdk/core';
import { ErrorObject, serializeError } from 'serialize-error';
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
      providerHandler<Uint8Array>(async ([tx], req, res) => {
        logger.debug('/submit', { ip: req.ip });
        let body: Error['message'] | undefined;
        try {
          await txSubmitProvider.submitTx(tx);
          body = undefined;
        } catch (error) {
          if (!(await txSubmitProvider.healthCheck()).ok) {
            res.statusCode = 503;
            body = JSON.stringify(serializeError(new ProviderError(ProviderFailure.Unhealthy, error)));
          } else {
            res.statusCode = Cardano.util.asTxSubmissionError(error) ? 400 : 500;
            body = JSON.stringify(
              Array.isArray(error) ? error.map<ErrorObject>((e) => serializeError(e)) : serializeError(error)
            );
          }
          logger.error(body);
        }
        res.send(body);
      })
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
