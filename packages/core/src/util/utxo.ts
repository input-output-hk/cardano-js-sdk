export const createUtxoId = (txHash: string, index: number) => `${txHash}:${index}`;
