import { ProviderFactory } from '../../src';

// Mock providers.

/**
 * Provider interface.
 */
interface Provider {
  getName(): string;
}

/**
 * Mock provider A.
 */
class MockProviderA implements IProvider {
  /**
   * Dummy provider method.
   *
   * @returns The provider name.
   */
  getName() {
    return 'A';
  }

  /**
   * Factory method for the provider.
   *
   * @returns a new provider A.
   */
  static create(): Promise<IProvider> {
    return new Promise<IProvider>(async (resolve) => {
      resolve(new MockProviderA());
    });
  }
}

/**
 * Mock provider B.
 */
class MockProviderB implements IProvider {
  /**
   * Dummy provider method.
   *
   * @returns The provider name.
   */
  getName() {
    return 'B';
  }

  /**
   * Factory method for the provider.
   *
   * @returns a new provider B.
   */
  static create(): Promise<IProvider> {
    return new Promise<IProvider>(async (resolve) => {
      resolve(new MockProviderB());
    });
  }
}

describe('ProviderFactory', () => {
  it('can register several providers', async () => {
    // Arrange.
    const factory = new ProviderFactory<IProvider>();

    // Act
    factory.register(MockProviderA.name, MockProviderA.create);
    factory.register(MockProviderB.name, MockProviderB.create);

    // Assert
    expect(factory.getProviders().length).toEqual(2);
    expect(factory.getProviders()).toEqual(expect.arrayContaining([MockProviderA.name, MockProviderB.name]));
  });

  it('can create a registered provider', async () => {
    // Arrange.
    const factory = new ProviderFactory<IProvider>();

    // Act
    factory.register(MockProviderA.name, MockProviderA.create);
    factory.register(MockProviderB.name, MockProviderB.create);

    const providerA: IProvider = await factory.create(MockProviderA.name, {});
    const providerB: IProvider = await factory.create(MockProviderB.name, {});

    // Assert
    expect(providerA.getName()).toEqual('A');
    expect(providerB.getName()).toEqual('B');
  });

  it('throws if requested provider is not supported', async () => {
    // Arrange.
    const factory = new ProviderFactory<IProvider>();

    // Assert
    expect(() => factory.create(MockProviderA.name, {})).toThrow(`Provider unsupported: ${MockProviderA.name}`);
  });
});
