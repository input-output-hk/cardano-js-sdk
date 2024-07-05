import { HealthCheckResponse, Provider } from '@cardano-sdk/core';
import { Logger } from 'ts-log';
import { Observable, skip } from 'rxjs';
import { PgConnectionConfig } from '@cardano-sdk/projection-typeorm';
import { TypeormService } from '../TypeormService';

export interface TypeormProviderDependencies {
  logger: Logger;
  entities: Function[];
  connectionConfig$: Observable<PgConnectionConfig>;
}

const unhealthy = { ok: false, reason: 'Provider error' };

export abstract class TypeormProvider extends TypeormService implements Provider {
  health: HealthCheckResponse = { ok: false, reason: 'not started' };

  constructor(name: string, { connectionConfig$, logger, entities }: TypeormProviderDependencies) {
    super(name, { connectionConfig$, entities, logger });
    // We skip 1 to omit the initial null value of the subject
    this.dataSource$.pipe(skip(1)).subscribe((dataSource) => {
      this.health = dataSource ? { ok: true } : unhealthy;
    });
  }

  async healthCheck(): Promise<HealthCheckResponse> {
    if (this.state === 'running')
      try {
        await this.withDataSource((dataSource) => dataSource.query('SELECT 1'));
      } catch {
        return unhealthy;
      }

    return this.health;
  }
}
