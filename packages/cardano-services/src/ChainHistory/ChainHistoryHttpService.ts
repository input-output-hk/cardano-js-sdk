import * as OpenApiValidator from 'express-openapi-validator';
import { ChainHistoryProvider } from '@cardano-sdk/core';
import { DbSyncChainHistoryProvider } from './DbSyncChainHistory/DbSyncChainHistoryProvider';
import { HttpService } from '../Http';
import { Logger, dummyLogger } from 'ts-log';
import { ServiceNames } from '../Program';
import { providerHandler } from '../util';
import express from 'express';
import path from 'path';

export interface ChainHistoryHttpServiceDependencies {
  logger?: Logger;
  chainHistoryProvider: DbSyncChainHistoryProvider;
}

export class ChainHistoryHttpService extends HttpService {
  #chainHistoryProvider: ChainHistoryProvider;
  private constructor(
    { logger = dummyLogger, chainHistoryProvider }: ChainHistoryHttpServiceDependencies,
    router: express.Router
  ) {
    super(ServiceNames.ChainHistory, router, logger);
    this.#chainHistoryProvider = chainHistoryProvider;
  }

  async healthCheck() {
    return this.#chainHistoryProvider.healthCheck();
  }

  static async create({ logger = dummyLogger, chainHistoryProvider }: ChainHistoryHttpServiceDependencies) {
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
      '/blocks/by-hashes',
      providerHandler(chainHistoryProvider.blocksByHashes.bind(chainHistoryProvider))(
        HttpService.routeHandler(logger),
        logger
      )
    );
    router.post(
      '/txs/by-hashes',
      providerHandler(chainHistoryProvider.transactionsByHashes.bind(chainHistoryProvider))(
        HttpService.routeHandler(logger),
        logger
      )
    );
    router.post(
      '/txs/by-addresses',
      providerHandler(chainHistoryProvider.transactionsByAddresses.bind(chainHistoryProvider))(
        HttpService.routeHandler(logger),
        logger
      )
    );
    return new ChainHistoryHttpService({ chainHistoryProvider, logger }, router);
  }
}
