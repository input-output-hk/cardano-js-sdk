import { CustomError } from 'ts-custom-error';

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

export class InvalidStringError<InnerError = unknown> extends ComposableError<InnerError> {
  constructor(expectation: string, innerError?: InnerError) {
    super(`Invalid string: "${expectation}"`, innerError);
  }
}
