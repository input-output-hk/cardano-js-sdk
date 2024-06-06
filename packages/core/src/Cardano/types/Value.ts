import type { AssetId } from './Asset.js';

export type Lovelace = bigint;

/** `{[assetId]: amount}` */
export type TokenMap = Map<AssetId, bigint>;

/** Total quantities of Coin and Assets in a Value. */
export interface Value {
  coins: Lovelace;
  assets?: TokenMap;
}

export type PositiveCoin<T extends bigint> = bigint extends T
  ? never
  : `${T}` extends `-${string}` | `${string}.${string}`
  ? never
  : T;
