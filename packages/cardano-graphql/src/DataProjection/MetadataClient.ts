import { Asset } from '../Schema/types';
import { AssetMetadata } from './types';
import { HostDoesNotExist } from './errors';
import { Logger, dummyLogger } from 'ts-log';
import { RunnableModule } from './RunnableModule';
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
          throw error;
        }
      } else throw error;
    }
  }

  public async fetch(assetIds: Asset['assetId'][]): Promise<AssetMetadata[]> {
    try {
      const response = await this.#axiosClient.post('metadata/query', {
        subjects: assetIds,
        properties: ['decimals', 'description', 'logo', 'name', 'ticker', 'url']
      });
      return response.data.subjects;
    } catch (error) {
      if (axios.isAxiosError(error) && error?.code === 'ENOTFOUND') {
        this.logger.error({ err: error });
        throw new HostDoesNotExist('metadata server');
      } else {
        throw error;
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
