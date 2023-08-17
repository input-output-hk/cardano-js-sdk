import { ChainHistoryProvider } from '@cardano-sdk/core';
import { HttpService } from '../Http';
import { Logger } from 'ts-log';
import { ServiceNames } from '../Program/programs/types';
import { providerHandler } from '../util';
import express from 'express';

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
