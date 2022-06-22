/**
 * Factory method interface.
 */
export interface FactoryMethod<T> {
    (params: any): T;
}

/**
 * Faucet provider factories.
 */
export class Factory<T> {

    private _providers: Map<string, FactoryMethod<T>> = new Map<string, FactoryMethod<T>>();

    // Singleton instance.
    private static _instance: any = null;

    /**
     * Prevents direct instantiation.
     */
    private constructor() {
    }
    
    /**
     * Gets a reference to the static factory.
     * 
     * @returns The factory. 
     */
    public static get<T>() : Factory<T> {

        if (this._instance == null) {
            this._instance = new Factory<T>();
        }

        return this._instance;
    }

    /**
     * Register a provider in this factory.
     * 
     * @param name The name of the provider.
     * @param factoryMethod The factory method.
     */
    public register(name: string, factoryMethod : FactoryMethod<T>) {
        this._providers.set(name, factoryMethod);
    }

    /**
     * Create a new faucet provider.
     * 
     * @param name The name of the concrete facet provider implementation.
     * @param params The parameters to be passed to the concrete implementation constructor.
     * 
     * @returns The new Faucet provider.
     * 
     * @throws if The give provider name is not registered, or the constructor parameters of the providers are either missing or invalid.
     */
    public create(name: string, params: any): T {

        if (!this._providers.has(name))
            throw new Error(`Provider unsupported: ${name}`);

        if (!this._providers.get(name))
            throw new Error(`Provider is undefined: ${name}`);
            
        return this._providers.get(name)!(params);
    }

    /**
     * Gets the list of registered providers.
     * 
     * @return The registered providers.
     */
    public getProviders(): Array<string> {
        
        return Array.from(this._providers.keys());
    }
}