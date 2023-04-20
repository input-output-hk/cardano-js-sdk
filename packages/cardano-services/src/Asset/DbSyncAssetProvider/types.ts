export interface LastMintTxModel {
  tx_hash: Buffer;
}

export interface MultiAssetModel {
  count: string;
  fingerprint: string;
  sum: string;
}

export interface MultiAssetHistoryModel {
  hash: Buffer;
  quantity: string;
}
