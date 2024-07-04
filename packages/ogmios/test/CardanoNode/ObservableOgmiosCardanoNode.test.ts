/* eslint-disable @typescript-eslint/no-explicit-any */
import {
  Cardano,
  GeneralCardanoNodeError,
  GeneralCardanoNodeErrorCode,
  Milliseconds,
  StateQueryError,
  StateQueryErrorCode,
  TxCBOR,
  TxSubmissionError,
  TxSubmissionErrorCode
} from '@cardano-sdk/core';
import { Connection, InteractionContext, Mirror, createConnectionObject, safeJSON } from '@cardano-ogmios/client';
import { HEALTH_RESPONSE_BODY } from '../mocks/util';
import {
  MockCreateInteractionContext,
  MockCreateLedgerStateQuery,
  MockGetServerHealth,
  MockedChainSynchronization,
  MockedLedgerStateQueryClient,
  MockedSocket,
  MockedTransactionSubmission,
  ogmiosEraSummaries
} from './util';
import { NextBlockResponse, RollForward, SubmitTransactionFailureEraMismatch } from '@cardano-ogmios/schema';
import { OgmiosObservableCardanoNode } from '../../src';
import { combineLatest, delay as delayEmission, firstValueFrom, mergeMap, of, toArray } from 'rxjs';
import { generateRandomHexString, logger } from '@cardano-sdk/util-dev';
import { mockGenesisShelley, mockShelleyBlock } from '../ogmiosToCore/testData';
import delay from 'delay';

