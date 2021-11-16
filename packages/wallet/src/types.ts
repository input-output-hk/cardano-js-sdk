import { Balance, BehaviorObservable, DelegationTracker, TransactionalTracker, TransactionsTracker } from './services';
import { Cardano, NetworkInfo, ProtocolParametersRequiredByWallet } from '@cardano-sdk/core';
import { TxInternals } from './Transaction';

/** Internal = change address & External = receipt address */
export enum AddressType {
  /**
   * Change address
   */
  Internal = 'Internal',
  /**
   * Receipt address
   */
  External = 'External'
}

export interface Address {
  bech32: Cardano.Address;
  index: number;
  type: AddressType;
  accountIndex: number;
}

export type InitializeTxProps = {
  outputs?: Set<Cardano.TxOut>;
  certificates?: Cardano.Certificate[];
  withdrawals?: Cardano.Withdrawal[];
  options?: {
    validityInterval?: Cardano.ValidityInterval;
  };
};

export interface FinalizeTxProps {
  readonly body: Cardano.TxBodyAlonzo;
}

export interface Wallet {
  name: string;
  readonly balance: TransactionalTracker<Balance>;
  readonly delegation: DelegationTracker;
  readonly utxo: TransactionalTracker<Cardano.Utxo[]>;
  readonly transactions: TransactionsTracker;
  readonly tip$: BehaviorObservable<Cardano.Tip>;
  readonly genesisParameters$: BehaviorObservable<Cardano.CompactGenesis>;
  readonly networkInfo$: BehaviorObservable<NetworkInfo>;
  readonly protocolParameters$: BehaviorObservable<ProtocolParametersRequiredByWallet>;
  get addresses(): Address[];
  initializeTx(props: InitializeTxProps): Promise<TxInternals>;
  finalizeTx(props: TxInternals): Promise<Cardano.NewTxAlonzo>;
  submitTx(tx: Cardano.NewTxAlonzo): Promise<void>;
  sync(): void;
  shutdown(): void;
}
