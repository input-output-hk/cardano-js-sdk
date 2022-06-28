/* eslint-disable no-console */
import { KeyManagement } from '@cardano-sdk/wallet';

/**
 * Generates a new set of Mnemonic words and prints them to the console.
 */
let mnemonic = '';

for (const word of KeyManagement.util.generateMnemonicWords()) mnemonic += `${word} `;

console.log('');
console.log(mnemonic);
console.log('');
