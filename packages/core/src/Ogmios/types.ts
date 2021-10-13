import { PoolId, Value as _OgmiosValue } from '@cardano-ogmios/schema';

export type Lovelace = bigint;

/**
 * {[assetId]: amount}
 */
export type TokenMap = NonNullable<_OgmiosValue['assets']>;

/**
 * Total quantities of Coin and Assets in a Value.
 * TODO: Use Ogmios Value type after it changes lovelaces to bigint;
 */
export interface Value {
  coins: Lovelace;
  assets?: TokenMap;
}

/**
 * TODO: Use Ogmios type after it changes lovelaces to bigint;
 */
export interface DelegationsAndRewards {
  delegate?: PoolId;
  rewards?: Lovelace;
}
