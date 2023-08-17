import { HandleProvider, handleProviderPaths } from '@cardano-sdk/core';
import { HttpService } from '../Http';
import { Logger } from 'ts-log';
import { Router } from 'express';
import { ServiceNames } from '../Program/programs/types';
import { useOpenApi } from '../util';
import path from 'path';

const apiSpec = path.join(__dirname, 'openApi.json');

export interface HandleServiceDependencies {
  handleProvider: HandleProvider;
  logger: Logger;
}

export class HandleHttpService extends HttpService {
  constructor({ logger, handleProvider }: HandleServiceDependencies, router: Router = Router()) {
    super(ServiceNames.Handle, handleProvider, router, apiSpec, logger);

    useOpenApi(apiSpec, router);
    this.attachProviderRoutes(handleProvider, router, handleProviderPaths);
  }
}
