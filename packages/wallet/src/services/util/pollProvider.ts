import { PollProps, poll } from '@cardano-sdk/util-rxjs';
import { ProviderError, ProviderFailure } from '@cardano-sdk/core';
import { catchError } from 'rxjs';

export type PollProviderProps<T> = Omit<PollProps<T>, 'retryBackoffConfig'> & {
  retryBackoffConfig: Omit<PollProps<T>['retryBackoffConfig'], 'shouldRetry'>;
};

export const pollProvider = <T>(props: PollProviderProps<T>) =>
  poll({
    ...props,
    retryBackoffConfig: {
      ...props.retryBackoffConfig,
      shouldRetry: (error) => {
        if (error instanceof ProviderError) {
          return ![ProviderFailure.NotImplemented, ProviderFailure.BadRequest].includes(error.reason);
        }
        return false;
      }
    }
  }).pipe(
    catchError((error) => {
      if (error instanceof ProviderError) {
        throw error;
      }
      throw new ProviderError(ProviderFailure.Unknown, error);
    })
  );
