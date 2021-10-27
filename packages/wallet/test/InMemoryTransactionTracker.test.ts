import { CSL, ProviderError, ProviderFailure } from '@cardano-sdk/core';
import { InMemoryTransactionTracker, TransactionFailure, TransactionTrackerEvent } from '../src';
import { ProviderStub, ledgerTip, providerStub, queryTransactionsResult } from './mocks';
import { dummyLogger } from 'ts-log';
import mockDelay from 'delay';

jest.mock('delay', () => jest.fn().mockResolvedValue(void 0));
// eslint-disable-next-line sonarjs/no-duplicate-string
jest.mock('@emurgo/cardano-serialization-lib-nodejs', () => ({
  ...jest.requireActual('@emurgo/cardano-serialization-lib-nodejs'),
  hash_transaction: jest.fn()
}));
const cslMock = jest.requireMock('@emurgo/cardano-serialization-lib-nodejs');
const mockHashTransactionReturn = (resultHash: string) => {
  cslMock.hash_transaction.mockReturnValue({
    to_bytes() {
      return Buffer.from(resultHash);
    }
  });
};

describe('InMemoryTransactionTracker', () => {
  const POLL_INTERVAL = 1000;
  let ledgerTipSlot: number;
  let provider: ProviderStub;
  let txTracker: InMemoryTransactionTracker;

  beforeEach(() => {
    provider = providerStub();
    provider.queryTransactionsByHashes.mockReturnValue([queryTransactionsResult[0]]);
    mockHashTransactionReturn('some-hash');
    txTracker = new InMemoryTransactionTracker({
      logger: dummyLogger,
      pollInterval: POLL_INTERVAL,
      provider
    });
    ledgerTipSlot = ledgerTip.slot;
    (mockDelay as unknown as jest.Mock).mockReset();
  });

  afterEach(() => cslMock.hash_transaction.mockReset());

  describe('track', () => {
    let onTransaction: jest.Mock;

    beforeEach(() => {
      onTransaction = jest.fn();
      txTracker.on(TransactionTrackerEvent.NewTransaction, onTransaction);
    });

    it('cannot track transactions that have no validity interval', async () => {
      await expect(() =>
        txTracker.track({
          body: () => ({
            ttl: () => void 0
          })
        } as unknown as CSL.Transaction)
      ).rejects.toThrowError(TransactionFailure.CannotTrack);
    });

    describe('valid transaction', () => {
      let transaction: CSL.Transaction;

      beforeEach(async () => {
        transaction = {
          body: () => ({
            ttl: () => ledgerTipSlot
          })
        } as unknown as CSL.Transaction;
      });

      it('throws CannotTrack on ledger tip fetch error', async () => {
        provider.queryTransactionsByHashes.mockResolvedValueOnce([]);
        provider.ledgerTip.mockRejectedValueOnce(new ProviderError(ProviderFailure.Unknown));
        await expect(txTracker.track(transaction)).rejects.toThrowError(TransactionFailure.CannotTrack);
        expect(provider.ledgerTip).toBeCalledTimes(1);
        expect(provider.queryTransactionsByHashes).toBeCalledTimes(1);
      });

      it('polls provider at "pollInterval" until it returns the transaction', async () => {
        // resolve [] or reject with 404 should be treated the same
        provider.queryTransactionsByHashes.mockResolvedValueOnce([]);
        provider.queryTransactionsByHashes.mockRejectedValueOnce(new ProviderError(ProviderFailure.NotFound));
        await txTracker.track(transaction);
        expect(provider.queryTransactionsByHashes).toBeCalledTimes(3);
        expect(mockDelay).toBeCalledTimes(3);
        expect(mockDelay).toBeCalledWith(POLL_INTERVAL);
      });

      it('throws after timeout', async () => {
        provider.queryTransactionsByHashes.mockResolvedValueOnce([]);
        provider.ledgerTip.mockResolvedValueOnce({ slot: ledgerTipSlot + 1 });
        await expect(txTracker.track(transaction)).rejects.toThrowError(TransactionFailure.Timeout);
      });

      it('emits "transaction" event for tracked transactions, returns promise unique per pending tx', async () => {
        const promise1 = txTracker.track(transaction);
        const promise2 = txTracker.track(transaction);
        await promise1;
        await promise2;
        mockHashTransactionReturn('other-hash');
        await txTracker.track(transaction);
        expect(provider.queryTransactionsByHashes).toBeCalledTimes(2);
        expect(onTransaction).toBeCalledTimes(2);
        // assert it clears cache
        await txTracker.track(transaction);
        expect(provider.queryTransactionsByHashes).toBeCalledTimes(3);
        expect(onTransaction).toBeCalledTimes(3);
      });
    });
  });
});
