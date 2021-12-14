import { CustomError } from 'ts-custom-error';

export enum ProviderFailure {
  NotFound = 'NOT_FOUND',
  Unknown = 'UNKNOWN',
  InvalidResponse = 'INVALID_RESPONSE',
  NotImplemented = 'NOT_IMPLEMENTED'
}

const formatMessage = (reason: string, detail?: string) => reason + (detail ? ` (${detail})` : '');

export class ProviderError extends CustomError {
  constructor(public reason: ProviderFailure, public innerError?: unknown, public detail?: string) {
    super(formatMessage(reason, detail));
  }
}

export enum SerializationFailure {
  InvalidType = 'INVALID_TYPE',
  Overflow = 'OVERFLOW',
  InvalidAddress = 'INVALID_ADDRESS'
}

export class SerializationError extends CustomError {
  constructor(public reason: SerializationFailure, public detail?: string, public innerError?: unknown) {
    super(formatMessage(reason, detail));
  }
}

export class InvalidProtocolParametersError extends CustomError {
  public constructor(reason: string) {
    super(reason);
  }
}

export class NotImplementedError extends CustomError {
  public constructor(missingFeature: string) {
    super(`Not implemented: ${missingFeature}`);
  }
}

export class InvalidStringError extends CustomError {
  constructor(expectation: string, public innerError?: unknown) {
    super(`Invalid string: "${expectation}"`);
  }
}
