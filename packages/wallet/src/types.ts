import {
  Balance,
  BehaviorObservable,
  ProviderSubscription,
  SourceTransactionalTracker,
  TransactionalTracker,
  Transactions
} from './services';
import { Cardano, ProtocolParametersRequiredByWallet } from '@cardano-sdk/core';
import { TxInternals } from './Transaction';

// Review: this is not used anywhere. Should we use this instead of string for address in the wallet?
// /** internal = change address & external = receipt address */
// export enum AddressType {
//   internal = 'Internal',
//   external = 'External'
// }
// export interface Address {
//   address: string;
//   index: number;
//   type: AddressType;
//   accountIndex: number;
// }

export type InitializeTxProps = {
  outputs: Set<Cardano.TxOut>;
  certificates?: Cardano.Certificate[];
  withdrawals?: Cardano.Withdrawal[];
  options?: {
    validityInterval?: Cardano.ValidityInterval;
  };
};

export interface FinalizeTxProps {
  readonly body: Cardano.TxBodyAlonzo;
}

export interface Wallet extends ProviderSubscription {
  name: string;
  readonly balance: TransactionalTracker<Balance>;
  readonly utxo: SourceTransactionalTracker<Cardano.Utxo[]>;
  readonly transactions: Transactions;
  readonly tip$: BehaviorObservable<Cardano.Tip>;
  readonly protocolParameters$: BehaviorObservable<ProtocolParametersRequiredByWallet>;
  get addresses(): Cardano.Address[];
  initializeTx(props: InitializeTxProps): Promise<TxInternals>;
  finalizeTx(props: TxInternals): Promise<Cardano.NewTxAlonzo>;
  submitTx(tx: Cardano.NewTxAlonzo): Promise<void>;
}
