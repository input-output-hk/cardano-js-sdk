import { CustomError } from 'ts-custom-error';

export enum ProviderFailure {
  NotFound = 'NOT_FOUND',
  Unknown = 'UNKNOWN',
  InvalidResponse = 'INVALID_RESPONSE',
  NotImplemented = 'NOT_IMPLEMENTED',
  Unhealthy = 'UNHEALTHY',
  ConnectionFailure = 'CONNECTION_FAILURE',
  BadRequest = 'BAD_REQUEST'
}

export const providerFailureToStatusCodeMap: { [key in ProviderFailure]: number } = {
  [ProviderFailure.BadRequest]: 400,
  [ProviderFailure.NotFound]: 404,
  [ProviderFailure.Unhealthy]: 500,
  [ProviderFailure.Unknown]: 500,
  [ProviderFailure.InvalidResponse]: 500,
  [ProviderFailure.NotImplemented]: 500,
  [ProviderFailure.ConnectionFailure]: 500
};

const formatMessage = (reason: string, detail?: string) => reason + (detail ? ` (${detail})` : '');

interface ErrorLike {
  message: string;
  stack: string;
}

/**
 * This type check works as an "error instanceof Error" check, but it let pass also those objects
 * which implements the Error interface without inheriting from the same base class
 * (as the errors thrown by the fs package are)
 *
 * @param error the error object to evaluate
 * @returns whether the input error is or not an ErrorLike
 */
const isErrorLike = (error: unknown): error is ErrorLike => {
  if (!error || typeof error !== 'object' || !('message' in (error as never) && 'stack' in (error as never)))
    return false;

  const { message, stack } = error as ErrorLike;

  return typeof message === 'string' && typeof stack === 'string';
};

export class ComposableError<InnerError = unknown> extends CustomError {
  private static stackDelimiter = '\n    at ';

  constructor(message: string, public innerError?: InnerError) {
    let firstLineOfInnerErrorStack = '';
    let innerErrorStack: string[] = [];

    if (isErrorLike(innerError) && innerError.stack) {
      [firstLineOfInnerErrorStack, ...innerErrorStack] = innerError.stack.split(ComposableError.stackDelimiter);

      message = `${message} due to\n ${firstLineOfInnerErrorStack}`;
    }

    if (typeof innerError === 'string') message = `${message} due to\n ${innerError}`;

    super(message);

    if (!this.stack || innerErrorStack.length === 0) return;

    const [firstLineOfStack] = this.stack.split(ComposableError.stackDelimiter);

    Object.defineProperty(this, 'stack', {
      configurable: true,
      value: `${firstLineOfStack}${innerErrorStack.join(ComposableError.stackDelimiter)}`
    });
  }
}

export class ProviderError<InnerError = unknown> extends ComposableError<InnerError> {
  constructor(public reason: ProviderFailure, innerError?: InnerError, public detail?: string) {
    super(formatMessage(reason, detail), innerError);
  }
}

export enum SerializationFailure {
  InvalidType = 'INVALID_TYPE',
  Overflow = 'OVERFLOW',
  InvalidAddress = 'INVALID_ADDRESS',
  MaxLengthLimit = 'MAX_LENGTH_LIMIT',
  InvalidNativeScriptKind = 'INVALID_NATIVE_SCRIPT_KIND',
  InvalidScriptType = 'INVALID_SCRIPT_TYPE'
}

export class SerializationError<InnerError = unknown> extends ComposableError<InnerError> {
  constructor(public reason: SerializationFailure, public detail?: string, innerError?: InnerError) {
    super(formatMessage(reason, detail), innerError);
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

export class InvalidStringError<InnerError = unknown> extends ComposableError<InnerError> {
  constructor(expectation: string, innerError?: InnerError) {
    super(`Invalid string: "${expectation}"`, innerError);
  }
}
