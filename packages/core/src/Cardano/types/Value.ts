import { AssetId } from './Asset';

export type Lovelace = bigint;

/**
 * `{[assetId]: amount}`
 */
export type TokenMap = Map<AssetId, bigint>;

/**
 * Total quantities of Coin and Assets in a Value.
 */
export interface Value {
  coins: Lovelace;
  assets?: TokenMap;
}
