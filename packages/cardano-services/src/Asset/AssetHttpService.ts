import * as OpenApiValidator from 'express-openapi-validator';
import { AssetProvider } from '@cardano-sdk/core';
import { HttpService } from '../Http';
import { Logger } from 'ts-log';
import { ServiceNames } from '../Program/programs/types';
import { providerHandler } from '../util';
import express from 'express';
import path from 'path';

/**
 * Dependencies that are need to create AssetHttpService
 */
export interface AssetHttpServiceDependencies {
  /**
   * The asset provider to fetch data
   */
  assetProvider: AssetProvider;

  /**
   * The logger object
   */
  logger: Logger;
}

/**
 * The Asset Http Service
 */
export class AssetHttpService extends HttpService {
  constructor({ assetProvider, logger }: AssetHttpServiceDependencies, router: express.Router = express.Router()) {
    super(ServiceNames.Asset, assetProvider, router, logger);

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
      '/get-asset',
      providerHandler(assetProvider.getAsset.bind(assetProvider))(HttpService.routeHandler(logger), logger)
    );
  }
}
