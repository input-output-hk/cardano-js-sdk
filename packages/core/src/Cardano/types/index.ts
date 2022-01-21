import * as Ogmios from '@cardano-ogmios/schema';
import { CustomError } from 'ts-custom-error';
import { util } from '../../util';

export { Epoch, Slot, ExUnits } from '@cardano-ogmios/schema';
export { Hash32ByteBase16, Hash28ByteBase16 } from '../util';
export * from './Address';
export * from './RewardAccount';
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
export * from './Key';
export * as TxSubmissionErrors from './TxSubmissionErrors';
export * as NativeScriptType from './NativeScriptType';

export type TxSubmissionError = CustomError;

export type ProtocolParametersAlonzo = util.OptionalUndefined<
  util.RecursivelyReplaceNullWithUndefined<Ogmios.ProtocolParametersAlonzo>
>;
export type ValidityInterval = util.OptionalUndefined<
  util.RecursivelyReplaceNullWithUndefined<Ogmios.ValidityInterval>
>;
