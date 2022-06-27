import * as OpenApiValidator from 'express-openapi-validator';
import { DbSyncNetworkInfoProvider } from './DbSyncNetworkInfoProvider';
import { HttpService } from '../Http';
import { Logger, dummyLogger } from 'ts-log';
import { ProviderError, ProviderFailure } from '@cardano-sdk/core';
import { ServiceNames } from '../Program';
import { providerHandler } from '../util';
import express from 'express';
import path from 'path';

export interface NetworkInfoServiceDependencies {
  logger?: Logger;
  networkInfoProvider: DbSyncNetworkInfoProvider;
}

export class NetworkInfoHttpService extends HttpService {
  #networkInfoProvider: DbSyncNetworkInfoProvider;

  private constructor(
    { networkInfoProvider, logger = dummyLogger }: NetworkInfoServiceDependencies,
    router: express.Router
  ) {
    super(ServiceNames.NetworkInfo, router, logger);
    this.#networkInfoProvider = networkInfoProvider;
  }

  static create({ logger = dummyLogger, networkInfoProvider }: NetworkInfoServiceDependencies) {
    const router = express.Router();

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

    return new NetworkInfoHttpService({ logger, networkInfoProvider }, router);
  }

  async healthCheck() {
    return this.#networkInfoProvider.healthCheck();
  }

  async initializeImpl(): Promise<void> {
    if (!(await this.healthCheck()).ok) {
      throw new ProviderError(ProviderFailure.Unhealthy);
    }
  }

  async startImpl(): Promise<void> {
    await this.#networkInfoProvider.start();
  }

  async shutdownImpl(): Promise<void> {
    await this.#networkInfoProvider.close();
  }
}
