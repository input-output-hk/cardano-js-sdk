import type { Logger } from 'ts-log';

/** ProviderFactory method interface. */
export interface ProviderFactoryMethod<T> {
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  (params: any, logger: Logger): Promise<T>;
}

/** Generic provider factory. */
export class ProviderFactory<T> {
  #providers: Map<string, ProviderFactoryMethod<T>> = new Map<string, ProviderFactoryMethod<T>>();

  /**
   * Register a provider in this ProviderFactory.
   *
   * @param name The name of the provider.
   * @param providerFactoryMethod The provider factory method method.
   */
  public register(name: string, providerFactoryMethod: ProviderFactoryMethod<T>) {
    this.#providers.set(name, providerFactoryMethod);
  }

  /**
   * Create a new provider.
   *
   * @param name The name of the concrete provider implementation.
   * @param params The parameters to be passed to the concrete implementation constructor.
   * @param logger The logger instance to be used in the service.
   * @returns The new provider.
   * @throws if The give provider name is not registered, or the constructor parameters of
   * the providers are either missing or invalid.
   */
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  public create(name: string, params: any, logger: Logger): Promise<T> {
    if (!this.#providers.has(name)) throw new Error(`Provider unsupported: ${name}`);

    return this.#providers.get(name)!(params, logger);
  }

  /**
   * Gets the list of registered providers.
   *
   * @returns The registered providers.
   */
  public getProviders(): Array<string> {
    return [...this.#providers.keys()];
  }
}
