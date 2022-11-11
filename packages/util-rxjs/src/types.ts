import { Observable } from 'rxjs';

export type ProviderMethod<Args extends unknown[], Return> = (...args: Args) => Promise<Return>;

export type ObservableProvider<T> = {
  [Key in keyof T]: T[Key] extends ProviderMethod<infer Args, infer Return>
    ? (...args: Args) => Observable<Return>
    : never;
};

export type ObservableProviders<T> = {
  [Key in keyof T]: ObservableProvider<T[Key]>;
};
