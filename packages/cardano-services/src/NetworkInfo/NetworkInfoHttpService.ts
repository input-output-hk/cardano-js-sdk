import * as OpenApiValidator from 'express-openapi-validator';
import { HttpService } from '../Http';
import { Logger } from 'ts-log';
import { NetworkInfoProvider } from '@cardano-sdk/core';
import { ServiceNames } from '../Program';
import { providerHandler } from '../util';
import express from 'express';
import path from 'path';

export interface NetworkInfoServiceDependencies {
  logger: Logger;
  networkInfoProvider: NetworkInfoProvider;
}

export class NetworkInfoHttpService extends HttpService {
  constructor(
    { networkInfoProvider, logger }: NetworkInfoServiceDependencies,
    router: express.Router = express.Router()
  ) {
    super(ServiceNames.NetworkInfo, networkInfoProvider, router, logger);

    const apiSpec = path.join(__dirname, 'openApi.json');
    router.use(
      OpenApiValidator.middleware({
        apiSpec,
        ignoreUndocumented: true,
        validateRequests: true,
        validateResponses: true
      })
    );

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
      '/time-settings',
      providerHandler(networkInfoProvider.timeSettings.bind(networkInfoProvider))(
        HttpService.routeHandler(logger),
        logger
      )
    );
    router.post(
      '/ledger-tip',
      providerHandler(networkInfoProvider.ledgerTip.bind(networkInfoProvider))(HttpService.routeHandler(logger), logger)
    );
    router.post(
      '/current-wallet-protocol-parameters',
      providerHandler(networkInfoProvider.currentWalletProtocolParameters.bind(networkInfoProvider))(
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
