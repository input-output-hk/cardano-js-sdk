import { Asset, ProviderError, ProviderFailure } from '@cardano-sdk/core';
import { AssetMetadata } from './types';
import { HostDoesNotExist } from '../errors';
import { Logger, dummyLogger } from 'ts-log';
import { RunnableModule } from '../RunnableModule';
import axios, { AxiosInstance } from 'axios';

export class MetadataClient extends RunnableModule {
  #axiosClient: AxiosInstance;

  constructor(private metadataServerUri: string, logger: Logger = dummyLogger) {
    super('MetadataClient', logger);
    this.#axiosClient = axios.create({
      baseURL: this.metadataServerUri
    });
  }

  private async ensureMetadataServerIsAvailable(): Promise<void> {
    try {
      await this.#axiosClient.get('/metadata/healthcheck');
    } catch (error) {
      if (axios.isAxiosError(error)) {
        if (error?.code === 'ENOTFOUND') {
          throw new HostDoesNotExist('metadata server');
        } else if (error.response?.status !== 404) {
          throw new ProviderError(ProviderFailure.Unknown);
        }
      } else throw new ProviderError(ProviderFailure.Unknown);
    }
  }

  public async fetch(assetIds: Asset.AssetInfo['assetId'][]): Promise<AssetMetadata[]> {
    try {
      const response = await this.#axiosClient.post('metadata/query', {
        properties: ['decimals', 'description', 'logo', 'name', 'ticker', 'url'],
        subjects: assetIds
      });
      return response.data.subjects;
    } catch (error) {
      if (axios.isAxiosError(error) && error?.code === 'ENOTFOUND') {
        this.logger.error({ err: error });
        throw new HostDoesNotExist('metadata server');
      } else {
        throw new ProviderError(ProviderFailure.Unknown);
      }
    }
  }

  public async initializeImpl() {
    await this.ensureMetadataServerIsAvailable();
  }

  // eslint-disable-next-line @typescript-eslint/no-empty-function
  public async shutdownImpl(): Promise<void> {}

  // eslint-disable-next-line @typescript-eslint/no-empty-function
  public async startImpl() {}
}
