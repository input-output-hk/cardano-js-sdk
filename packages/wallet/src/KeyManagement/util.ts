import * as bip39 from 'isomorphic-bip39';

/**
 * A wrapper around the bip39 package function, with default strength applied to produce 24 words
 */
export const generateMnemonic = (strength = 256) => bip39.generateMnemonic(strength);

/**
 * A wrapper around the bip39 package function
 */
export const validateMnemonic = bip39.validateMnemonic;

export const harden = (num: number): number => 0x80_00_00_00 + num;
