/* eslint-disable @typescript-eslint/no-explicit-any */
import { from } from 'rxjs';

import { ObservableProvider, ObservableProviders } from './types';

export const toObservableProvider = <Provider extends {}>(provider: Provider): ObservableProvider<Provider> =>
  Object.keys(provider).reduce(
    (result, key) => ({
      ...result,
      [key]: (...args: any[]) => from((provider as any)[key](...args))
    }),
    {} as any
  );

export const toObservableProviders = <T extends {}>(providers: T): ObservableProviders<T> =>
  Object.keys(providers).reduce(
    (result, key) => ({
      ...result,
      [key]: toObservableProvider((providers as any)[key])
    }),
    {} as any
  );
