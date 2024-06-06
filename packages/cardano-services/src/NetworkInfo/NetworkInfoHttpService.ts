import { HttpService } from '../Http/index.js';
import { ServiceNames } from '../Program/programs/types.js';
import { providerHandler } from '../util/index.js';
import express from 'express';
import type { Logger } from 'ts-log';
import type { NetworkInfoProvider } from '@cardano-sdk/core';

export interface NetworkInfoServiceDependencies {
  logger: Logger;
  networkInfoProvider: NetworkInfoProvider;
}

export class NetworkInfoHttpService extends HttpService {
  constructor(
    { networkInfoProvider, logger }: NetworkInfoServiceDependencies,
    router: express.Router = express.Router()
  ) {
    super(ServiceNames.NetworkInfo, networkInfoProvider, router, __dirname, logger);

    router.post(
      '/stake',
      providerHandler(networkInfoProvider.stake.bind(networkInfoProvider))(HttpService.routeHandler(logger), logger)
    );
    router.post(
      '/lovelace-supply',
      providerHandler(networkInfoProvider.lovelaceSupply.bind(networkInfoProvider))(
        HttpService.routeHandler(logger),
        logger
      )
    );
    router.post(
      '/era-summaries',
      providerHandler(networkInfoProvider.eraSummaries.bind(networkInfoProvider))(
        HttpService.routeHandler(logger),
        logger
      )
    );
    router.post(
      '/ledger-tip',
      providerHandler(networkInfoProvider.ledgerTip.bind(networkInfoProvider))(HttpService.routeHandler(logger), logger)
    );
    router.post(
      '/protocol-parameters',
      providerHandler(networkInfoProvider.protocolParameters.bind(networkInfoProvider))(
        HttpService.routeHandler(logger),
        logger
      )
    );
    router.post(
      '/genesis-parameters',
      providerHandler(networkInfoProvider.genesisParameters.bind(networkInfoProvider))(
        HttpService.routeHandler(logger),
        logger
      )
    );
  }
}
