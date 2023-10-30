import { CustomError } from 'ts-custom-error';
import { toSerializableObject } from './serializableObject';

export const formatErrorMessage = (reason: string, detail?: string) => reason + (detail ? ` (${detail})` : '');

interface ErrorLike {
  message: string;
  stack: string;
  data?: unknown;
}

interface WithInnerError {
  innerError: string | Error;
}

/**
 * Gets whether the given error has an innerError.
 *
 * @param error The error to be checked for.
 */
const isWithInnerError = (error: unknown): error is WithInnerError =>
  error !== null && typeof error === 'object' && 'innerError' in (error as never);

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

/**
 * Strips the stack trace of all errors and their inner errors recursively.
 *
 * @param error The error to be stripped of its stack trace.
 */
export const stripStackTrace = (error: unknown) => {
  if (!error) return;

  if (isErrorLike(error)) {
    delete (error as Error).stack;
  }

  if (isWithInnerError(error)) {
    stripStackTrace(error.innerError);
  }
};

export class ComposableError<InnerError = unknown> extends CustomError {
  private static stackDelimiter = '\n    at ';

  constructor(message: string, public innerError?: InnerError) {
    let firstLineOfInnerErrorStack = '';
    let innerErrorStack: string[] = [];

    if (isErrorLike(innerError) && innerError.stack) {
      [firstLineOfInnerErrorStack, ...innerErrorStack] = innerError.stack.split(ComposableError.stackDelimiter);

      message = `${message} due to\n ${firstLineOfInnerErrorStack}`;

      if (innerError.data) {
        innerError.data = toSerializableObject(innerError.data);
      }
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

export class InvalidStringError<InnerError = unknown> extends ComposableError<InnerError> {
  constructor(expectation: string, innerError?: InnerError) {
    super(`Invalid string: "${expectation}"`, innerError);
  }
}

/** Represents an error that is thrown when a function is called with an invalid argument. */
export class InvalidArgumentError extends CustomError {
  /**
   * Initializes a new instance of the InvalidArgumentError class.
   *
   * @param argName The invalid argument name.
   * @param message The error message.
   */
  public constructor(argName: string, message: string) {
    super(`Invalid argument '${argName}': ${message}`);
  }
}

/**
 * The error that is thrown when a method call is invalid for the object's current state.
 *
 * This error can be used in cases when the failure to invoke a method is caused by reasons
 * other than invalid arguments.
 */
export class InvalidStateError extends CustomError {
  /**
   * Initializes a new instance of the InvalidStateError class.
   *
   * @param message The error message.
   */
  public constructor(message: string) {
    super(`Invalid state': ${message}`);
  }
}