jest.mock('@cardano-ogmios/client', () => {
  const original = jest.requireActual('@cardano-ogmios/client');
  return {
    ...original,
    ChainSynchronization: {},
    TransactionSubmission: {
      submitTransaction: jest.fn()
    },
    createInteractionContext: jest.fn(),
    createLedgerStateQueryClient: jest.fn(),
    getServerHealth: jest.fn()
  };
});
describe('ObservableOgmiosCardanoNode', () => {
  let connection: Connection;
  let createLedgerStateQueryClient: MockCreateLedgerStateQuery;
  let ledgerStateQueryClient: MockedLedgerStateQueryClient;
  let getServerHealth: MockGetServerHealth;
  let socket: MockedSocket;
  let chainSynchronization: MockedChainSynchronization;
  let TransactionSubmission: MockedTransactionSubmission;
  let createInteractionContext: MockCreateInteractionContext;

  const tip = {
    height: 10,
    id: Cardano.BlockId('0000000000000000000000000000000000000000000000000000000000000000'),
    slot: 100
  };

  beforeEach(async () => {
    connection = createConnectionObject();
    ({
      createInteractionContext,
      createLedgerStateQueryClient,
      getServerHealth,
      ChainSynchronization: chainSynchronization,
      TransactionSubmission
    } = require('@cardano-ogmios/client'));
    ledgerStateQueryClient = {
      eraSummaries: jest.fn() as MockedLedgerStateQueryClient['eraSummaries'],
      genesisConfiguration: jest.fn() as MockedLedgerStateQueryClient['genesisConfiguration'],
      liveStakeDistribution: jest.fn() as MockedLedgerStateQueryClient['liveStakeDistribution'],
      networkStartTime: jest.fn() as MockedLedgerStateQueryClient['networkStartTime']
    } as MockedLedgerStateQueryClient;
    createLedgerStateQueryClient.mockResolvedValue(ledgerStateQueryClient);
    chainSynchronization.findIntersection = jest.fn();
    chainSynchronization.nextBlock = jest.fn();
    ledgerStateQueryClient.eraSummaries.mockResolvedValue(ogmiosEraSummaries);
    ledgerStateQueryClient.genesisConfiguration.mockResolvedValue(mockGenesisShelley as any);
    ledgerStateQueryClient.networkStartTime.mockResolvedValue(new Date(mockGenesisShelley.startTime));
    ledgerStateQueryClient.liveStakeDistribution.mockResolvedValue({
      pool1cjm567pd9eqj7wlpuq2mnsasw2upewq0tchg4n8gktq5k7eepvr: {
        stake: '1/100',
        vrf: '4e4a2e82dc455449bf5f1f6d249470963cf97389b5dc4d2118fe21625f50f518'
      }
    });
    chainSynchronization.findIntersection.mockResolvedValue({
      intersection: {
        id: generateRandomHexString(64),
        slot: 10
      },
      tip
    });
    socket = {
      off: jest.fn() as typeof socket.off,
      on: jest.fn((eventName, handler) => {
        if (eventName !== 'message') return socket;
        chainSynchronization.nextBlock = jest.fn((_, { id }: { id: Mirror }) => {
          handler(
            safeJSON.stringify({
              id: { requestId: id.requestId },
              jsonrpc: '2.0',
              method: 'nextBlock',
              result: {
                // TODO: use a block that has some tx(es)
                block: mockShelleyBlock,
                direction: 'forward',
                tip
              } as RollForward
            } as NextBlockResponse)
          );
        }) as any;
        return socket;
      }) as any
    } as MockedSocket;
    createInteractionContext.mockResolvedValue({ connection, socket } as InteractionContext);
    getServerHealth.mockResolvedValue(HEALTH_RESPONSE_BODY);
  });

  afterEach(() => {
    createInteractionContext.mockReset();
    createLedgerStateQueryClient.mockReset();
    getServerHealth.mockReset();
    TransactionSubmission.submitTransaction.mockReset();
  });

  describe('LSQs on QueryUnavailableInCurrentEra', () => {
    it('genesisParameters$ keeps polling until query is available', async () => {
      ledgerStateQueryClient.genesisConfiguration
        .mockRejectedValueOnce(new StateQueryError(StateQueryErrorCode.UnavailableInCurrentEra, null, ''))
        .mockRejectedValueOnce(new StateQueryError(StateQueryErrorCode.UnavailableInCurrentEra, null, ''));
      const node = new OgmiosObservableCardanoNode(
        { connectionConfig$: of(connection), localStateQueryRetryConfig: { initialInterval: 1 } },
        { logger }
      );
      // entire object is not equal because of the difference of core types vs ogmios types
      expect((await firstValueFrom(node.genesisParameters$)).epochLength).toEqual(mockGenesisShelley.epochLength);
      expect(ledgerStateQueryClient.genesisConfiguration).toBeCalledTimes(3);
    });

    it('eraSummaries$ keeps polling until query is available', async () => {
      ledgerStateQueryClient.eraSummaries
        .mockRejectedValueOnce(new StateQueryError(StateQueryErrorCode.UnavailableInCurrentEra, null, ''))
        .mockRejectedValueOnce(new StateQueryError(StateQueryErrorCode.UnavailableInCurrentEra, null, ''));
      const node = new OgmiosObservableCardanoNode(
        { connectionConfig$: of(connection), localStateQueryRetryConfig: { initialInterval: 1 } },
        { logger }
      );
      const eraSummaries = await firstValueFrom(node.eraSummaries$);
      expect(eraSummaries[0].parameters.epochLength).toEqual(ogmiosEraSummaries[0].parameters.epochLength);
      expect(ledgerStateQueryClient.genesisConfiguration).toBeCalledTimes(3);
    });

    it('systemStart$ keeps polling until query is available', async () => {
      ledgerStateQueryClient.networkStartTime
        .mockRejectedValueOnce(new StateQueryError(StateQueryErrorCode.UnavailableInCurrentEra, null, ''))
        .mockRejectedValueOnce(new StateQueryError(StateQueryErrorCode.UnavailableInCurrentEra, null, ''));
      const node = new OgmiosObservableCardanoNode(
        { connectionConfig$: of(connection), localStateQueryRetryConfig: { initialInterval: 1 } },
        { logger }
      );
      expect(await firstValueFrom(node.systemStart$)).toEqual(new Date(mockGenesisShelley.startTime));
      expect(ledgerStateQueryClient.networkStartTime).toBeCalledTimes(3);
    });

    it('stakeDistribution$ keeps polling until query is available', async () => {
      ledgerStateQueryClient.liveStakeDistribution
        .mockRejectedValueOnce(new StateQueryError(StateQueryErrorCode.UnavailableInCurrentEra, null, ''))
        .mockRejectedValueOnce(new StateQueryError(StateQueryErrorCode.UnavailableInCurrentEra, null, ''));
      const node = new OgmiosObservableCardanoNode(
        { connectionConfig$: of(connection), localStateQueryRetryConfig: { initialInterval: 1 } },
        { logger }
      );
      const stakeDistribution = await firstValueFrom(node.stakeDistribution$);
      expect(stakeDistribution.get(Cardano.PoolId('pool1cjm567pd9eqj7wlpuq2mnsasw2upewq0tchg4n8gktq5k7eepvr'))).toEqual(
        {
          stake: { pool: BigInt(1), supply: BigInt(100) },
          vrf: Cardano.VrfVkHex('4e4a2e82dc455449bf5f1f6d249470963cf97389b5dc4d2118fe21625f50f518')
        }
      );
      expect(ledgerStateQueryClient.liveStakeDistribution).toBeCalledTimes(3);
    });
  });

  describe('subscribing to all observables', () => {
    it('shares a single lazily created connection & emits well-formed data', async () => {
      const node = new OgmiosObservableCardanoNode({ connectionConfig$: of(connection) }, { logger });
      // Doesn't connect until any observable is subscribed
      await delay(100);
      expect(createInteractionContext).not.toBeCalled();

      // Shares a single connection for all observables
      const res = await firstValueFrom(
        combineLatest([
          node.eraSummaries$,
          node.genesisParameters$,
          node.findIntersect(['origin']).pipe(mergeMap(({ chainSync$ }) => chainSync$))
        ])
      );
      expect(createInteractionContext).toBeCalledTimes(1);
      // Data is well formed
      expect(res).toMatchSnapshot();
    });
  });

  it('opaquely reconnects when connection is refused', async () => {
    createInteractionContext.mockRejectedValueOnce({ name: 'WebSocketClosed' });
    const node = new OgmiosObservableCardanoNode({ connectionConfig$: of(connection) }, { logger });
    const result = firstValueFrom(node.genesisParameters$);
    // Once it can connect, it emits something that looks like genesis config
    expect(typeof (await result).epochLength).toBe('number');
    expect(createInteractionContext).toBeCalledTimes(2);
  });

  describe('healthCheck', () => {
    it('is ok if node is close to the network tip', async () => {
      getServerHealth.mockResolvedValueOnce({ ...HEALTH_RESPONSE_BODY, networkSynchronization: 0.999 });
      const node = new OgmiosObservableCardanoNode({ connectionConfig$: of(connection) }, { logger });
      const res = await firstValueFrom(node.healthCheck$);
      expect(res.ok).toBe(true);
    });
    it('simultaneous healthChecks share a single health request to ogmios', async () => {
      getServerHealth.mockImplementationOnce(async () => {
        await delay(10);
        return { ...HEALTH_RESPONSE_BODY, networkSynchronization: 0.999 };
      });
      const node = new OgmiosObservableCardanoNode({ connectionConfig$: of(connection) }, { logger });
      const [res1, res2] = await firstValueFrom(combineLatest([node.healthCheck$, node.healthCheck$]));
      expect(res1.ok).toBe(true);
      expect(res1).toEqual(res2);
      expect(getServerHealth).toBeCalledTimes(1);
    });
    it('is not ok if node is not close to the network tip', async () => {
      getServerHealth.mockResolvedValueOnce({ ...HEALTH_RESPONSE_BODY, networkSynchronization: 0.8 });
      const node = new OgmiosObservableCardanoNode({ connectionConfig$: of(connection) }, { logger });
      const res = await firstValueFrom(node.healthCheck$);
      expect(res.ok).toBe(false);
    });
    it('is not ok when ogmios responds with an unknown result', async () => {
      getServerHealth.mockRejectedValueOnce(
        new GeneralCardanoNodeError(GeneralCardanoNodeErrorCode.Unknown, null, 'Some error')
      );
      const node = new OgmiosObservableCardanoNode({ connectionConfig$: of(connection) }, { logger });
      const res = await firstValueFrom(node.healthCheck$);
      expect(res.ok).toBe(false);
    });
    it('is not ok when connection is refused', async () => {
      getServerHealth.mockRejectedValueOnce(
        new GeneralCardanoNodeError(GeneralCardanoNodeErrorCode.ConnectionFailure, null, 'Connection error')
      );
      const node = new OgmiosObservableCardanoNode({ connectionConfig$: of(connection) }, { logger });
      const result = await firstValueFrom(node.healthCheck$);
      expect(result.ok).toBe(false);
    });
    it('is ok when connectionConfig$ emits within "healthCheckTimeout" duration', async () => {
      const node = new OgmiosObservableCardanoNode(
        { connectionConfig$: of(connection).pipe(delayEmission(25)), healthCheckTimeout: Milliseconds(50) },
        { logger }
      );
      const result = await firstValueFrom(node.healthCheck$);
      expect(result.ok).toBe(true);
    });
    it('is not ok when connectionConfig$ takes longer than "healthCheckTimeout" to emit', async () => {
      const node = new OgmiosObservableCardanoNode(
        { connectionConfig$: of(connection).pipe(delayEmission(50)), healthCheckTimeout: Milliseconds(25) },
        { logger }
      );
      const result = await firstValueFrom(node.healthCheck$);
      expect(result.ok).toBe(false);
    });
  });

  describe('submitTx', () => {
    let node: OgmiosObservableCardanoNode;
    const submitTxMaxRetries = 2;

    beforeEach(() => {
      node = new OgmiosObservableCardanoNode(
        {
          connectionConfig$: of(connection),
          submitTxQueryRetryConfig: { initialInterval: 1, maxRetries: submitTxMaxRetries }
        },
        { logger }
      );
    });

    describe('successful submission', () => {
      it('emits transaction id and completes', async () => {
        TransactionSubmission.submitTransaction.mockResolvedValueOnce('id');
        await expect(firstValueFrom(node.submitTx('cbor' as TxCBOR).pipe(toArray()))).resolves.toEqual(['id']);
        expect(TransactionSubmission.submitTransaction).toBeCalledTimes(1);
      });
    });

    describe('submission error', () => {
      it('maps error to core type', async () => {
        TransactionSubmission.submitTransaction.mockRejectedValueOnce({
          code: 3005,
          data: { ledgerEra: 'shelley', queryEra: 'alonzo' },
          message: 'Era mismatch'
        } as SubmitTransactionFailureEraMismatch);
        await expect(firstValueFrom(node.submitTx('cbor' as TxCBOR))).rejects.toThrowError(
          expect.objectContaining({
            code: TxSubmissionErrorCode.EraMismatch,
            name: TxSubmissionError.name
          })
        );
        expect(TransactionSubmission.submitTransaction).toBeCalledTimes(1);
      });
    });

    describe('connection error', () => {
      it('attempts to resubmit opaquely', async () => {
        TransactionSubmission.submitTransaction
          .mockRejectedValueOnce({ code: 'ECONNREFUSED' })
          .mockResolvedValueOnce('id');
        await expect(firstValueFrom(node.submitTx('cbor' as TxCBOR))).resolves.toBe('id');
        expect(TransactionSubmission.submitTransaction).toBeCalledTimes(2);
      });

      it('rejects after maxRetries attempts to submit', async () => {
        const error = { code: 'ECONNREFUSED' };
        TransactionSubmission.submitTransaction.mockRejectedValue(error);

        await expect(firstValueFrom(node.submitTx('cbor' as TxCBOR))).rejects.toThrowError(
          expect.objectContaining({
            code: GeneralCardanoNodeErrorCode.ConnectionFailure
          })
        );
        expect(TransactionSubmission.submitTransaction).toBeCalledTimes(submitTxMaxRetries + 1);
      });
    });
  });
});
