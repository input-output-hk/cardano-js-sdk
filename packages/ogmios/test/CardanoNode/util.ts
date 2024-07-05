import {
  ChainSynchronization,
  InteractionContext,
  TransactionSubmission,
  createInteractionContext,
  createLedgerStateQueryClient,
  getServerHealth
} from '@cardano-ogmios/client';
import { EraSummary } from '@cardano-ogmios/schema';
import { LedgerStateQueryClient } from '@cardano-ogmios/client/dist/LedgerStateQuery';

export type MockedSocket = jest.Mocked<InteractionContext['socket']>;
export type MockedLedgerStateQueryClient = jest.Mocked<LedgerStateQueryClient>;
export type MockCreateLedgerStateQuery = jest.MockedFunction<typeof createLedgerStateQueryClient>;
export type MockGetServerHealth = jest.MockedFunction<typeof getServerHealth>;
export type MockedChainSynchronization = jest.Mocked<typeof ChainSynchronization>;
export type MockedTransactionSubmission = jest.Mocked<typeof TransactionSubmission>;
export type MockCreateInteractionContext = jest.MockedFunction<typeof createInteractionContext>;

export const ogmiosEraSummaries: EraSummary[] = [
  {
    parameters: {
      epochLength: 1,
      safeZone: 1,
      slotLength: {
        milliseconds: 1000n
      }
    },
    start: {
      epoch: 0,
      slot: 0,
      time: { seconds: 0n }
    }
  }
];
