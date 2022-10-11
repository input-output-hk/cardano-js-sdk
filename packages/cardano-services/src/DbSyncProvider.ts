import { HealthCheckResponse, Provider } from '@cardano-sdk/core';
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

    constructor(...args: AnyArgs) {
      const [db, ...baseArgs] = [...args];

      super(...baseArgs);

      this.db = db;
    }

    public async healthCheck(): Promise<HealthCheckResponse> {
      const result = await this.db.query(HEALTH_CHECK_QUERY);
      return { ok: !!result.rowCount };
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
  type ReturnedType = BaseInstance & { db: Pool; healthCheck: () => Promise<HealthCheckResponse> };

  return Mixin as unknown as (T extends new (...baseArgs: AnyArgs) => {}
    ? new (db: Pool, ...args: BaseArgs) => ReturnedType
    : abstract new (db: Pool, ...args: BaseArgs) => ReturnedType) & {
    prototype: { healthCheck: () => Promise<HealthCheckResponse> };
  };
};

export type DbSyncProvider<T> = T extends new (...args: AnyArgs) => infer O ? O : never;
