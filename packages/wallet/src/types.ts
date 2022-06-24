import { Asset, Cardano, EpochInfo, NetworkInfo, ProtocolParametersRequiredByWallet } from '@cardano-sdk/core';
import { BalanceTracker, DelegationTracker, TransactionalObservables, TransactionsTracker } from './services';
import { Cip30DataSignature } from '@cardano-sdk/cip30';
import { Cip30SignDataRequest } from './KeyManagement/cip8';
import { GroupedAddress } from './KeyManagement';
import { Observable } from 'rxjs';
import { SelectionSkeleton } from '@cardano-sdk/cip2';
import { Shutdown } from '@cardano-sdk/util';
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

export interface OutputValidation {
  minimumCoin: Cardano.Lovelace;
  coinMissing: Cardano.Lovelace;
  tokenBundleSizeExceedsLimit: boolean;
}
export type MinimumCoinQuantityPerOutput = Map<Cardano.TxOut, OutputValidation>;

export interface InitializeTxPropsValidationResult {
  minimumCoinQuantities: MinimumCoinQuantityPerOutput;
}

export type InitializeTxResult = TxInternals & { inputSelection: SelectionSkeleton };

export type SignDataProps = Omit<Cip30SignDataRequest, 'keyAgent'>;

export interface SyncStatus extends Shutdown {
  /**
   * Emits:
   * - `true` while waiting for any provider request to resolve
   * - `false` while there are no provider requests waiting to resolve
   */
  isAnyRequestPending$: Observable<boolean>;
  /**
   * Emits after wallet makes at least one request with each relevant provider method:
   * - `false` on load
   * - `true` when all provider requests resolve
   * - `false` when some provider request(s) do not resolve for some time (determined by specific wallet implementation)
   */
  isUpToDate$: Observable<boolean>;
  /**
   * Emits after wallet makes at least one request with each relevant provider method:
   * - `false` on load
   * - `true` while there are no provider requests waiting to resolve
   * - `false` while waiting for any provider request to resolve
   */
  isSettled$: Observable<boolean>;
}

export interface ObservableWallet {
  readonly balance: BalanceTracker;
  readonly delegation: DelegationTracker;
  readonly utxo: TransactionalObservables<Cardano.Utxo[]>;
  readonly transactions: TransactionsTracker;
  readonly tip$: Observable<Cardano.Tip>;
  readonly genesisParameters$: Observable<Cardano.CompactGenesis>;
  readonly networkInfo$: Observable<NetworkInfo>;
  readonly currentEpoch$: Observable<EpochInfo>;
  readonly protocolParameters$: Observable<ProtocolParametersRequiredByWallet>;
  readonly addresses$: Observable<GroupedAddress[]>;
  readonly assets$: Observable<Assets>;
  readonly syncStatus: SyncStatus;

  getName(): Promise<string>;
  /**
   * @throws InputSelectionError
   */
  initializeTx(props: InitializeTxProps): Promise<InitializeTxResult>;
  finalizeTx(props: TxInternals, auxiliaryData?: Cardano.AuxiliaryData): Promise<Cardano.NewTxAlonzo>;
  /**
   * @throws Cip30DataSignError
   */
  signData(props: SignDataProps): Promise<Cip30DataSignature>;
  /**
   * @throws {Cardano.TxSubmissionError}
   */
  submitTx(tx: Cardano.NewTxAlonzo): Promise<void>;
  shutdown(): void;
}
