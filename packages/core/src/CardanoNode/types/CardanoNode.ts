// eslint-disable-next-line @typescript-eslint/ban-ts-comment
// @ts-ignore
import { CardanoNodeError, CardanoNodeNotInitializedError } from './CardanoNodeErrors';

export interface EraSummary {
  parameters: {
    epochLength: number;
    slotLength: number;
  };
  start: {
    slot: number;
    time: Date;
  };
}

export interface CardanoNode {
  /**
   * Initialize CardanoNode instance
   */
  initialize: () => Promise<void>;
  /**
   * Shut down CardanoNode instance
   *
   * @throws {CardanoNodeNotInitializedError}
   */
  shutdown: () => Promise<void>;
  /**
   * Get summaries of all Cardano eras
   *
   * @returns {EraSummary[]} Era summaries
   * @throws {CardanoNodeError}
   */
  eraSummaries: () => Promise<EraSummary[]>;
  /**
   * Get the start date of the network.
   *
   * @returns {Date} Network start date
   * @throws {CardanoNodeError}
   */
  systemStart: () => Promise<Date>;
}
