import { HealthCheckResponse, Provider } from '@cardano-sdk/core';
import { Pool } from 'pg';

const HEALTH_CHECK_QUERY = 'SELECT 1';

export class DbSyncProvider implements Provider {
  public db: Pool;

  protected constructor(db: Pool) {
    this.db = db;
  }

  public async healthCheck(): Promise<HealthCheckResponse> {
    const result = await this.db.query(HEALTH_CHECK_QUERY);
    return { ok: !!result.rowCount };
  }
}
