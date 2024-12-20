import { ProviderError, ProviderFailure } from '@cardano-sdk/core';
import { RetryBackoffConfig } from 'backoff-rxjs';
import { firstValueFrom } from 'rxjs';
import { logger } from '@cardano-sdk/util-dev';
import { pollProvider } from '../../../src';

describe('pollProvider', () => {
  it('retries retryable ProviderError', async () => {
    const sample = jest
      .fn()
      .mockRejectedValueOnce(new ProviderError(ProviderFailure.ConnectionFailure))
      .mockResolvedValue(true);
    const retryBackoffConfig: RetryBackoffConfig = { initialInterval: 1 };
    const values$ = pollProvider({ logger, retryBackoffConfig, sample });
    const resolvedValue = await firstValueFrom(values$);
    expect(sample).toBeCalledTimes(2);
    expect(resolvedValue).toBe(true);
  });

  it('does not retry non-retryable ProviderError', async () => {
    const sample = jest.fn().mockRejectedValueOnce(new ProviderError(ProviderFailure.BadRequest));
    const retryBackoffConfig: RetryBackoffConfig = { initialInterval: 1 };
    const values$ = pollProvider({ logger, retryBackoffConfig, sample });
    await expect(firstValueFrom(values$)).rejects.toThrowError(ProviderError);
    expect(sample).toBeCalledTimes(1);
  });

  it('does not retry errors other than ProviderError and wraps them in ProviderError', async () => {
    const sample = jest.fn().mockRejectedValueOnce(new Error('other error'));
    const retryBackoffConfig: RetryBackoffConfig = { initialInterval: 1 };
    const values$ = pollProvider({ logger, retryBackoffConfig, sample });
    await expect(firstValueFrom(values$)).rejects.toThrowError(ProviderError);
    expect(sample).toBeCalledTimes(1);
  });
});
