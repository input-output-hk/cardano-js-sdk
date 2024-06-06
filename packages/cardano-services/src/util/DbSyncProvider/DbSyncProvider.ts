import { Cardano } from '@cardano-sdk/core';
import { findLedgerTip } from './util.js';
import type { CardanoNode, HealthCheckResponse, Provider, ProviderDependencies } from '@cardano-sdk/core';
import type { InMemoryCache } from '../../InMemoryCache/index.js';
import type { LedgerTipModel } from './util.js';
import type { Logger } from 'ts-log';
import type { Pool } from 'pg';

/** Dedicated DB pools */
export interface DbPools {
  /** Main operational db pool */
  main: Pool;
  /** Secondary health check db pool */
  healthCheck: Pool;
}

/** Properties that are need to create DbSyncProvider */
export interface DbSyncProviderDependencies extends ProviderDependencies {
  /** Cache engines. Default: InMemoryCache with HealthCheck.cacheTTL as default TTL */
  cache: {
    healthCheck: InMemoryCache;
  };
  /** DB pools */
  dbPools: DbPools;
  /** Ogmios Cardano Node provider */
  cardanoNode: CardanoNode;
}

// eslint-disable-next-line @typescript-eslint/no-explicit-any
type AnyArgs = any[];

export const findLedgerTipOptions = { name: 'find_ledger_tip', text: findLedgerTip } as const;

export const DbSyncProvider = <
  T extends (abstract new (...args: AnyArgs) => {}) | (new (...args: AnyArgs) => {}) = { new (): {} }
>(
  BaseClass?: T
) => {
  abstract class Mixin extends (BaseClass || Object) implements Provider {
    public dbPools: DbPools;
    public cardanoNode: CardanoNode;
    public logger: Logger;
    #cache: {
      healthCheck: InMemoryCache;
    };

    constructor(...args: AnyArgs) {
      const [dependencies, ...baseArgs] = [...args] as [DbSyncProviderDependencies, ...AnyArgs];
      const { cache, dbPools, cardanoNode, logger } = dependencies;
      super(...baseArgs);

      this.dbPools = dbPools;
      this.cardanoNode = cardanoNode;
      this.logger = logger;
      this.#cache = cache;
    }

    /** Healthy if the tip of both the node and database can be accessed. */
    public async healthCheck(): Promise<HealthCheckResponse> {
      const response: HealthCheckResponse = { ok: false };
      try {
        const cardanoNode = await this.#cache.healthCheck.get('node_health', async () =>
          this.cardanoNode.healthCheck()
        );
        response.localNode = cardanoNode.localNode;
        const tip = await this.#cache.healthCheck.get(
          'db_tip',
          async () => (await this.dbPools.healthCheck.query<LedgerTipModel>(findLedgerTipOptions)).rows[0]
        );

        if (tip) {
          response.projectedTip = {
            blockNo: Cardano.BlockNo(tip.block_no),
            hash: tip.hash.toString('hex') as unknown as Cardano.BlockId,
            slot: Cardano.Slot(Number(tip.slot_no))
          };
          response.ok = cardanoNode.ok && !!tip?.block_no;

          this.logger.debug(
            `Service /health: projected block tip: ${tip.block_no},local node block tip: ${cardanoNode.localNode?.ledgerTip?.blockNo}.`
          );
        }
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
      } catch (error: any) {
        this.logger.error(error.message);
      }
      return response;
    }
  }

  type BaseArgs = T extends abstract new (...baseArgs: infer A) => {}
    ? A
    : T extends new (...baseArgs: infer A) => {}
    ? A
    : never;
  type BaseInstance = T extends abstract new (...baseArgs: AnyArgs) => infer I
    ? I
    : T extends new (...baseArgs: AnyArgs) => infer I
    ? I
    : never;
  type ReturnedType = BaseInstance & {
    dbPools: DbPools;
    cardanoNode: CardanoNode;
    logger: Logger;
    healthCheck: () => Promise<HealthCheckResponse>;
  };

  return Mixin as unknown as (T extends new (...baseArgs: AnyArgs) => {}
    ? new (dependencies: DbSyncProviderDependencies, ...args: BaseArgs) => ReturnedType
    : abstract new (dependencies: DbSyncProviderDependencies, ...args: BaseArgs) => ReturnedType) & {
    prototype: { healthCheck: () => Promise<HealthCheckResponse> };
  };
};
