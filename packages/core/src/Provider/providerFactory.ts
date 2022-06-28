/**
 * ProviderFactory method interface.
 */
export interface ProviderFactoryMethod<T> {
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  (params: any): Promise<T>;
}

/**
 * Generic provider factory.
 */
export class ProviderFactory<T> {
  private _providers: Map<string, ProviderFactoryMethod<T>> = new Map<string, ProviderFactoryMethod<T>>();

  /**
   * Register a provider in this ProviderFactory.
   *
   * @param name The name of the provider.
   * @param providerFactoryMethod The provider factory method method.
   */
  public register(name: string, providerFactoryMethod: ProviderFactoryMethod<T>) {
    this._providers.set(name, providerFactoryMethod);
  }

  /**
   * Create a new faucet provider.
   *
   * @param name The name of the concrete facet provider implementation.
   * @param params The parameters to be passed to the concrete implementation constructor.
   * @returns The new Faucet provider.
   * @throws if The give provider name is not registered, or the constructor parameters of
   * the providers are either missing or invalid.
   */
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  public create(name: string, params: any): Promise<T> {
    if (!this._providers.has(name)) throw new Error(`Provider unsupported: ${name}`);

    return this._providers.get(name)!(params);
  }

  /**
   * Gets the list of registered providers.
   *
   * @returns The registered providers.
   */
  public getProviders(): Array<string> {
    return [...this._providers.keys()];
  }
}
