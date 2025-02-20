/** Node.js environment configurations. */
export enum Environment {
  /**
   * Production environment.
   *
   * Node.js assumes it's always running in a development environment. You can signal Node.js that you are running
   * in production by setting the NODE_ENV=production environment variable.
   */
  Production = 'production',

  /** Development environment. */
  Development = 'development'
}

export const isProductionEnvironment = (): boolean => process.env.NODE_ENV === Environment.Production;

export const getEnvironmentConfiguration = (): Environment =>
  isProductionEnvironment() ? Environment.Production : Environment.Development;

/**
 * Chrome extensions use a service worker that does not have a window object.
 * Firefox addons use a generated background page to run the background script, so they have a window object
 *
 * @returns {boolean} True if the script is running in a background/service worker process, false otherwise.
 */
export const isBackgroundProcess = () =>
  typeof window === 'undefined' || window.location.href.includes('_generated_background');
