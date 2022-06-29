import { HealthCheckResponse, Provider } from '../../src/Provider/Provider';
import { ProviderFactory } from '../../src';

// Mock providers.

/**
 * Mock provider A.
 */
class MockProviderA implements Provider {
  /**
   * Dummy health check method.
   */
  healthCheck(): Promise<HealthCheckResponse> {
    return new Promise<HealthCheckResponse>(async (resolve) => {
      resolve({ ok: true });
    });
  }

  /**
   * Factory method for the provider.
   *
   * @returns a new provider A.
   */
  static create(): Promise<Provider> {
    return new Promise<Provider>(async (resolve) => {
      resolve(new MockProviderA());
    });
  }
}

/**
 * Mock provider B.
 */
class MockProviderB implements Provider {
  /**
   * Dummy health check method.
   */
  healthCheck(): Promise<HealthCheckResponse> {
    return new Promise<HealthCheckResponse>(async (resolve) => {
      resolve({ ok: false });
    });
  }

  /**
   * Factory method for the provider.
   *
   * @returns a new provider B.
   */
  static create(): Promise<Provider> {
    return new Promise<Provider>(async (resolve) => {
      resolve(new MockProviderB());
    });
  }
}

describe('ProviderFactory', () => {
  it('can register several providers', async () => {
    // Arrange
    const factory = new ProviderFactory<Provider>();

    // Act
    factory.register(MockProviderA.name, MockProviderA.create);
    factory.register(MockProviderB.name, MockProviderB.create);

    // Assert
    expect(factory.getProviders().length).toEqual(2);
    expect(factory.getProviders()).toEqual(expect.arrayContaining([MockProviderA.name, MockProviderB.name]));
  });

  it('can create a registered provider', async () => {
    // Arrange
    const factory = new ProviderFactory<Provider>();

    factory.register(MockProviderA.name, MockProviderA.create);
    factory.register(MockProviderB.name, MockProviderB.create);

    // Act
    const providerA: Provider = await factory.create(MockProviderA.name, {});
    const providerB: Provider = await factory.create(MockProviderB.name, {});

    const resultA = await providerA.healthCheck();
    const resultB = await providerB.healthCheck();

    // Assert
    expect(resultA.ok).toEqual(true);
    expect(resultB.ok).toEqual(false);
  });

  it('throws if requested provider is not supported', async () => {
    // Arrange
    const factory = new ProviderFactory<Provider>();

    // Assert
    expect(() => factory.create(MockProviderA.name, {})).toThrow(`Provider unsupported: ${MockProviderA.name}`);
  });
});
