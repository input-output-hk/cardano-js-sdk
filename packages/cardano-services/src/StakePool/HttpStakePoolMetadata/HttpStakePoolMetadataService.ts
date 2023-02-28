import { Cardano, ProviderError, ProviderFailure } from '@cardano-sdk/core';
import { Logger } from 'ts-log';
import { StakePoolExtMetadataResponse, StakePoolMetadataService } from '../types';
import { ValidationError, validate } from 'jsonschema';
import { getExtMetadataUrl, getSchemaFormat, loadJsonSchema } from './util';
import { mapToExtendedMetadata } from './mappers';
import axios, { AxiosInstance } from 'axios';

const HTTP_CLIENT_TIMEOUT = 1 * 1000;
const HTTP_CLIENT_MAX_CONTENT_LENGTH = 5000;

export const createHttpStakePoolMetadataService = (
  logger: Logger,
  axiosClient: AxiosInstance = axios.create({
    maxContentLength: HTTP_CLIENT_MAX_CONTENT_LENGTH,
    timeout: HTTP_CLIENT_TIMEOUT
  })
): StakePoolMetadataService => ({
  async getStakePoolExtendedMetadata(metadata: Cardano.StakePoolMetadata): Promise<Cardano.ExtendedStakePoolMetadata> {
    const url = getExtMetadataUrl(metadata);
    try {
      logger.debug('About to fetch stake pool extended metadata');
      const { data } = await axiosClient.get<StakePoolExtMetadataResponse>(url);
      const schema = loadJsonSchema(getSchemaFormat(metadata));
      validate(data, schema, { throwError: true });
      return mapToExtendedMetadata(data);
    } catch (error) {
      if (axios.isAxiosError(error)) {
        if (error.response?.status === 404) {
          throw new ProviderError(
            ProviderFailure.NotFound,
            error,
            `StakePoolMetadataService failed to fetch extended metadata from ${url} due to resource not found`
          );
        }

        throw new ProviderError(
          ProviderFailure.ConnectionFailure,
          error,
          `StakePoolMetadataService failed to fetch extended metadata from ${url} due to connection error`
        );
      }
      if (error instanceof ValidationError) {
        throw new ProviderError(
          ProviderFailure.InvalidResponse,
          error,
          'Extended metadata JSON format validation failed against the corresponding schema for correctness'
        );
      }
      throw error;
    }
  }
});
