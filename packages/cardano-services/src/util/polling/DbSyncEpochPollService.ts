import { Cardano } from '@cardano-sdk/core';
import { EpochModel } from '../../StakePool';
import { EpochMonitor } from './types';
import { Pool, QueryResult } from 'pg';
import { findLastEpoch } from './queries';

export const EPOCH_POLL_INTERVAL_DEFAULT = 10_000;

/** Class to handle epoch rollover through db polling */
export class DbSyncEpochPollService implements EpochMonitor {
  #timeoutId?: ReturnType<typeof setInterval>;
  #callbacks: Function[];
  #currentEpoch: Promise<Cardano.EpochNo | null>;

  /** Db connection */
  #db: Pool;

  /** Polling interval in ms */
  #interval: number;

  /**
   * @param db Db connection
   * @param interval Polling interval in ms
   */
  constructor(db: Pool, interval: number) {
    this.#db = db;
    this.#callbacks = [];
    this.#interval = interval;
    this.#currentEpoch = Promise.resolve(null);
  }

  /**
   * Poll execution to detect a new epoch rollover
   * Upon the occurrence of rollover event it executes all callbacks by registered dependant services
   */
  async #executePoll() {
    const lastEpoch = await this.#queryLastEpoch();
    const currentEpoch = await this.#currentEpoch;
    const shouldClearCache = !!(currentEpoch && lastEpoch > currentEpoch);

    if (shouldClearCache) this.onEpoch(lastEpoch);
  }

  /**
   * Query the last epoch number stored in db
   *
   * @returns {number} epoch number
   */
  async #queryLastEpoch() {
    const result: QueryResult<EpochModel> = await this.#db.query({
      name: 'current_epoch',
      text: findLastEpoch
    });
    return Cardano.EpochNo(result.rowCount ? result.rows[0].no : 0);
  }

  /** Starts the poll execution */
  #start() {
    if (this.#timeoutId) return;

    this.#currentEpoch = this.#queryLastEpoch();
    this.#timeoutId = setInterval(() => this.#executePoll(), this.#interval);
  }

  /** Shutdown the poll execution */
  #shutdown() {
    if (this.#timeoutId) clearInterval(this.#timeoutId);
  }

  /** Epoch Rollover event - subscription-based mechanism to manage starting and stopping of epoch poll service */
  onEpochRollover(cb: Function) {
    this.#callbacks.push(cb);
    if (this.#callbacks.length === 1) this.#start();
    return () => {
      this.#callbacks.splice(this.#callbacks.indexOf(cb), 1);
      if (this.#callbacks.length === 0) this.#shutdown();
    };
  }

  /** Get last known epoch */
  getLastKnownEpoch() {
    return this.#currentEpoch;
  }

  onEpoch(currentEpoch: Cardano.EpochNo) {
    this.#currentEpoch = Promise.resolve(currentEpoch);

    for (const cb of this.#callbacks) cb();
  }
}
