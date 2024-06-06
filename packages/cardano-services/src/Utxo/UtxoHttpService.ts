import { HttpService } from '../Http/index.js';
import { ServiceNames } from '../Program/programs/types.js';
import { providerHandler } from '../util/index.js';
import express from 'express';
import type { Logger } from 'ts-log';
import type { UtxoProvider } from '@cardano-sdk/core';

export interface UtxoServiceDependencies {
  logger: Logger;
  utxoProvider: UtxoProvider;
}

export class UtxoHttpService extends HttpService {
  constructor({ utxoProvider, logger }: UtxoServiceDependencies, router: express.Router = express.Router()) {
    super(ServiceNames.Utxo, utxoProvider, router, __dirname, logger);

    router.post(
      '/utxo-by-addresses',
      providerHandler(utxoProvider.utxoByAddresses.bind(utxoProvider))(HttpService.routeHandler(logger), logger)
    );
  }
}
