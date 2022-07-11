import { BehaviorSubject, EmptyError, Subject, firstValueFrom } from 'rxjs';
import { RetryBackoffConfig, retryBackoff } from 'backoff-rxjs';
import { coldObservableProvider } from '../../../src';

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
    expect(retryBackoff).toBeCalledWith(backoffConfig);
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
});
