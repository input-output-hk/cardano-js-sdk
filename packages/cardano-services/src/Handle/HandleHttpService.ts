import { HandleProvider } from '@cardano-sdk/core';
import { HttpService } from '../Http';
import { Logger } from 'ts-log';
import { Router } from 'express';
import { ServiceNames } from '../Program/programs/types';
import { providerHandler, useOpenApi } from '../util';

export interface HandleServiceDependencies {
  handleProvider: HandleProvider;
  logger: Logger;
}

export class HandleHttpService extends HttpService {
  constructor({ logger, handleProvider }: HandleServiceDependencies, router: Router = Router()) {
    super(ServiceNames.Handle, handleProvider, router, logger);

    useOpenApi(__dirname, router);

    router.post(
      '/resolve',
      providerHandler(handleProvider.resolveHandles.bind(handleProvider))(HttpService.routeHandler(logger), logger)
    );
  }
}
