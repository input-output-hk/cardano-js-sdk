import { BehaviorSubject, EmptyError, Subject, firstValueFrom, lastValueFrom, tap } from 'rxjs';
import { InvalidStringError } from '@cardano-sdk/util';
import { coldObservableProvider } from '../src/index.js';
import { retryBackoff } from 'backoff-rxjs';
import type { RetryBackoffConfig } from 'backoff-rxjs';

// There might be a more elegant way to mock with original implementation (spy)
jest.mock('backoff-rxjs', () => ({
  retryBackoff: jest.fn().mockImplementation((...args) => jest.requireActual('backoff-rxjs').retryBackoff(...args))
}));

describe('coldObservableProvider', () => {
  it('returns an observable that calls underlying provider on each subscription and uses retryBackoff', async () => {
    const underlyingProvider = jest.fn().mockResolvedValue(true);
    const backoffConfig: RetryBackoffConfig = { initialInterval: 1 };
    const provider$ = coldObservableProvider({ provider: underlyingProvider, retryBackoffConfig: backoffConfig });
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
    const provider$ = coldObservableProvider({ provider: underlyingProvider, retryBackoffConfig });
    const resolvedValue = await firstValueFrom(provider$);
    expect(underlyingProvider).toBeCalledTimes(2);
    expect(resolvedValue).toBeTruthy();
  });

  it('does not retry, when underlying provider rejects with InvalidStringError', async () => {
    const testValue = { test: 'value' };
    const testError = new InvalidStringError('Test invalid string error');
    const underlyingProvider = jest
      .fn()
      .mockRejectedValueOnce(new Error('Test error'))
      .mockResolvedValueOnce(testValue)
      .mockRejectedValueOnce(testError)
      .mockResolvedValueOnce(testValue);
    const onFatalError = jest.fn();
    const retryBackoffConfig: RetryBackoffConfig = { initialInterval: 1, shouldRetry: () => true };
    const provider$ = coldObservableProvider({
      onFatalError,
      provider: underlyingProvider,
      retryBackoffConfig
    });
    await expect(firstValueFrom(provider$)).resolves.toBe(testValue);
    await expect(firstValueFrom(provider$)).rejects.toThrow(EmptyError);
    expect(underlyingProvider).toBeCalledTimes(3);
    expect(onFatalError).toBeCalledWith(testError);
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
      pollUntil: (v) => v === 'c',
      provider: underlyingProvider,
      retryBackoffConfig: backoffConfig
    });

    const providerValues: unknown[] = [];
    await lastValueFrom(provider$.pipe(tap((v) => providerValues.push(v))));
    expect(providerValues).toEqual(['a', 'b', 'c']);
    expect(underlyingProvider).toBeCalledTimes(3);
  });
});
