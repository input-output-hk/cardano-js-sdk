import { HttpService } from '../Http';
import { Logger } from 'ts-log';
import { NftMetadataService } from './types';
import { ServiceNames } from '../Program';
import { providerHandler } from '../util';
import express from 'express';

export interface NftMetadataHttpServiceDependencies {
  nftMetadataService: NftMetadataService;
  logger: Logger;
}

export class NftMetadataHttpService extends HttpService {
  constructor(
    { nftMetadataService, logger }: NftMetadataHttpServiceDependencies,
    router: express.Router = express.Router()
  ) {
    super(ServiceNames.NftMetadata, nftMetadataService, router, logger);

    router.get(
      '/nft-metadata',
      providerHandler(nftMetadataService.getNftMetadata.bind(nftMetadataService))(
        HttpService.routeHandler(logger),
        logger
      )
    );
  }
}
