import { PoolId } from './StakePool';
import { Lovelace } from './Value';

/**
 * TODO: re-export Ogmios/DelegationsAndRewards type after it changes lovelaces to bigint;
 */
export interface DelegationsAndRewards {
  delegate?: PoolId;
  rewards?: Lovelace;
}
