import * as OpenApiValidator from 'express-openapi-validator';
import { DbSyncUtxoProvider } from './DbSyncUtxoProvider';
import { HttpService } from '../Http';
import { Logger, dummyLogger } from 'ts-log';
import { ProviderError, ProviderFailure } from '@cardano-sdk/core';
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
      providerHandler(utxoProvider.utxoByAddresses.bind(utxoProvider))(HttpService.routeHandler(logger), logger)
    );
    return new UtxoHttpService({ logger, utxoProvider }, router);
  }

  async initializeImpl(): Promise<void> {
    if (!(await this.healthCheck()).ok) {
      throw new ProviderError(ProviderFailure.Unhealthy);
    }
  }

  async healthCheck() {
    return this.#utxoProvider.healthCheck();
  }
}
