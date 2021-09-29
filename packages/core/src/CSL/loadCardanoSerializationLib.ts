export const isNodeJs = (): boolean => typeof process !== 'undefined' && !!process.versions && !!process.versions.node;

export type CardanoSerializationLib = typeof import('./browser');

/**
 * Dynamically loads the environment-specific library.
 * The type of each complete library is the same.
 */
export const loadCardanoSerializationLib = (): Promise<CardanoSerializationLib> =>
  isNodeJs() ? import('./nodejs') : import('./browser');
