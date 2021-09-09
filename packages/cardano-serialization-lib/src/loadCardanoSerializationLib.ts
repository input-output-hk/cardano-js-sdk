import CardanoSerializationLibNodeJs from '@emurgo/cardano-serialization-lib-nodejs';

export const isNodeJs = (): boolean => {
  try {
    return !!process;
  } catch {
    return false;
  }
};

/**
 * Loads the environment-specific library.
 * The type of each complete library is the same, so one is statically imported for the return type.
 * Dynamically loads the browser library.
 */
export const loadCardanoSerializationLib = async (): Promise<typeof CardanoSerializationLibNodeJs> =>
  isNodeJs() ? CardanoSerializationLibNodeJs : await import('@emurgo/cardano-serialization-lib-browser');
