/* eslint-disable @typescript-eslint/no-explicit-any */
import {
  CardanoNodeUtil,
  ChainSyncError,
  GeneralCardanoNodeError,
  StateQueryError,
  TxSubmissionError
} from '@cardano-sdk/core';
import { toSerializableObject } from '@cardano-sdk/util';

export const TX_SUBMISSION_QUEUE = 'cardano-tx-submit';

/**
 * Analyzes a serializable error to get the right prototype object
 *
 * @param error the error to analyze
 * @returns the right prototype for the error
 */
// eslint-disable-next-line @typescript-eslint/no-explicit-any
export const getErrorPrototype = (error: unknown) => {
  if (CardanoNodeUtil.asGeneralCardanoNodeError(error)) {
    return GeneralCardanoNodeError.prototype;
  }
  if (CardanoNodeUtil.asTxSubmissionError(error)) {
    return TxSubmissionError.prototype;
  }
  if (CardanoNodeUtil.asStateQueryError(error)) {
    return StateQueryError.prototype;
  }
  if (CardanoNodeUtil.asChainSyncError(error)) {
    return ChainSyncError.prototype;
  }
  return Error.prototype;
};

/**
 * Serializes an error and checks if it is retryable
 *
 * @param err the error to serialize
 */
export const serializeError = (err: unknown) => {
  let isRetryable = false;

  const serializableError = toSerializableObject(err);

  if (CardanoNodeUtil.isOutsideOfValidityIntervalError(err)) {
    const details = err.data;
    if (details.validityInterval.invalidBefore && details.currentSlot <= details.validityInterval.invalidBefore)
      isRetryable = true;
  }

  // TODO: connection errors are also retryable

  return { isRetryable, serializableError };
};

// Workaround inspired to https://github.com/amqp-node/amqplib/issues/250#issuecomment-888558719
// to avoid the error reported on https://github.com/amqp-node/amqplib/issues/692
export const waitForPending = async (channel: unknown) => {
  const check = () => {
    const { pending, reply } = channel as { pending: unknown[]; reply: unknown };

    return pending.length > 0 || reply !== null;
  };

  try {
    while (check()) await new Promise((resolve) => setTimeout(resolve, 50));
  } catch {
    // If something is wrong in the workaround as well... let's simply go on and close the channel
  }
};

export const CONNECTION_ERROR_EVENT = 'connection-error';
