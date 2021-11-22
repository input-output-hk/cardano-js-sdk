import * as Ogmios from '@cardano-ogmios/schema';
import { util } from '../../util';

export {
  Address,
  Hash16,
  Hash64,
  Epoch,
  Tip,
  PoolMetadata,
  PoolId,
  Slot,
  ExUnits,
  RewardAccount
} from '@cardano-ogmios/schema';
export * from './StakePool';
export * from './ExtendedStakePoolMetadata';
export * from './Utxo';
export * from './Value';
export * from './DelegationsAndRewards';
export * from './Transaction';
export * from './Certificate';
export * from './Genesis';
export * from './Block';
export * from './Asset';
export * from './AuxiliaryData';

export type Ed25519KeyHashBech32 = string;

export type ProtocolParametersAlonzo = util.OptionalUndefined<
  util.RecursivelyReplaceNullWithUndefined<Ogmios.ProtocolParametersAlonzo>
>;
export type ValidityInterval = util.OptionalUndefined<
  util.RecursivelyReplaceNullWithUndefined<Ogmios.ValidityInterval>
>;
