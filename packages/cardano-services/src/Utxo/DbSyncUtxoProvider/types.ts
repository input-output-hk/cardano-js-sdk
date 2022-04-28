/*
 * There will be as much rows as tokens are in Value object
 */
export interface UtxoModel {
  address: string;
  coins: string;
  index: number;
  tx_id: string;
  asset_quantity?: string;
  asset_name?: string;
  asset_policy?: string;
  data_hash?: string;
}
