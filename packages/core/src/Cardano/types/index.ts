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
  AuxiliaryData
} from '@cardano-ogmios/schema';
export * from './StakePool';
export * from './ExtendedStakePoolMetadata';
export * from './Utxo';
export * from './Value';
export * from './DelegationsAndRewards';
export * from './Transaction';

export type ProtocolParametersAlonzo = util.OptionalUndefined<
  util.RecursivelyReplaceNullWithUndefined<Ogmios.ProtocolParametersAlonzo>
>;
export type ValidityInterval = util.OptionalUndefined<
  util.RecursivelyReplaceNullWithUndefined<Ogmios.ValidityInterval>
>;
