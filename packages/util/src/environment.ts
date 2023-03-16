/**
 * Node.js environment configurations.
 */
export enum Environment {
  /**
   * Production environment.
   *
   * Node.js assumes it's always running in a development environment. You can signal Node.js that you are running
   * in production by setting the NODE_ENV=production environment variable.
   */
  Production = 'production',

  /**
   * Development environment.
   */
  Development = 'development'
}

export const isProductionEnvironment = (): boolean => process.env.NODE_ENV === Environment.Production;

export const getEnvironmentConfiguration = (): Environment =>
  isProductionEnvironment() ? Environment.Production : Environment.Development;
