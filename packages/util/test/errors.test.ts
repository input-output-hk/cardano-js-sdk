import { ComposableError, stripStackTrace } from '../src/index.js';

class TestError<InnerError = unknown> extends ComposableError<InnerError> {
  constructor(innerError: InnerError) {
    super('Test error', innerError);
  }
}

const throwsError = () => {
  throw new Error('a');
};

const throwsComposableError = () => {
  try {
    throwsError();
  } catch (error) {
    throw new TestError(error);
  }
};

describe('stripStackTrace', () => {
  it('doesnt throw if given undefined', () => {
    const error = undefined;
    expect(() => stripStackTrace(error)).not.toThrow();
  });

  it('doesnt throw if given null', () => {
    const error = null;
    expect(() => stripStackTrace(error)).not.toThrow();
  });

  it('doesnt throw if a non Error object', () => {
    const error = { a: 'a' };
    expect(() => stripStackTrace(error)).not.toThrow();
    expect(() => stripStackTrace(10)).not.toThrow();
    expect(() => stripStackTrace('some error')).not.toThrow();
  });

  it('removes the stack field from the Error object', () => {
    try {
      throwsError();
    } catch (error) {
      stripStackTrace(error);
      expect((error as Error).stack).toBeUndefined();
    }
  });

  it('removes the stack field from the Error object and inner errors', () => {
    try {
      throwsComposableError();
    } catch (error) {
      let testError = error as TestError;
      let innerError = testError.innerError as Error;

      expect(testError.stack).toBeDefined();
      expect(innerError.stack).toBeDefined();

      stripStackTrace(error);

      testError = error as TestError;
      innerError = testError.innerError as Error;

      expect(testError.stack).toBeUndefined();
      expect(innerError.stack).toBeUndefined();
    }
  });
});
