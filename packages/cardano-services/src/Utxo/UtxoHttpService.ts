import { HttpService } from '../Http';
import { Logger } from 'ts-log';
import { ServiceNames } from '../Program/programs/types';
import { UtxoProvider } from '@cardano-sdk/core';
import { providerHandler } from '../util';
import express from 'express';

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
