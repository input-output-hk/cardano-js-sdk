import { RetryBackoffConfig, retryBackoff } from 'backoff-rxjs';
import { coldObservableProvider } from '../../../src';
import { firstValueFrom } from 'rxjs';

// There might be a more elegant way to mock with original implementation (spy)
jest.mock('backoff-rxjs', () => ({
  retryBackoff: jest.fn().mockImplementation((...args) => jest.requireActual('backoff-rxjs').retryBackoff(...args))
}));

describe('coldObservableProvider', () => {
  it('returns an observable that calls underlying provider on each subscription and uses retryBackoff', async () => {
    const underlyingProvider = jest.fn().mockResolvedValue(true);
    const backoffConfig: RetryBackoffConfig = { initialInterval: 1 };
    const provider$ = coldObservableProvider(underlyingProvider, backoffConfig);
    expect(await firstValueFrom(provider$)).toBe(true);
    expect(await firstValueFrom(provider$)).toBe(true);
    expect(underlyingProvider).toBeCalledTimes(2);
    expect(retryBackoff).toBeCalledTimes(2);
    expect(retryBackoff).toBeCalledWith(backoffConfig);
  });
});
