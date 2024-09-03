import { HealthCheckResponse, Milliseconds, Provider } from '@cardano-sdk/core';
import { InMemoryCache } from '../../InMemoryCache';
import { TypeormService, TypeormServiceDependencies } from '../TypeormService';
import { skip } from 'rxjs';

export type TypeormProviderDependencies = Omit<TypeormServiceDependencies, 'connectionTimeout'> & {
  healthCheckCache: InMemoryCache;
};

const unhealthy = { ok: false, reason: 'Provider error' };

export abstract class TypeormProvider extends TypeormService implements Provider {
  health: HealthCheckResponse = { ok: false, reason: 'not started' };
  healthCheckCache: InMemoryCache;

  constructor(name: string, dependencies: TypeormProviderDependencies) {
    super(name, { ...dependencies, connectionTimeout: Milliseconds(1000) });
    // We skip 1 to omit the initial null value of the subject
    this.dataSource$.pipe(skip(1)).subscribe((dataSource) => {
      this.health = dataSource ? { ok: true } : unhealthy;
    });

    this.healthCheckCache = dependencies.healthCheckCache;
  }

  async healthCheck(): Promise<HealthCheckResponse> {
    if (this.state === 'running')
      try {
        await this.healthCheckCache.get(`typeorm_db_${this.name}`, () =>
          this.withDataSource((dataSource) => dataSource.query('SELECT 1'))
        );
      } catch {
        return unhealthy;
      }

    return this.health;
  }
}
