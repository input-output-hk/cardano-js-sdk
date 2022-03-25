import { Cardano, ProviderError, ProviderFailure, TxSubmitProvider } from '@cardano-sdk/core';
import { ErrorObject, serializeError } from 'serialize-error';
import { HttpServer, HttpServerConfig } from '../Http';
import { Logger, dummyLogger } from 'ts-log';
import bodyParser, { Options } from 'body-parser';
import express, { Router } from 'express';

export interface TxSubmitServerDependencies {
  txSubmitProvider: TxSubmitProvider;
  logger?: Logger;
}

export interface TxSubmitHttpServerConfig extends HttpServerConfig {
  bodyParser?: {
    limit?: Options['limit'];
  };
}

export class TxSubmitHttpServer extends HttpServer {
  #txSubmitProvider: TxSubmitProvider;

  private constructor(
    config: TxSubmitHttpServerConfig,
    router: Router,
    { logger = dummyLogger, txSubmitProvider }: TxSubmitServerDependencies
  ) {
    super({ ...config, name: 'TxSubmitServer' }, { logger, router });
    this.#txSubmitProvider = txSubmitProvider;
  }
  static create(
    config: TxSubmitHttpServerConfig,
    { txSubmitProvider, logger = dummyLogger }: TxSubmitServerDependencies
  ) {
    const router = express.Router();
    router.use(bodyParser.raw({ limit: config.bodyParser?.limit || '500kB', type: 'application/cbor' }));
    router.get('/health', async (req, res) => {
      logger.debug('/health', { ip: req.ip });
      let body: { ok: boolean } | Error['message'];
      try {
        body = await txSubmitProvider.healthCheck();
      } catch (error) {
        logger.error(error);
        body = error instanceof ProviderError ? error.message : 'Unknown error';
        res.statusCode = 500;
      }
      res.send(body);
    });
    router.post('/submit', async (req, res) => {
      if (req.header('Content-Type') !== 'application/cbor') {
        res.statusCode = 400;
        return res.send('Must use application/cbor Content-Type header');
      }
      logger.debug('/submit', { ip: req.ip });
      let body: Error['message'] | undefined;
      try {
        await txSubmitProvider.submitTx(new Uint8Array(req.body));
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
    });
    return new TxSubmitHttpServer(config, router, { logger, txSubmitProvider });
  }

  async initializeImpl(): Promise<void> {
    if (!(await this.#txSubmitProvider.healthCheck()).ok) {
      throw new ProviderError(ProviderFailure.Unhealthy);
    }
    await super.initializeImpl();
  }
}
