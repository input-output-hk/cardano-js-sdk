// TODO: remove this and refactor
/* eslint-disable sonarjs/no-identical-functions */
/* eslint-disable sonarjs/no-duplicate-string */
import { Connection, InteractionContext, createConnectionObject } from '@cardano-ogmios/client';
import {
  GeneralCardanoNodeError,
  GeneralCardanoNodeErrorCode,
  StateQueryError,
  StateQueryErrorCode
} from '@cardano-sdk/core';
import { HEALTH_RESPONSE_BODY } from '../mocks/util';
import { InvalidModuleState } from '@cardano-sdk/util';
import {
  MockCreateInteractionContext,
  MockCreateLedgerStateQuery,
  MockGetServerHealth,
  MockedLedgerStateQueryClient,
  ogmiosEraSummaries
} from './util';
import { OgmiosCardanoNode } from '../../src';
import { dummyLogger as logger } from 'ts-log';
import { mockGenesisShelley } from '../ogmiosToCore/testData';

jest.mock('@cardano-ogmios/client', () => {
  const original = jest.requireActual('@cardano-ogmios/client');
  return {
    ...original,
    createInteractionContext: jest.fn(),
    createLedgerStateQueryClient: jest.fn(),
    getServerHealth: jest.fn()
  };
});

describe('OgmiosCardanoNode', () => {
  let connection: Connection;
  let node: OgmiosCardanoNode;
  let createLedgerStateQueryClient: MockCreateLedgerStateQuery;
  let ledgerStateQueryClient: MockedLedgerStateQueryClient;
  let getServerHealth: MockGetServerHealth;
  let createInteractionContext: MockCreateInteractionContext;

  beforeEach(async () => {
    connection = createConnectionObject();
    ({ createInteractionContext, createLedgerStateQueryClient, getServerHealth } = require('@cardano-ogmios/client'));
    ledgerStateQueryClient = {
      eraSummaries: jest.fn() as MockedLedgerStateQueryClient['eraSummaries'],
      genesisConfiguration: jest.fn() as MockedLedgerStateQueryClient['genesisConfiguration'],
      liveStakeDistribution: jest.fn() as MockedLedgerStateQueryClient['liveStakeDistribution'],
      networkStartTime: jest.fn() as MockedLedgerStateQueryClient['networkStartTime'],
      shutdown: jest.fn() as MockedLedgerStateQueryClient['shutdown']
    } as MockedLedgerStateQueryClient;
    createLedgerStateQueryClient.mockResolvedValue(ledgerStateQueryClient);
    ledgerStateQueryClient.eraSummaries.mockResolvedValue(ogmiosEraSummaries);
    ledgerStateQueryClient.liveStakeDistribution.mockResolvedValue({
      pool1cjm567pd9eqj7wlpuq2mnsasw2upewq0tchg4n8gktq5k7eepvr: {
        stake: '1/100',
        vrf: 'vrf'
      }
    });
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    ledgerStateQueryClient.genesisConfiguration.mockResolvedValue(mockGenesisShelley as any);
    createInteractionContext.mockResolvedValue({ connection } as InteractionContext);
    getServerHealth.mockResolvedValue(HEALTH_RESPONSE_BODY);
  });
  afterEach(async () => {
    createInteractionContext.mockReset();
    createLedgerStateQueryClient.mockReset();
    getServerHealth.mockReset();
  });
  describe('not initialized and started', () => {
    beforeEach(async () => {
      node = new OgmiosCardanoNode(connection, logger);
    });

    it('eraSummaries rejects with not initialized error', async () => {
      await expect(node.eraSummaries()).rejects.toThrowError(GeneralCardanoNodeError);
    });
    it('systemStart rejects with not initialized error', async () => {
      await expect(node.systemStart()).rejects.toThrowError(GeneralCardanoNodeError);
    });
    it('stakeDistribution rejects with not initialized error', async () => {
      await expect(node.stakeDistribution()).rejects.toThrowError(GeneralCardanoNodeError);
    });
    it('shutdown rejects with not initialized error', async () => {
      await expect(node.shutdown()).rejects.toThrowError(InvalidModuleState);
    });
  });
  describe('initialized and started', () => {
    describe('eraSummaries', () => {
      describe('success', () => {
        beforeEach(async () => {
          ledgerStateQueryClient.eraSummaries.mockResolvedValue(ogmiosEraSummaries);
          node = new OgmiosCardanoNode(connection, logger);
          await node.initialize();
          await node.start();
        });
        afterEach(async () => {
          await node.shutdown();
        });
        it('resolves if successful', async () => {
          const res = await node.eraSummaries();
          expect(res).toMatchSnapshot();
        });
      });
      describe('failure', () => {
        beforeEach(async () => {
          ledgerStateQueryClient.eraSummaries.mockRejectedValue(
            new StateQueryError(StateQueryErrorCode.UnavailableInCurrentEra, null, 'Some error')
          );
          node = new OgmiosCardanoNode(connection, logger);
          await node.initialize();
          await node.start();
        });
        afterEach(async () => {
          await node.shutdown();
        });

        it('rejects with errors thrown by the service', async () => {
          await expect(node.eraSummaries()).rejects.toThrowError(StateQueryError);
        });
      });
    });
    describe('systemStart', () => {
      const startTime = new Date();

      describe('success', () => {
        beforeEach(async () => {
          ledgerStateQueryClient.networkStartTime.mockResolvedValue(startTime);
          node = new OgmiosCardanoNode(connection, logger);
          await node.initialize();
          await node.start();
        });
        afterEach(async () => {
          await node.shutdown();
        });
        it('resolves if successful', async () => {
          const res = await node.systemStart();
          expect(res).toEqual(startTime);
        });
      });
      describe('failure', () => {
        beforeEach(async () => {
          ledgerStateQueryClient.networkStartTime.mockRejectedValue(
            new StateQueryError(StateQueryErrorCode.UnavailableInCurrentEra, null, 'Some error')
          );
          node = new OgmiosCardanoNode(connection, logger);
          await node.initialize();
          await node.start();
        });
        afterEach(async () => {
          await node.shutdown();
        });

        it('rejects with errors thrown by the service', async () => {
          await expect(node.systemStart()).rejects.toThrowError(StateQueryError);
        });
      });
    });
    describe('healthCheck', () => {
      describe('success', () => {
        beforeEach(async () => {
          node = new OgmiosCardanoNode(connection, logger);
          await node.initialize();
          await node.start();
        });
        afterEach(async () => {
          await node.shutdown();
        });
        it('returns ok if successful', async () => {
          const res = await node.healthCheck();
          expect(res.ok).toBe(true);
        });
      });
      describe('failure', () => {
        beforeEach(async () => {
          getServerHealth.mockRejectedValue(
            new GeneralCardanoNodeError(GeneralCardanoNodeErrorCode.ServerNotReady, null, 'Not ready')
          );
          node = new OgmiosCardanoNode(connection, logger);
          await node.initialize();
          await node.start();
        });
        afterEach(async () => {
          await node.shutdown();
        });

        it('returns not ok if the Ogmios server throws an error', async () => {
          const res = await node.healthCheck();
          expect(res.ok).toBe(false);
        });
      });
    });
    describe('stakeDistribution', () => {
      describe('success', () => {
        beforeEach(async () => {
          node = new OgmiosCardanoNode(connection, logger);
          await node.initialize();
          await node.start();
        });
        afterEach(async () => {
          await node.shutdown();
        });
        it('resolves if successful', async () => {
          const res = await node.stakeDistribution();
          expect(res).toMatchSnapshot();
        });
      });
      describe('failure', () => {
        beforeEach(async () => {
          ledgerStateQueryClient.liveStakeDistribution.mockRejectedValue(
            new StateQueryError(StateQueryErrorCode.UnavailableInCurrentEra, null, 'Some error')
          );
          node = new OgmiosCardanoNode(connection, logger);
          await node.initialize();
          await node.start();
        });
        afterEach(async () => {
          await node.shutdown();
        });

        it('rejects with errors thrown by the service', async () => {
          await expect(node.stakeDistribution()).rejects.toThrowError(StateQueryError);
        });
      });
    });
    describe('shutdown', () => {
      beforeEach(async () => {
        ledgerStateQueryClient.networkStartTime.mockResolvedValue(new Date());
        node = new OgmiosCardanoNode(connection, logger);
        await node.initialize();
        await node.start();
      });
      it('shuts down successfully', async () => {
        await expect(node.shutdown()).resolves.not.toThrow();
      });

      it('throws when querying after shutting down', async () => {
        await node.shutdown();
        await expect(node.systemStart()).rejects.toThrowError(GeneralCardanoNodeError);
      });
    });
  });
});
