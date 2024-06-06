import { BlockFrostAPI } from '@blockfrost/blockfrost-js';
import { BlockfrostCacheBuilder } from './builder.js';
import { Cardano } from '@cardano-sdk/core';
import { HttpService } from '../Http/index.js';
import { Router } from 'express';
import { setPoolMetric } from './queries.js';
import type { AvailableNetworks } from '../Program/programs/blockfrostWorker.js';
import type { Logger } from 'ts-log';
import type { Pool } from 'pg';
import type { Provider } from '@cardano-sdk/core';

type BlockfrostMetrics = Awaited<ReturnType<BlockFrostAPI['poolsById']>>;

export interface BlockfrostServiceConfig {
  blockfrostApiKey: string;
  cacheTtl: number;
  network: AvailableNetworks;
}

export interface BlockfrostServiceDependencies {
  db: Pool;
  logger: Logger;
}

export class BlockfrostService extends HttpService {
  #api: BlockFrostAPI;
  #builder: BlockfrostCacheBuilder;
  #cacheTtl: number;
  #db: Pool;
  #shuttingDown?: boolean;

  constructor(cfg: BlockfrostServiceConfig, deps: BlockfrostServiceDependencies) {
    const { blockfrostApiKey, cacheTtl, network } = cfg;
    const { db, logger } = deps;
    const provider: Provider = { healthCheck: () => Promise.resolve({ ok: false }) };

    super('blockfrost-cache', provider, Router(), __dirname, logger);

    this.#api = new BlockFrostAPI({ network, projectId: blockfrostApiKey });
    this.#builder = new BlockfrostCacheBuilder(db, this.logger);
    this.#cacheTtl = cacheTtl;
    this.#db = db;

    provider.healthCheck = async () => {
      try {
        await db.query('SELECT 1');
        await this.#api.pools();
      } catch (error) {
        this.logger.error(error);

        return { ok: false };
      }

      return { ok: true };
    };
  }

  protected initializeImpl() {
    return Promise.resolve();
  }

  protected startImpl() {
    return Promise.resolve();
  }

  protected shutdownImpl() {
    this.#shuttingDown = true;

    return Promise.resolve();
  }

  public async refreshCache() {
    const [pools, currentEpoch] = await Promise.all([
      this.#builder.getPools(this.#cacheTtl),
      this.#builder.getCurrentEpoch()
    ]);

    for (const { id, view } of pools) {
      if (this.#shuttingDown) return;

      this.logger.debug(`Going to fetch data from Blockfrost for pool ${view}`);
      const metrics = await this.#api.poolsById(view);

      const lastRetire = await this.#builder.getLastRetire(id);
      const firstUpdate = await this.#builder.getFirstUpdateAfterBlock(id, lastRetire ? lastRetire.block_no : 0);
      const status = firstUpdate
        ? firstUpdate.epoch_no <= currentEpoch
          ? Cardano.StakePoolStatus.Active
          : Cardano.StakePoolStatus.Activating
        : lastRetire!.retiring_epoch <= currentEpoch
        ? Cardano.StakePoolStatus.Retired
        : Cardano.StakePoolStatus.Retiring;

      this.logger.debug(`Going to write Blockfrost cache data for pool ${view}`);
      await this.writeCache(id, metrics, status);
    }
  }

  private async writeCache(id: string, metrics: BlockfrostMetrics, status: Cardano.StakePoolStatus) {
    const client = await this.#db.connect();

    try {
      await client.query('BEGIN');

      try {
        await client.query(setPoolMetric, [
          id,
          0,
          Date.now(),
          metrics.blocks_minted,
          metrics.live_delegators,
          metrics.active_stake,
          metrics.live_stake,
          metrics.live_pledge,
          metrics.live_saturation,
          metrics.reward_account,
          JSON.stringify([metrics.owners, metrics.registration.reverse(), metrics.retirement]),
          status
        ]);

        await client.query('COMMIT');
      } catch (error) {
        this.logger.error(error);
        await client.query('ROLLBACK');
      }
    } catch (error) {
      this.logger.error(error);
    }

    client.release();
  }
}
