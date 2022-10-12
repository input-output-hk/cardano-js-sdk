import { CardanoNode, HealthCheckResponse, Provider } from '@cardano-sdk/core';
import { Pool } from 'pg';

const HEALTH_CHECK_QUERY = 'SELECT 1';
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
      // TODO: query block table, get last block minus 5
      const dbHealthCheck = { ok: !!(await this.db.query(HEALTH_CHECK_QUERY)).rowCount };
      const cardanoNodeHealthCheck = await this.cardanoNode.healthCheck();
      return {
        localNode: cardanoNodeHealthCheck.localNode ?? undefined,
        ok: dbHealthCheck.ok && cardanoNodeHealthCheck.ok
      };
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
