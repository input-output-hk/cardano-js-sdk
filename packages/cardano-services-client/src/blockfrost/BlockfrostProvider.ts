import { BlockfrostClient, BlockfrostError } from './BlockfrostClient';
import { HealthCheckResponse, Provider, ProviderError, ProviderFailure } from '@cardano-sdk/core';
import { Logger } from 'ts-log';
import { contextLogger } from '@cardano-sdk/util';
import type { AsyncReturnType } from 'type-fest';
import type { BlockFrostAPI } from '@blockfrost/blockfrost-js';

const toProviderFailure = (status: number | undefined): ProviderFailure => {
  switch (status) {
    case 400:
      return ProviderFailure.BadRequest;
    case 403:
      return ProviderFailure.Forbidden;
    case 404:
      return ProviderFailure.NotFound;
    case 402:
    case 418:
    case 425:
    case 429:
      return ProviderFailure.ServerUnavailable;
    case 500:
      return ProviderFailure.Unhealthy;
    default:
      return ProviderFailure.Unknown;
  }
};

export abstract class BlockfrostProvider implements Provider {
  #logger: Logger;
  #client: BlockfrostClient;

  constructor(client: BlockfrostClient, logger: Logger) {
    this.#client = client;
    this.#logger = contextLogger(logger, this.constructor.name);
  }

  /**
   * @param endpoint e.g. 'blocks/latest'
   * @throws {ProviderError}
   */
  protected async request<T>(endpoint: string): Promise<T> {
    try {
      this.#logger.debug('request', endpoint);
      const response = await this.#client.request<T>(endpoint);
      this.#logger.debug('response', response);
      return response;
    } catch (error) {
      this.#logger.error('error', error);
      throw this.toProviderError(error);
    }
  }

  async healthCheck(): Promise<HealthCheckResponse> {
    try {
      const result = await this.#client.request<AsyncReturnType<BlockFrostAPI['health']>>('health');
      return { ok: result.is_healthy };
    } catch (error) {
      return { ok: false, reason: this.toProviderError(error).message };
    }
  }

  protected toProviderError(error: unknown): ProviderError {
    if (error instanceof BlockfrostError) {
      return new ProviderError(toProviderFailure(error.status), error);
    }
    return new ProviderError(ProviderFailure.Unknown, error);
  }
}
