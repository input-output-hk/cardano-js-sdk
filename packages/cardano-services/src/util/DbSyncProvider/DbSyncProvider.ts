import { Cardano, CardanoNode, HealthCheckResponse, Provider, ProviderError, ProviderFailure } from '@cardano-sdk/core';
import { DB_BLOCKS_BEHIND_TOLERANCE, DB_MAX_SAFE_INTEGER, LedgerTipModel, findLedgerTip } from './util';
import { Pool } from 'pg';

// eslint-disable-next-line @typescript-eslint/no-explicit-any
type AnyArgs = any[];
export const DbSyncProvider = <
  T extends (abstract new (...args: AnyArgs) => {}) | (new (...args: AnyArgs) => {}) = { new (): {} }
>(
  BaseClass?: T
) => {
  abstract class Mixin extends (BaseClass || Object) implements Provider {
    public db: Pool;
    public cardanoNode: CardanoNode;

    constructor(...args: AnyArgs) {
      const [db, cardanoNode, ...baseArgs] = [...args];

      super(...baseArgs);

      this.db = db;
      this.cardanoNode = cardanoNode;
    }

    public async healthCheck(): Promise<HealthCheckResponse> {
      try {
        const { ok, localNode } = await this.cardanoNode.healthCheck();
        const tip = (await this.db.query<LedgerTipModel>(findLedgerTip)).rows[0];
        const isHealthy =
          ok && tip.block_no >= (localNode?.ledgerTip?.blockNo ?? DB_MAX_SAFE_INTEGER) - DB_BLOCKS_BEHIND_TOLERANCE;

        const projectedTip: Cardano.Tip = {
          blockNo: Cardano.BlockNo(tip.block_no),
          hash: Cardano.BlockId(tip.hash.toString('hex')),
          slot: Cardano.Slot(Number(tip.slot_no))
        };

        return {
          localNode,
          ok: isHealthy,
          projectedTip
        };
      } catch (error) {
        throw new ProviderError(
          ProviderFailure.ConnectionFailure,
          error,
          'Failed to perform health check against dependencies'
        );
      }
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
    db: Pool;
    cardanoNode: CardanoNode;
    healthCheck: () => Promise<HealthCheckResponse>;
  };

  return Mixin as unknown as (T extends new (...baseArgs: AnyArgs) => {}
    ? new (db: Pool, cardanoNode: CardanoNode, ...args: BaseArgs) => ReturnedType
    : abstract new (db: Pool, cardanoNode: CardanoNode, ...args: BaseArgs) => ReturnedType) & {
    prototype: { healthCheck: () => Promise<HealthCheckResponse> };
  };
};
