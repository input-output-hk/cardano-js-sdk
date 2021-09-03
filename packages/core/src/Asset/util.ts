export const policyIdFromAssetId = (assetId: string): string => assetId.slice(0, 56);

export const assetNameFromAssetId = (assetId: string): string => assetId.slice(56);
