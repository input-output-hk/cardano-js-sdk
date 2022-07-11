import * as Ogmios from '@cardano-ogmios/schema';
import { OptionalUndefined, RecursivelyReplaceNullWithUndefined } from '@cardano-sdk/util';

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
export * from './TxSubmissionErrors';
export * as NativeScriptType from './NativeScriptType';

export type ProtocolParametersBabbage = OptionalUndefined<
  RecursivelyReplaceNullWithUndefined<Ogmios.ProtocolParametersBabbage>
>;
export type ValidityInterval = OptionalUndefined<RecursivelyReplaceNullWithUndefined<Ogmios.ValidityInterval>>;
