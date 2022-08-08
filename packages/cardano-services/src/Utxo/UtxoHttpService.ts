import * as OpenApiValidator from 'express-openapi-validator';
import { HttpService } from '../Http';
import { Logger } from 'ts-log';
import { ServiceNames } from '../Program';
import { UtxoProvider } from '@cardano-sdk/core';
import { providerHandler } from '../util';
import express from 'express';
import path from 'path';

export interface UtxoServiceDependencies {
  logger: Logger;
  utxoProvider: UtxoProvider;
}

export class UtxoHttpService extends HttpService {
  constructor({ utxoProvider, logger }: UtxoServiceDependencies, router: express.Router = express.Router()) {
    super(ServiceNames.Utxo, utxoProvider, router, logger);

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
      '/utxo-by-addresses',
      providerHandler(utxoProvider.utxoByAddresses.bind(utxoProvider))(HttpService.routeHandler(logger), logger)
    );
  }
}
