import { TransactionTracker, TransactionTrackerEvents } from './types';
import Emittery from 'emittery';
import { Hash16, Slot, Tip } from '@cardano-ogmios/schema';
import { WalletProvider, ProviderError, ProviderFailure, CSL } from '@cardano-sdk/core';
import { TransactionError, TransactionFailure } from './TransactionError';
import { dummyLogger, Logger } from 'ts-log';
import delay from 'delay';
import { TransactionTrackerEvent } from '.';

export type Milliseconds = number;

export interface InMemoryTransactionTrackerProps {
  provider: WalletProvider;
  logger?: Logger;
  pollInterval?: Milliseconds;
}

export class InMemoryTransactionTracker extends Emittery<TransactionTrackerEvents> implements TransactionTracker {
  readonly #provider: WalletProvider;
  readonly #pendingTransactions = new Map<string, Promise<void>>();
  readonly #logger: Logger;
  readonly #pollInterval: number;

  constructor({ provider, logger = dummyLogger, pollInterval = 2000 }: InMemoryTransactionTrackerProps) {
    super();
    this.#provider = provider;
    this.#logger = logger;
    this.#pollInterval = pollInterval;
  }

  async track(transaction: CSL.Transaction, submitted: Promise<void> = Promise.resolve()): Promise<void> {
    await submitted;
    const body = transaction.body();
    const hash = Buffer.from(CSL.hash_transaction(body).to_bytes()).toString('hex');
    this.#logger.debug('InMemoryTransactionTracker.trackTransaction', hash);

    if (this.#pendingTransactions.has(hash)) {
      return this.#pendingTransactions.get(hash)!;
    }

    const invalidHereafter = body.ttl();
    if (!invalidHereafter) {
      throw new TransactionError(TransactionFailure.CannotTrack, undefined, 'no TTL');
    }

    const promise = this.#checkTransactionViaProvider(hash, invalidHereafter);
    this.#pendingTransactions.set(hash, promise);
    this.emit(TransactionTrackerEvent.NewTransaction, { transaction, confirmed: promise }).catch(this.#logger.error);
    void promise.catch(() => void 0).then(() => this.#pendingTransactions.delete(hash));

    return promise;
  }

  async #checkTransactionViaProvider(hash: Hash16, invalidHereafter: Slot): Promise<void> {
    await delay(this.#pollInterval);
    try {
      const tx = await this.#provider.queryTransactionsByHashes([hash]);
      if (tx.length > 0) return; // done
      return this.#onTransactionNotFound(hash, invalidHereafter);
    } catch (error: unknown) {
      if (error instanceof ProviderError && error.reason === ProviderFailure.NotFound) {
        return this.#onTransactionNotFound(hash, invalidHereafter);
      }
      throw new TransactionError(TransactionFailure.CannotTrack, error);
    }
  }

  async #onTransactionNotFound(hash: string, invalidHereafter: number) {
    let tip: Tip | undefined;
    try {
      tip = await this.#provider.ledgerTip();
    } catch (error: unknown) {
      throw new TransactionError(
        TransactionFailure.CannotTrack,
        error,
        "can't query tip to check for transaction timeout"
      );
    }
    if (tip && tip.slot > invalidHereafter) {
      throw new TransactionError(TransactionFailure.Timeout);
    }
    return this.#checkTransactionViaProvider(hash, invalidHereafter);
  }
}
