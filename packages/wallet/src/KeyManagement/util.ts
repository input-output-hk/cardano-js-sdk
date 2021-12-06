import * as bip39 from 'bip39';

/**
 * A wrapper around the bip39 package function, with default strength applied to produce 24 words
 */
export const mnemonicToWords = (mnemonic: string) => mnemonic.split(' ');
export const generateMnemonicWords = (strength = 256) => mnemonicToWords(bip39.generateMnemonic(strength));
export const joinMnemonicWords = (mnenomic: string[]) => mnenomic.join(' ');
export const entropyToMnemonicWords = (entropy: Buffer | string) => mnemonicToWords(bip39.entropyToMnemonic(entropy));
export const mnemonicWordsToEntropy = (mnenonic: string[]) => bip39.mnemonicToEntropy(joinMnemonicWords(mnenonic));

/**
 * A wrapper around the bip39 package function
 */
export const validateMnemonic = bip39.validateMnemonic;

export const harden = (num: number): number => 0x80_00_00_00 + num;
