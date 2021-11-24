import * as Ogmios from '@cardano-ogmios/schema';
import { CustomError } from 'ts-custom-error';
import { util } from '../../util';

export {
  Address,
  Hash16,
  Hash64,
  Epoch,
  Tip,
  PoolMetadata,
  Slot,
  ExUnits,
  RewardAccount
} from '@cardano-ogmios/schema';
export * from './StakePool';
export * from './Utxo';
export * from './Value';
export * from './DelegationsAndRewards';
export * from './Transaction';
export * from './Certificate';
export * from './Genesis';
export * from './Block';
export * from './Asset';
export * from './AuxiliaryData';
export * as TxSubmissionErrors from './TxSubmissionErrors';

export type TxSubmissionError = CustomError;

export type ProtocolParametersAlonzo = util.OptionalUndefined<
  util.RecursivelyReplaceNullWithUndefined<Ogmios.ProtocolParametersAlonzo>
>;
export type ValidityInterval = util.OptionalUndefined<
  util.RecursivelyReplaceNullWithUndefined<Ogmios.ValidityInterval>
>;
