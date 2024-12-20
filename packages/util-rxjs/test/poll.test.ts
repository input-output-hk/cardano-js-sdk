import { BehaviorSubject, EmptyError, Subject, firstValueFrom, lastValueFrom, tap } from 'rxjs';
import { InvalidStringError } from '@cardano-sdk/util';
import { RetryBackoffConfig, retryBackoff } from 'backoff-rxjs';
import { TestLogger, createLogger } from '@cardano-sdk/util-dev';
import { poll } from '../src';

// There might be a more elegant way to mock with original implementation (spy)
jest.mock('backoff-rxjs', () => ({
  retryBackoff: jest.fn().mockImplementation((...args) => jest.requireActual('backoff-rxjs').retryBackoff(...args))
}));

describe('poll', () => {
  let logger: TestLogger;
  const testErrorStr = 'Test error';

  beforeEach(() => {
    logger = createLogger({ record: true });
  });

  it('returns an observable that calls sample on each subscription and uses retryBackoff', async () => {
    const sample = jest.fn().mockResolvedValue(true);
    const backoffConfig: RetryBackoffConfig = { initialInterval: 1 };
    const values$ = poll({
      logger,
      retryBackoffConfig: backoffConfig,
      sample
    });
    expect(await firstValueFrom(values$)).toBe(true);
    expect(await firstValueFrom(values$)).toBe(true);
    expect(sample).toBeCalledTimes(2);
    expect(retryBackoff).toBeCalledTimes(2);
  });

  it('completes on cancel emit', async () => {
    const fakeSampleSubject = new Subject();
    const sample = () => firstValueFrom(fakeSampleSubject);
    const backoffConfig: RetryBackoffConfig = { initialInterval: 1 };
    const cancel$ = new BehaviorSubject<boolean>(true);
    const values$ = poll({
      cancel$,
      logger,
      retryBackoffConfig: backoffConfig,
      sample
    });

    try {
      await firstValueFrom(values$);
    } catch (error) {
      expect(error).toBeInstanceOf(EmptyError);
    }
    expect.assertions(1);
  });

  it('retries using retryBackoff, when sample rejects', async () => {
    const sample = jest.fn().mockRejectedValueOnce(false).mockResolvedValue(true);
    const retryBackoffConfig: RetryBackoffConfig = { initialInterval: 1 };
    const values$ = poll({ logger, retryBackoffConfig, sample });
    const resolvedValue = await firstValueFrom(values$);
    expect(sample).toBeCalledTimes(2);
    expect(resolvedValue).toBeTruthy();
  });

  it('does not retry, when shouldRetry returns false', async () => {
    const testValue = { test: 'value' };
    const testError = new InvalidStringError('Test invalid string error');
    const sample = jest
      .fn()
      .mockRejectedValueOnce(new Error(testErrorStr))
      .mockResolvedValueOnce(testValue)
      .mockRejectedValueOnce(testError)
      .mockResolvedValueOnce(testValue);
    const retryBackoffConfig: RetryBackoffConfig = {
      initialInterval: 1,
      shouldRetry: (error) => !(error instanceof InvalidStringError)
    };
    const values$ = poll({
      logger,
      retryBackoffConfig,
      sample
    });
    await expect(firstValueFrom(values$)).resolves.toBe(testValue);
    await expect(firstValueFrom(values$)).rejects.toThrow(testError);
    expect(sample).toBeCalledTimes(3);
    expect(logger.messages).toStrictEqual([
      { level: 'error', message: [new Error(testErrorStr)] },
      { level: 'debug', message: ['Should retry: true'] },
      { level: 'error', message: [testError] },
      { level: 'debug', message: ['Should retry: false'] }
    ]);
  });

  it('polls sample until the pollUntil condition is satisfied', async () => {
    const sample = jest
      .fn()
      .mockResolvedValueOnce('a')
      .mockResolvedValueOnce('b')
      .mockResolvedValueOnce('c')
      .mockResolvedValue('Never reached');
    const backoffConfig: RetryBackoffConfig = { initialInterval: 1 };

    const values$ = poll({
      logger,
      pollUntil: (v) => v === 'c',
      retryBackoffConfig: backoffConfig,
      sample
    });

    const sampleValues: unknown[] = [];
    await lastValueFrom(values$.pipe(tap((v) => sampleValues.push(v))));
    expect(sampleValues).toEqual(['a', 'b', 'c']);
    expect(sample).toBeCalledTimes(3);
  });

  it('stops retrying after maxRetries attempts and handles the error in catchError', async () => {
    const testError = new Error(testErrorStr);
    const sample = jest.fn().mockRejectedValue(testError);
    const maxRetries = 3;
    const retryBackoffConfig: RetryBackoffConfig = { initialInterval: 1, maxRetries };

    const values$ = poll({
      logger,
      retryBackoffConfig,
      sample
    });

    await expect(firstValueFrom(values$)).rejects.toThrow(testError);

    expect(sample).toBeCalledTimes(maxRetries + 1);
    expect(logger.messages).toStrictEqual([
      { level: 'error', message: [testError] },
      { level: 'error', message: [testError] },
      { level: 'error', message: [testError] }
    ]);
  });
});
