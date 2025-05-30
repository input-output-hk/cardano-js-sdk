import sodium from 'libsodium-wrappers-sumo';

export * from './blake2b-hash';
export * from './Bip32';
export * from './Bip32Ed25519';
export * from './Ed25519e';
export * from './strategies';
export * from './hexTypes';
export * from './types';

/** This function must be awaited before calling any other function in this module. It is safe to await this function multiple times. */
export const ready = async (): Promise<void> => await sodium.ready;
