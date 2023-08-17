import { HandleProvider, handleProviderPaths } from '@cardano-sdk/core';
import { HttpService } from '../Http';
import { Logger } from 'ts-log';
import { Router } from 'express';
import { ServiceNames } from '../Program/programs/types';

export interface HandleServiceDependencies {
  handleProvider: HandleProvider;
  logger: Logger;
}

export class HandleHttpService extends HttpService {
  constructor({ logger, handleProvider }: HandleServiceDependencies, router: Router = Router()) {
    super(ServiceNames.Handle, handleProvider, router, __dirname, logger);

    this.attachProviderRoutes(handleProvider, router, handleProviderPaths);
  }
}
