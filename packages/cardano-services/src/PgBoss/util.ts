import { PgBossQueue, workerQueues } from './types';

export const isValidQueue = (queue: string): queue is PgBossQueue => workerQueues.includes(queue as PgBossQueue);

export const isErrorWithConstraint = (error: unknown): error is Error & { constraint: unknown } =>
  error instanceof Error && 'constraint' in error;
