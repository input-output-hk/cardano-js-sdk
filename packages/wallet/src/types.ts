import { Asset, Cardano, NetworkInfo, ProtocolParametersRequiredByWallet, TimeSettings } from '@cardano-sdk/core';
import { Balance, BehaviorObservable, DelegationTracker, TransactionalTracker, TransactionsTracker } from './services';
import { GroupedAddress } from './KeyManagement';
import { SelectionSkeleton } from '@cardano-sdk/cip2';
import { TxInternals } from './Transaction';

export type InitializeTxProps = {
  outputs?: Set<Cardano.TxOut>;
  certificates?: Cardano.Certificate[];
  withdrawals?: Cardano.Withdrawal[];
  auxiliaryData?: Cardano.AuxiliaryData;
  options?: {
    validityInterval?: Cardano.ValidityInterval;
  };
};

export interface FinalizeTxProps {
  readonly body: Cardano.TxBodyAlonzo;
}

export type Assets = Map<Cardano.AssetId, Asset.AssetInfo>;

export interface MinimumCoinQuantity {
  minimumCoin: Cardano.Lovelace;
  coinMissing: Cardano.Lovelace;
}
export type MinimumCoinQuantityPerOutput = Map<Cardano.TxOut, MinimumCoinQuantity>;

export interface InitializeTxPropsValidationResult {
  minimumCoinQuantities: MinimumCoinQuantityPerOutput;
}

export type InitializeTxResult = TxInternals & { inputSelection: SelectionSkeleton };

export interface Wallet {
  name: string;
  readonly balance: TransactionalTracker<Balance>;
  readonly delegation: DelegationTracker;
  readonly utxo: TransactionalTracker<Cardano.Utxo[]>;
  readonly transactions: TransactionsTracker;
  readonly tip$: BehaviorObservable<Cardano.Tip>;
  readonly timeSettings$: BehaviorObservable<TimeSettings[]>;
  readonly genesisParameters$: BehaviorObservable<Cardano.CompactGenesis>;
  readonly networkInfo$: BehaviorObservable<NetworkInfo>;
  readonly protocolParameters$: BehaviorObservable<ProtocolParametersRequiredByWallet>;
  readonly addresses$: BehaviorObservable<GroupedAddress[]>;
  readonly assets$: BehaviorObservable<Assets>;
  /**
   * Compute minimum coin quantity for each transaction output
   */
  validateInitializeTxProps(props: InitializeTxProps): Promise<InitializeTxPropsValidationResult>;
  /**
   * @throws InputSelectionError
   */
  initializeTx(props: InitializeTxProps): Promise<InitializeTxResult>;
  finalizeTx(props: TxInternals): Promise<Cardano.NewTxAlonzo>;
  /**
   * @throws {Cardano.TxSubmissionError}
   */
  submitTx(tx: Cardano.NewTxAlonzo): Promise<void>;
  sync(): void;
  shutdown(): void;
}
