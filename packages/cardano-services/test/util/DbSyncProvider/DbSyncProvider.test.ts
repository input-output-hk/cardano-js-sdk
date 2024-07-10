import { CardanoNode, HealthCheckResponse, Provider } from '@cardano-sdk/core';
import { DbPools, DbSyncProvider, DbSyncProviderDependencies } from '../../../src/util';
import { HEALTH_RESPONSE_BODY } from '../../../../ogmios/test/mocks/util';
import { InMemoryCache, UNLIMITED_CACHE_TTL } from '../../../src/InMemoryCache';
import { OgmiosCardanoNode, OgmiosObservableCardanoNode } from '@cardano-sdk/ogmios';
import { Pool, QueryResult } from 'pg';
import { dummyLogger as logger } from 'ts-log';

const someError = new Error('Some error');

export interface SomeProvider extends Provider {
  getData: () => Promise<QueryResult>;
}

class DbSyncSomeProvider extends DbSyncProvider() implements SomeProvider {
  constructor(dependencies: DbSyncProviderDependencies) {
    super(dependencies);
  }

  async getData() {
    return this.dbPools.main.query('SELECT * from a');
  }
}

jest.mock('pg', () => ({
  Pool: jest.fn(() => ({
    connect: jest.fn(),
    end: jest.fn(),
    query: jest.fn()
  }))
}));

let mockHealthResponse: HealthCheckResponse;
jest.mock('@cardano-sdk/ogmios', () => ({
  ...jest.requireActual('@cardano-sdk/ogmios'),
  OgmiosCardanoNode: jest.fn().mockImplementation(() => ({
    healthCheck: jest.fn((): ReturnType<CardanoNode['healthCheck']> => Promise.resolve(mockHealthResponse)),
    initialize: jest.fn().mockResolvedValue(true),
    shutdown: jest.fn().mockResolvedValue(true)
  }))
}));

describe('DbSyncProvider', () => {
  beforeEach(() => {
    mockHealthResponse = { localNode: {}, ok: true };
  });

  describe('healthCheck', () => {
    let cardanoNode: OgmiosCardanoNode;
    // const ogmiosUrl = new URL('http://dummy');
    let dbPools: DbPools;
    let provider: DbSyncSomeProvider;
    const cache = { db: new InMemoryCache(UNLIMITED_CACHE_TTL), healthCheck: new InMemoryCache(UNLIMITED_CACHE_TTL) };

    beforeEach(async () => {
      cache.db.clear();
      cache.healthCheck.clear();

      dbPools = {
        healthCheck: new Pool(),
        main: new Pool()
      };
    });

    afterEach(async () => {
      jest.clearAllMocks();
    });

    describe('healthy database', () => {
      beforeEach(async () => {
        // Mock the database query with the same tip as the Ogmios mock,
        // to ensure the sync percentage is 100
        (dbPools.healthCheck.query as jest.Mock).mockResolvedValue({
          rows: [
            {
              block_no: HEALTH_RESPONSE_BODY.lastKnownTip.height,
              hash: HEALTH_RESPONSE_BODY.lastKnownTip.id,
              slot_no: HEALTH_RESPONSE_BODY.lastKnownTip.slot.toString()
            }
          ]
        });
        cardanoNode = new OgmiosCardanoNode({} as unknown as OgmiosObservableCardanoNode, logger);
      });

      it('is ok when node is healthy', async () => {
        provider = new DbSyncSomeProvider({ cache, cardanoNode, dbPools, logger });
        const res = await provider.healthCheck();
        expect(res.ok).toEqual(true);
        expect(res.localNode).toBeDefined();
        expect(res.projectedTip).toBeDefined();
      });

      it('caches the node health and projected tip', async () => {
        const healthCheckCacheSetSpy = jest.spyOn(cache.healthCheck, 'set');
        provider = new DbSyncSomeProvider({ cache, cardanoNode, dbPools, logger });

        expect(cache.healthCheck.keys()).toEqual([]);
        const res1 = await provider.healthCheck();
        expect(res1.ok).toEqual(true);
        expect(healthCheckCacheSetSpy).toBeCalledTimes(2);
        expect(cache.healthCheck.keys()).toEqual(['node_health', 'db_tip']);

        healthCheckCacheSetSpy.mockClear();

        const res2 = await provider.healthCheck();
        expect(res2.ok).toEqual(true);
        expect(healthCheckCacheSetSpy).toBeCalledTimes(0);
        healthCheckCacheSetSpy.mockClear();
      });

      it('is not ok when node is unhealthy', async () => {
        mockHealthResponse = { ok: false };
        provider = new DbSyncSomeProvider({ cache, cardanoNode, dbPools, logger });
        const res = await provider.healthCheck();
        expect(res.ok).toEqual(false);
        expect(res.localNode).toBeUndefined();
        expect(res.projectedTip).toBeDefined();
      });
    });

    describe('unhealthy database', () => {
      beforeEach(async () => {
        (dbPools.healthCheck.query as jest.Mock).mockRejectedValue(someError);
      });

      it('is not ok when the node is healthy', async () => {
        provider = new DbSyncSomeProvider({ cache, cardanoNode, dbPools, logger });
        const res = await provider.healthCheck();
        expect(res.ok).toEqual(false);
        expect(res.localNode).toBeDefined();
        expect(res.projectedTip).toBeUndefined();
      });

      it('is not ok when the node is unhealthy', async () => {
        mockHealthResponse = { ok: false };
        provider = new DbSyncSomeProvider({ cache, cardanoNode, dbPools, logger });
        const res = await provider.healthCheck();
        expect(res.ok).toEqual(false);
        expect(res.localNode).toBeUndefined();
        expect(res.projectedTip).toBeUndefined();
      });
    });
  });
});
