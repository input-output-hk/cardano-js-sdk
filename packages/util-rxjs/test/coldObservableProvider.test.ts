import { BehaviorSubject, EmptyError, Subject, firstValueFrom, lastValueFrom, tap } from 'rxjs';
import { InvalidStringError } from '@cardano-sdk/util';
import { RetryBackoffConfig, retryBackoff } from 'backoff-rxjs';
import { TestLogger, createLogger } from '@cardano-sdk/util-dev';
import { coldObservableProvider } from '../src';

// There might be a more elegant way to mock with original implementation (spy)
jest.mock('backoff-rxjs', () => ({
  retryBackoff: jest.fn().mockImplementation((...args) => jest.requireActual('backoff-rxjs').retryBackoff(...args))
}));

describe('coldObservableProvider', () => {
  let logger: TestLogger;
  const testErrorStr = 'Test error';

  beforeEach(() => {
    logger = createLogger({ record: true });
  });

  it('returns an observable that calls underlying provider on each subscription and uses retryBackoff', async () => {
    const underlyingProvider = jest.fn().mockResolvedValue(true);
    const backoffConfig: RetryBackoffConfig = { initialInterval: 1 };
    const provider$ = coldObservableProvider({
      logger,
      provider: underlyingProvider,
      retryBackoffConfig: backoffConfig
    });
    expect(await firstValueFrom(provider$)).toBe(true);
    expect(await firstValueFrom(provider$)).toBe(true);
    expect(underlyingProvider).toBeCalledTimes(2);
    expect(retryBackoff).toBeCalledTimes(2);
  });

  it('provider is unsubscribed on cancel emit', async () => {
    const fakeProviderSubject = new Subject();
    const underlyingProvider = () => firstValueFrom(fakeProviderSubject);
    const backoffConfig: RetryBackoffConfig = { initialInterval: 1 };
    const cancel$ = new BehaviorSubject<boolean>(true);
    const provider$ = coldObservableProvider({
      cancel$,
      logger,
      provider: underlyingProvider,
      retryBackoffConfig: backoffConfig
    });

    try {
      await firstValueFrom(provider$);
    } catch (error) {
      expect(error).toBeInstanceOf(EmptyError);
    }
    expect.assertions(1);
  });

  it('retries using retryBackoff, when underlying provider rejects', async () => {
    const underlyingProvider = jest.fn().mockRejectedValueOnce(false).mockResolvedValue(true);
    const retryBackoffConfig: RetryBackoffConfig = { initialInterval: 1 };
    const provider$ = coldObservableProvider({ logger, provider: underlyingProvider, retryBackoffConfig });
    const resolvedValue = await firstValueFrom(provider$);
    expect(underlyingProvider).toBeCalledTimes(2);
    expect(resolvedValue).toBeTruthy();
  });

  it('does not retry, when underlying provider rejects with InvalidStringError', async () => {
    const testValue = { test: 'value' };
    const testError = new InvalidStringError('Test invalid string error');
    const underlyingProvider = jest
      .fn()
      .mockRejectedValueOnce(new Error(testErrorStr))
      .mockResolvedValueOnce(testValue)
      .mockRejectedValueOnce(testError)
      .mockResolvedValueOnce(testValue);
    const onFatalError = jest.fn();
    const retryBackoffConfig: RetryBackoffConfig = { initialInterval: 1, shouldRetry: () => true };
    const provider$ = coldObservableProvider({
      logger,
      onFatalError,
      provider: underlyingProvider,
      retryBackoffConfig
    });
    await expect(firstValueFrom(provider$)).resolves.toBe(testValue);
    await expect(firstValueFrom(provider$)).rejects.toThrow(EmptyError);
    expect(underlyingProvider).toBeCalledTimes(3);
    expect(onFatalError).toBeCalledWith(testError);
    expect(logger.messages).toStrictEqual([
      { level: 'error', message: [new Error(testErrorStr)] },
      { level: 'debug', message: ['Should retry: true'] },
      { level: 'error', message: [testError] },
      { level: 'debug', message: ['Should retry: true'] }
    ]);
  });

  it('polls the provider until the pollUntil condition is satisfied', async () => {
    const underlyingProvider = jest
      .fn()
      .mockResolvedValueOnce('a')
      .mockResolvedValueOnce('b')
      .mockResolvedValueOnce('c')
      .mockResolvedValue('Never reached');
    const backoffConfig: RetryBackoffConfig = { initialInterval: 1 };

    const provider$ = coldObservableProvider({
      logger,
      pollUntil: (v) => v === 'c',
      provider: underlyingProvider,
      retryBackoffConfig: backoffConfig
    });

    const providerValues: unknown[] = [];
    await lastValueFrom(provider$.pipe(tap((v) => providerValues.push(v))));
    expect(providerValues).toEqual(['a', 'b', 'c']);
    expect(underlyingProvider).toBeCalledTimes(3);
  });

  it('stops retrying after maxRetries attempts and handles the error in catchError', async () => {
    const testError = new Error(testErrorStr);
    const underlyingProvider = jest.fn().mockRejectedValue(testError);
    const maxRetries = 3;
    const retryBackoffConfig: RetryBackoffConfig = { initialInterval: 1, maxRetries };
    const onFatalError = jest.fn();

    const provider$ = coldObservableProvider({
      logger,
      onFatalError,
      provider: underlyingProvider,
      retryBackoffConfig
    });

    await expect(firstValueFrom(provider$)).rejects.toThrow(testError);

    expect(underlyingProvider).toBeCalledTimes(maxRetries + 1);
    expect(onFatalError).toBeCalledWith(expect.any(Error));
    expect(logger.messages).toStrictEqual([
      { level: 'error', message: [testError] },
      { level: 'error', message: [testError] },
      { level: 'error', message: [testError] }
    ]);
  });
});
