import { Cardano } from '@cardano-sdk/core';
import { CustomError } from 'ts-custom-error';
import { StringUtils } from '@cardano-sdk/util';

export const METADATUM_LABEL = 674n;
const MAX_BYTES = 64;

export enum MessageValidationFailure {
  wrongType = 'WrongType',
  oversize = 'Oversize'
}

export type MessageValidationResult = {
  valid: boolean;
  failure?: MessageValidationFailure;
};

export type TxMetadataMessage = string;

export type TxMetadataArgs = {
  // An array of message strings, limited to 64 bytes each
  messages: TxMetadataMessage[];
};

export type ValidationResultMap = Map<TxMetadataMessage, MessageValidationResult>;

export class MessageValidationError extends CustomError {
  public constructor(failures: ValidationResultMap) {
    const m = [failures.entries()].map(
      ([[message, result]]) => `${result.failure}: ${message.slice(0, Math.max(0, MAX_BYTES + 1))}`
    );
    super(`The provided message array contains validation errors | ${m}`);
  }
}

/**
 * Validate each message for correct type, in the case of JavaScript, and size constraint
 *
 * @param entry unknown
 * @returns Validation result
 */
export const validateMessage = (entry: unknown): MessageValidationResult => {
  if (typeof entry !== 'string') return { failure: MessageValidationFailure.wrongType, valid: false };
  if (StringUtils.byteSize(entry) > MAX_BYTES) return { failure: MessageValidationFailure.oversize, valid: false };
  return { valid: true };
};

/**
 * Converts an object containing an array of individual messages into https://cips.cardano.org/cip/CIP-20 compliant
 * transaction metadata
 *
 * @param args Object containing a message property or a string to be transformed into an array
 * @returns CIP20-compliant transaction metadata
 * @throws Message validation error containing details. Use validateMessage to independently check each message before calling this function
 */
export const toTxMetadata = (args: TxMetadataArgs | string): Cardano.TxMetadata => {
  const messages = typeof args === 'string' ? StringUtils.chunkByBytes(args, MAX_BYTES) : args.messages;
  const invalidMessages: ValidationResultMap = new Map();
  for (const message of messages) {
    const result = validateMessage(message);
    if (!result.valid) invalidMessages.set(message, result);
  }
  if (invalidMessages.size > 0) throw new MessageValidationError(invalidMessages);
  return new Map([[METADATUM_LABEL, new Map([['msg', messages]])]]);
};
