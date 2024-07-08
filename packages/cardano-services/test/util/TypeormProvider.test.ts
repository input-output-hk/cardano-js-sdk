import { PgConnectionConfig } from '@cardano-sdk/projection-typeorm';
import { TypeormProvider } from '../../src/util';
import { getEntities } from '../../src';
import { logger } from '@cardano-sdk/util-dev';
import { of } from 'rxjs';

class TestProvider extends TypeormProvider {}

jest.mock('../../src/util/createTypeormDataSource', () => ({
  createTypeormDataSource: jest.fn().mockImplementation(() => {
    let called = false;

    return of({
      query: () => {
        if (called) return Promise.reject(0);

        called = true;
        return Promise.resolve(0);
      }
    });
  })
}));

describe('TypeormProvider', () => {
  const notUsedConnectionConfig = {} as PgConnectionConfig;
  const connectionConfig$ = of(notUsedConnectionConfig);
  const entities = getEntities(['currentPoolMetrics', 'poolMetadata', 'poolDelisted']);
  const provider = new TestProvider('test', { connectionConfig$, entities, logger });

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
  });
});
