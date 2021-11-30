import { AssetId } from './Asset';
import { Value as _OgmiosValue } from '@cardano-ogmios/schema';

export type Lovelace = bigint;

/**
 * {[assetId]: amount}
 */
export type TokenMap = Map<AssetId, bigint>;

/**
 * Total quantities of Coin and Assets in a Value.
 */
export interface Value {
  coins: Lovelace;
  assets?: TokenMap;
}
