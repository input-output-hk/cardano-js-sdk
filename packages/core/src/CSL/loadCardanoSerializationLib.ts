export const isNodeJs = (): boolean => {
  try {
    return !!process;
  } catch {
    return false;
  }
};

export type CardanoSerializationLib = typeof import('@emurgo/cardano-serialization-lib-nodejs');

/**
 * Dynamically loads the environment-specific library.
 * The type of each complete library is the same.
 */
export const loadCardanoSerializationLib = (): Promise<CardanoSerializationLib> =>
  isNodeJs() ? import('@emurgo/cardano-serialization-lib-nodejs') : import('@emurgo/cardano-serialization-lib-browser');
