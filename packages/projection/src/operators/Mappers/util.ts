import { Logger, dummyLogger } from 'ts-log';

/**
 * Up to 100k transactions per block.
 * Fits in 64-bit signed integer.
 */
export const computeCompactTxId = (blockHeight: number, txIndex: number) => blockHeight * 100_000 + txIndex;

export const logError = (error: unknown) => {
  const logger: Logger = dummyLogger;
  const message = error instanceof Error ? error.message : `Internal error: ${error}`;
  logger.error(message);
};
