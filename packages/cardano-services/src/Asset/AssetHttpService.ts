import { HttpService } from '../Http/index.js';
import { ServiceNames } from '../Program/programs/types.js';
import { providerHandler } from '../util/index.js';
import express from 'express';
import type { AssetProvider } from '@cardano-sdk/core';
import type { Logger } from 'ts-log';

/** Dependencies that are need to create AssetHttpService */
export interface AssetHttpServiceDependencies {
  /** The asset provider to fetch data */
  assetProvider: AssetProvider;

  /** The logger object */
  logger: Logger;
}

/** The Asset Http Service */
export class AssetHttpService extends HttpService {
  constructor({ assetProvider, logger }: AssetHttpServiceDependencies, router: express.Router = express.Router()) {
    super(ServiceNames.Asset, assetProvider, router, __dirname, logger);

    router.post(
      '/get-asset',
      providerHandler(assetProvider.getAsset.bind(assetProvider))(HttpService.routeHandler(logger), logger)
    );

    router.post(
      '/get-assets',
      providerHandler(assetProvider.getAssets.bind(assetProvider))(HttpService.routeHandler(logger), logger)
    );
  }
}
