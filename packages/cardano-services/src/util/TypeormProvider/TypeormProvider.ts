import { TypeormService } from '../TypeormService/index.js';
import { skip } from 'rxjs';
import type { HealthCheckResponse, Provider } from '@cardano-sdk/core';
import type { Logger } from 'ts-log';
import type { Observable } from 'rxjs';
import type { PgConnectionConfig } from '@cardano-sdk/projection-typeorm';

export interface TypeormProviderDependencies {
  logger: Logger;
  entities: Function[];
  connectionConfig$: Observable<PgConnectionConfig>;
}

export abstract class TypeormProvider extends TypeormService implements Provider {
  health: HealthCheckResponse = { ok: false, reason: 'not started' };

  constructor(name: string, { connectionConfig$, logger, entities }: TypeormProviderDependencies) {
    super(name, { connectionConfig$, entities, logger });
    // We skip 1 to omit the initial null value of the subject
    this.dataSource$.pipe(skip(1)).subscribe((dataSource) => {
      this.health = dataSource ? { ok: true } : { ok: false, reason: 'Provider error' };
    });
  }

  async healthCheck(): Promise<HealthCheckResponse> {
    return this.health;
  }
}
