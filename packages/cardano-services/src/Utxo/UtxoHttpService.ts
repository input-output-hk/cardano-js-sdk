import * as OpenApiValidator from 'express-openapi-validator';
import { Cardano, ProviderError, ProviderFailure } from '@cardano-sdk/core';
import { DbSyncUtxoProvider } from './DbSyncUtxoProvider';
import { HttpServer, HttpService } from '../Http';
import { Logger, dummyLogger } from 'ts-log';
import { ServiceNames } from '../Program';
import { providerHandler } from '../util';
import express from 'express';
import path from 'path';

export interface UtxoServiceDependencies {
  logger?: Logger;
  utxoProvider: DbSyncUtxoProvider;
}

export class UtxoHttpService extends HttpService {
  #utxoProvider: DbSyncUtxoProvider;

  private constructor({ utxoProvider, logger = dummyLogger }: UtxoServiceDependencies, router: express.Router) {
    super(ServiceNames.Utxo, router, logger);
    this.#utxoProvider = utxoProvider;
  }

  async healthCheck() {
    return this.#utxoProvider.healthCheck();
  }

  static create({ logger = dummyLogger, utxoProvider }: UtxoServiceDependencies) {
    const router = express.Router();
    const apiSpec = path.join(__dirname, 'openApi.json');
    router.use(
      OpenApiValidator.middleware({
        apiSpec,
        ignoreUndocumented: true, // otherwhise /metrics endpoint should be included in spec
        validateRequests: true,
        validateResponses: true
      })
    );
    router.post(
      '/utxo-by-addresses',
      providerHandler<[Cardano.Address[]], Cardano.Utxo[]>(async ([addresses], _, res) => {
        try {
          return HttpServer.sendJSON(res, await utxoProvider.utxoByAddresses(addresses));
        } catch (error) {
          logger.error(error);
          return HttpServer.sendJSON(res, new ProviderError(ProviderFailure.Unhealthy, error), 500);
        }
      }, logger)
    );
    return new UtxoHttpService({ logger, utxoProvider }, router);
  }
}
