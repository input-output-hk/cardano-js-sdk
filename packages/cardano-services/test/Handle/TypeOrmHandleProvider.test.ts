import { TypeOrmHandleProvider, createDnsResolver, getConnectionConfig, getEntities } from '../../src/index.js';
import { createHandleFixtures } from './fixtures.js';
import { logger } from '@cardano-sdk/util-dev';
import type { HandleFixtures } from './fixtures.js';

describe('TypeOrmHandleProvider', () => {
  let provider: TypeOrmHandleProvider;
  let fixtures: HandleFixtures;

  beforeAll(async () => {
    const dnsResolver = createDnsResolver({ factor: 1.1, maxRetryTime: 1000 }, logger);
    const entities = getEntities(['handle', 'handleMetadata']);
    const connectionConfig$ = getConnectionConfig(dnsResolver, 'test', 'Handle', {
      postgresConnectionStringHandle: process.env.POSTGRES_CONNECTION_STRING_HANDLE!
    });

    fixtures = await createHandleFixtures(connectionConfig$);
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

  describe('resolveHandles', () => {
    it('correctly resolves cip25 handles', async () => {
      const result = await provider.resolveHandles({ handles: ['none', fixtures.cip25Handle] });

      expect(result.length).toBe(2);
      expect(result[0]).toBeNull();

      const resolution = result[1]!;
      expect(resolution.handle).toEqual(fixtures.cip25Handle);
      expect(typeof resolution.hasDatum).toBe('boolean');
      expect(typeof resolution.cardanoAddress).toBe('string');
      expect(typeof resolution.defaultForPaymentCredential).toBe('string');
      expect(typeof resolution.defaultForStakeCredential).toBe('string');
      expect(typeof resolution.image).toBe('string');
      expect(typeof resolution.policyId).toBe('string');
      expect(typeof resolution.resolvedAt).toBe('object');
      expect(resolution?.profilePic).toBeUndefined();
      expect(resolution?.backgroundImage).toBeUndefined();
    });

    // This might start failing after LW-8327 is done and db snapshot is regenerated,
    // because packages/cardano-services/test/jest-setup/mint-handles.js sends reference
    // token to the same wallet, which can then potentially be used by input selection and spent,
    // deleting or invalidating corresponding HandleMetadata from the database
    it('correctly resolves bg and pfp images of cip68 handles', async () => {
      const [resolution] = await provider.resolveHandles({ handles: [fixtures.handleWithProfileAndBackgroundPics] });
      expect(typeof resolution?.profilePic).toBe('string');
      expect(typeof resolution?.backgroundImage).toBe('string');
    });
  });

  describe('resolve sub-handles', () => {
    it('fetches parent handle of virtual subhandle', async () => {
      const resolution = await provider.resolveHandles({ handles: ['virtual@handl'] });
      expect(resolution[0]?.parentHandle).toBe('handl');
      expect(resolution[0]?.cardanoAddress?.startsWith('addr')).toBe(true);
    });
    it('fetches parent handle of NFT subhandle', async () => {
      const resolution = await provider.resolveHandles({ handles: ['sub@handl'] });
      expect(resolution[0]?.parentHandle).toBe('handl');
      expect(resolution[0]?.cardanoAddress?.startsWith('addr')).toBe(true);
    });
  });

  // Test data is sourced from the test database snapshot
  // packages/cardano-services/test/jest-setup/snapshots/handle.sql
  it('fetches all distinct policy ids', async () => {
    const result = await provider.getPolicyIds();
    expect(result.length).toBeGreaterThan(0);
    expect(typeof result[0]).toBe('string');
    expect(result[0]).toHaveLength(56);
  });
});
