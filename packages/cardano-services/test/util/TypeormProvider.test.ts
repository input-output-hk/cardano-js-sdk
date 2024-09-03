import { NoCache, getEntities } from '../../src';
import { PgConnectionConfig } from '@cardano-sdk/projection-typeorm';
import { TimeoutError, of } from 'rxjs';
import { TypeormProvider } from '../../src/util';
import { logger } from '@cardano-sdk/util-dev';

class TestProvider extends TypeormProvider {}

jest.mock('../../src/util/createTypeormDataSource', () => ({
  createTypeormDataSource: jest.fn().mockImplementation(() => {
    let called = 0;

    return of({
      query: () => {
        called++;

        if (called === 6) throw new TimeoutError();
        if (called % 2 === 0) return Promise.reject(0);

        return Promise.resolve(0);
      }
    });
  })
}));

describe('TypeormProvider', () => {
  const notUsedConnectionConfig = {} as PgConnectionConfig;
  const connectionConfig$ = of(notUsedConnectionConfig);
  const entities = getEntities(['currentPoolMetrics', 'poolMetadata', 'poolDelisted']);
  const provider = new TestProvider('test', { connectionConfig$, entities, healthCheckCache: new NoCache(), logger });

  beforeAll(async () => {
    await provider.initialize();
    await provider.start();
  });

  afterAll(() => provider.shutdown());

  test('healthCheck', async () => {
    // The mock creates a dataSource which resolves, next rejects, next the TypeormProvider create a new dataSource
    expect((await provider.healthCheck()).ok).toBeTruthy();
    expect((await provider.healthCheck()).ok).toBeFalsy();
    expect((await provider.healthCheck()).ok).toBeTruthy();
    expect((await provider.healthCheck()).ok).toBeFalsy();
    expect((await provider.healthCheck()).ok).toBeTruthy();
    expect((await provider.healthCheck()).ok).toBeFalsy();
  });
});
