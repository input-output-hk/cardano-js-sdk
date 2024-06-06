import { HttpService } from '../Http/index.js';
import { Router } from 'express';
import { ServiceNames } from '../Program/programs/types.js';
import { handleProviderPaths } from '@cardano-sdk/core';
import type { HandleProvider } from '@cardano-sdk/core';
import type { Logger } from 'ts-log';

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
