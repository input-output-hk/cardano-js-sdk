import { TypeOrmHandleProvider, createDnsResolver, getConnectionConfig, getEntities } from '../../src';
import { logger } from '@cardano-sdk/util-dev';

describe('TypeOrmHandleProvider', () => {
  let provider: TypeOrmHandleProvider;

  beforeAll(async () => {
    const dnsResolver = createDnsResolver({ factor: 1.1, maxRetryTime: 1000 }, logger);
    const entities = getEntities(['handle']);
    const connectionConfig$ = getConnectionConfig(dnsResolver, 'test', 'Handle', {
      postgresConnectionStringHandle: process.env.POSTGRES_CONNECTION_STRING_STAKE_POOL!
    });

    provider = new TypeOrmHandleProvider({ connectionConfig$, entities, logger });

    await provider.initialize();
    await provider.start();
  });

  afterAll(async () => {
    jest.restoreAllMocks();

    await provider.shutdown();
  });

  it('throws error if requested resolution for an empty string handle', () =>
    expect(provider.resolveHandles({ handles: ['none', '', 'test'] })).rejects.toThrow(
      "BAD_REQUEST (Empty string handle can't be resolved)"
    ));

  it.skip('resolve method correctly resolves handles', () =>
    // TODO: complete this test with mock or fixtures
    expect(provider.resolveHandles({ handles: ['none', 'test'] })).resolves.toBe([null, {}]));
});
