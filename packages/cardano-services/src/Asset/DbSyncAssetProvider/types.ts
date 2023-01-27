export interface LastMintTxModel {
  tx_hash: Buffer;
}

export interface MultiAssetModel {
  fingerprint: string;
  id: string;
}

export interface MultiAssetHistoryModel {
  hash: Buffer;
  quantity: string;
}

export interface MultiAssetQuantitiesModel {
  count: string;
  sum: string;
}
