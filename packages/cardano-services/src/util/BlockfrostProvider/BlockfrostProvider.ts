import { BlockFrostAPI } from '@blockfrost/blockfrost-js';
import { HealthCheckResponse, Provider, ProviderDependencies } from '@cardano-sdk/core';
import { blockfrostToProviderError } from './blockfrostUtil';
import type { Logger } from 'ts-log';

/** Properties that are need to create a BlockfrostProvider */
export interface BlockfrostProviderDependencies extends ProviderDependencies {
  blockfrost: BlockFrostAPI;
  logger: Logger;
}

export abstract class BlockfrostProvider implements Provider {
  protected blockfrost: BlockFrostAPI;
  protected logger: Logger;

  public constructor({ logger, blockfrost }: BlockfrostProviderDependencies) {
    this.blockfrost = blockfrost;
    this.logger = logger;
  }

  async healthCheck(): Promise<HealthCheckResponse> {
    try {
      const result = await this.blockfrost.health();
      return { ok: result.is_healthy };
    } catch (error) {
      throw blockfrostToProviderError(error);
    }
  }
}
