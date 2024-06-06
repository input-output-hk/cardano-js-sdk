import { HttpService } from '../Http/index.js';
import { ServiceNames } from '../Program/programs/types.js';
import { providerHandler } from '../util/index.js';
import express from 'express';
import type { ChainHistoryProvider } from '@cardano-sdk/core';
import type { Logger } from 'ts-log';

export interface ChainHistoryHttpServiceDependencies {
  logger: Logger;
  chainHistoryProvider: ChainHistoryProvider;
}

export class ChainHistoryHttpService extends HttpService {
  constructor(
    { logger, chainHistoryProvider }: ChainHistoryHttpServiceDependencies,
    router: express.Router = express.Router()
  ) {
    super(ServiceNames.ChainHistory, chainHistoryProvider, router, __dirname, logger);

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
  }
}
