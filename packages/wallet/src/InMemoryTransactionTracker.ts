import { TransactionTracker, TransactionTrackerEvents } from './types';
import Emittery from 'emittery';
import { Hash16, Slot, Tip } from '@cardano-ogmios/schema';
import { CardanoProvider, CardanoProviderError, CardanoSerializationLib, CSL } from '@cardano-sdk/core';
import { TransactionError, TransactionFailure } from './Transaction/TransactionError';
import { Logger } from 'ts-log';
import delay from 'delay';

export type Milliseconds = number;

export interface InMemoryTransactionTrackerProps {
  provider: CardanoProvider;
  csl: CardanoSerializationLib;
  logger: Logger;
  pollInterval?: Milliseconds;
}

export class InMemoryTransactionTracker extends Emittery<TransactionTrackerEvents> implements TransactionTracker {
  readonly #provider: CardanoProvider;
  readonly #pendingTransactions = new Map<string, Promise<void>>();
  readonly #csl: CardanoSerializationLib;
  readonly #logger: Logger;
  readonly #pollInterval: number;

  constructor({ provider, csl, logger, pollInterval = 2000 }: InMemoryTransactionTrackerProps) {
    super();
    this.#provider = provider;
    this.#csl = csl;
    this.#logger = logger;
    this.#pollInterval = pollInterval;
  }

  async trackTransaction(transaction: CSL.Transaction): Promise<void> {
    const body = transaction.body();
    const hash = Buffer.from(this.#csl.hash_transaction(body).to_bytes()).toString('hex');
    this.#logger.debug('InMemoryTransactionTracker.trackTransaction', hash);

    if (this.#pendingTransactions.has(hash)) {
      return this.#pendingTransactions.get(hash)!;
    }

    const invalidHereafter = body.ttl();
    if (!invalidHereafter) {
      throw new TransactionError(TransactionFailure.CannotTrack, undefined, 'no TTL');
    }

    const promise = this.#trackTransaction(hash, invalidHereafter);
    this.#pendingTransactions.set(hash, promise);
    this.emit('transaction', { transaction, confirmed: promise }).catch(this.#logger.error);
    void promise.catch(() => void 0).then(() => this.#pendingTransactions.delete(hash));

    return promise;
  }

  async #trackTransaction(hash: Hash16, invalidHereafter: Slot, numTipFailures = 0): Promise<void> {
    await delay(this.#pollInterval);
    try {
      const tx = await this.#provider.queryTransactionsByHashes([hash]);
      if (tx.length > 0) return; // done
      return this.#onTransactionNotFound(hash, invalidHereafter, numTipFailures);
    } catch (error: unknown) {
      const providerError = this.#formatCardanoProviderError(error);
      if (providerError.status_code !== 404) {
        throw new TransactionError(TransactionFailure.CannotTrack, error);
      }
      return this.#onTransactionNotFound(hash, invalidHereafter, numTipFailures);
    }
  }

  async #onTransactionNotFound(hash: string, invalidHereafter: number, numTipFailures: number) {
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
    return this.#trackTransaction(hash, invalidHereafter, numTipFailures);
  }

  #formatCardanoProviderError(error: unknown) {
    const cardanoProviderError = error as CardanoProviderError;
    if (typeof cardanoProviderError === 'string') {
      throw new TransactionError(TransactionFailure.Unknown, error, cardanoProviderError);
    }
    if (typeof cardanoProviderError !== 'object') {
      throw new TransactionError(TransactionFailure.Unknown, error, 'failed to parse error (response type)');
    }
    const errorAsType1 = cardanoProviderError as {
      status_code: number;
      message: string;
      error: string;
    };
    if (errorAsType1.status_code) {
      return errorAsType1;
    }
    const errorAsType2 = cardanoProviderError as {
      errno: number;
      message: string;
      code: string;
    };
    if (errorAsType2.code) {
      const status_code = Number.parseInt(errorAsType2.code);
      if (!status_code) {
        throw new TransactionError(TransactionFailure.Unknown, error, 'failed to parse error (status code)');
      }
      return {
        status_code,
        message: errorAsType1.message,
        error: errorAsType2.errno.toString()
      };
    }
    throw new TransactionError(TransactionFailure.Unknown, error, 'failed to parse error (response json)');
  }
}
