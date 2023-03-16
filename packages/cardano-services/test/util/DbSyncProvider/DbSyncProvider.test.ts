import { Connection, createConnectionObject } from '@cardano-ogmios/client';
import { DbSyncProvider, DbSyncProviderDependencies } from '../../../src/util';
import { HEALTH_RESPONSE_BODY } from '../../../../ogmios/test/mocks/util';
import { OgmiosCardanoNode } from '@cardano-sdk/ogmios';
import { Pool, QueryResult } from 'pg';
import { Provider } from '@cardano-sdk/core';
import {
  createMockOgmiosServer,
  listenPromise,
  serverClosePromise
} from '../../../../ogmios/test/mocks/mockOgmiosServer';
import { getRandomPort } from 'get-port-please';
import { dummyLogger as logger } from 'ts-log';
import http from 'http';

const someError = new Error('Some error');

const healthyMockOgmios = () =>
  createMockOgmiosServer({
    healthCheck: { response: { success: true } }
  });

const unhealthyMockOgmios = () =>
  createMockOgmiosServer({
    healthCheck: {
      response: {
        failWith: someError,
        success: false
      }
    }
  });

export interface SomeProvider extends Provider {
  getData: () => Promise<QueryResult>;
}

class DbSyncSomeProvider extends DbSyncProvider() implements SomeProvider {
  constructor(dependencies: DbSyncProviderDependencies) {
    super(dependencies);
  }

  async getData() {
    return this.db.query('SELECT * from a');
  }
}

jest.mock('pg', () => ({
  Pool: jest.fn(() => ({
    connect: jest.fn(),
    end: jest.fn(),
    query: jest.fn()
  }))
}));

describe('DbSyncProvider', () => {
  describe('healthCheck', () => {
    let cardanoNode: OgmiosCardanoNode;
    let connection: Connection;
    let mockServer: http.Server;
    let db: Pool;
    let provider: DbSyncSomeProvider;

    beforeEach(async () => {
      connection = createConnectionObject({ port: await getRandomPort() });
      db = new Pool();
    });

    afterEach(async () => {
      await serverClosePromise(mockServer);
      jest.clearAllMocks();
    });

    describe('healthy database', () => {
      beforeEach(async () => {
        // Mock the database query with the same tip as the Ogmios mock,
        // to ensure the sync percentage is 100
        (db.query as jest.Mock).mockResolvedValue({
          rows: [
            {
              block_no: HEALTH_RESPONSE_BODY.lastKnownTip.blockNo,
              hash: HEALTH_RESPONSE_BODY.lastKnownTip.hash,
              slot_no: HEALTH_RESPONSE_BODY.lastKnownTip.slot.toString()
            }
          ]
        });
        cardanoNode = new OgmiosCardanoNode(connection, logger);
      });

      it('is ok when node is healthy', async () => {
        mockServer = healthyMockOgmios();
        await listenPromise(mockServer, connection.port);
        provider = new DbSyncSomeProvider({ cardanoNode, db, logger });
        const res = await provider.healthCheck();
        expect(res.ok).toEqual(true);
        expect(res.localNode).toBeDefined();
        expect(res.projectedTip).toBeDefined();
      });

      it('is not ok when node is unhealthy', async () => {
        mockServer = unhealthyMockOgmios();
        await listenPromise(mockServer, connection.port);
        cardanoNode = new OgmiosCardanoNode(connection, logger);
        provider = new DbSyncSomeProvider({ cardanoNode, db, logger });
        const res = await provider.healthCheck();
        expect(res.ok).toEqual(false);
        expect(res.localNode).toBeUndefined();
        expect(res.projectedTip).toBeDefined();
      });
    });

    describe('unhealthy database', () => {
      beforeEach(async () => {
        (db.query as jest.Mock).mockRejectedValue(someError);
      });

      it('is not ok when the node is healthy', async () => {
        mockServer = healthyMockOgmios();
        await listenPromise(mockServer, connection.port);
        cardanoNode = new OgmiosCardanoNode(connection, logger);
        provider = new DbSyncSomeProvider({ cardanoNode, db, logger });
        const res = await provider.healthCheck();
        expect(res.ok).toEqual(false);
        expect(res.localNode).toBeDefined();
        expect(res.projectedTip).toBeUndefined();
      });

      it('is not ok when the node is unhealthy', async () => {
        mockServer = unhealthyMockOgmios();
        await listenPromise(mockServer, connection.port);
        cardanoNode = new OgmiosCardanoNode(connection, logger);
        provider = new DbSyncSomeProvider({ cardanoNode, db, logger });
        const res = await provider.healthCheck();
        expect(res.ok).toEqual(false);
        expect(res.localNode).toBeUndefined();
        expect(res.projectedTip).toBeUndefined();
      });
    });
  });
});
