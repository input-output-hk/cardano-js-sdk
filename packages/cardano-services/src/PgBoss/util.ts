import { availableQueues } from '@cardano-sdk/projection-typeorm';
import type { PgBossQueue } from './types.js';

/**
 * Checks if a string value is the name of a **pg-boss** queue.
 *
 * @param queue the string to check
 * @returns `true` if the value of `queue` is the name of a **pg-boss** queue
 */
export const isValidQueue = (queue: string): queue is PgBossQueue => availableQueues.includes(queue as PgBossQueue);

export const isErrorWithConstraint = (error: unknown): error is Error & { constraint: unknown } =>
  error instanceof Error && 'constraint' in error;
