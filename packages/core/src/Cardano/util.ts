/**
 * Blockchain restriction for minimum coin quantity in a UTxO
 */
export const computeMinUtxoValue = (coinsPerUtxoWord: bigint): bigint => coinsPerUtxoWord * 29n;
