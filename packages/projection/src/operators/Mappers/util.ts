/**
 * Up to 100k transactions per block.
 * Fits in 64-bit signed integer.
 */
export const computeCompactTxId = (blockHeight: number, txIndex: number) => blockHeight * 100_000 + txIndex;
