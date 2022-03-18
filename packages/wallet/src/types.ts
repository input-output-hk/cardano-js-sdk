import { Asset, Cardano, NetworkInfo, ProtocolParametersRequiredByWallet, TimeSettings } from '@cardano-sdk/core';
import { Balance, BehaviorObservable, DelegationTracker, TransactionalTracker, TransactionsTracker } from './services';
import { Cip30DataSignature, Cip30SignDataRequest } from './KeyManagement/cip8';
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

export type SignDataProps = Omit<Cip30SignDataRequest, 'keyAgent'>;

export interface SyncStatus {
  /**
   * Emits:
   * - `true` while waiting for any provider request to resolve
   * - `false` while there are no provider requests waiting to resolve
   */
  isAnyRequestPending$: BehaviorObservable<boolean>;
  /**
   * Emits after wallet makes at least one request with each relevant provider method:
   * - `false` on load
   * - `true` when all provider requests resolve
   * - `false` when some provider request(s) do not resolve for some time (determined by specific wallet implementation)
   */
  isUpToDate$: BehaviorObservable<boolean>;
  /**
   * Emits after wallet makes at least one request with each relevant provider method:
   * - `false` on load
   * - `true` while there are no provider requests waiting to resolve
   * - `false` while waiting for any provider request to resolve
   */
  isSettled$: BehaviorObservable<boolean>;
}

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
  readonly syncStatus: SyncStatus;
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
   * @throws Cip30DataSignError
   */
  signData(props: SignDataProps): Promise<Cip30DataSignature>;
  /**
   * @throws {Cardano.TxSubmissionError}
   */
  submitTx(tx: Cardano.NewTxAlonzo): Promise<void>;
  sync(): void;
  shutdown(): void;
}
