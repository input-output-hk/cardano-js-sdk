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
