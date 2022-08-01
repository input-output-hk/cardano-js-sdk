/* eslint-disable @typescript-eslint/no-explicit-any */
import { Cardano } from '@cardano-sdk/core';
import { OutsideOfValidityInterval } from '@cardano-ogmios/schema';
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
  if (typeof error === 'object') {
    const rawError = error as Cardano.TxSubmissionError;

    if (typeof rawError.name === 'string' && typeof rawError.message === 'string') {
      const txSubmissionErrorName = rawError.name as keyof typeof Cardano.TxSubmissionErrors;
      const ErrorClass = Cardano.TxSubmissionErrors[txSubmissionErrorName];

      if (ErrorClass) return ErrorClass.prototype;
    }
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

  if (err instanceof Cardano.TxSubmissionErrors.OutsideOfValidityIntervalError) {
    const details = JSON.parse(err.message) as OutsideOfValidityInterval['outsideOfValidityInterval'];

    if (details.interval.invalidBefore && details.currentSlot <= details.interval.invalidBefore) isRetryable = true;
  }

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
