import {
  Asset,
  Cardano,
  EpochInfo,
  EraSummary,
  HandleResolution,
  NetworkInfoProvider,
  TxCBOR
} from '@cardano-sdk/core';
import { BalanceTracker, DelegationTracker, TransactionsTracker, UtxoTracker } from './services';
import { Cip30DataSignature } from '@cardano-sdk/dapp-connector';
import { GroupedAddress, cip8 } from '@cardano-sdk/key-management';
import { InitializeTxProps, InitializeTxResult, SignedTx, TxBuilder, TxContext } from '@cardano-sdk/tx-construction';
import { Observable } from 'rxjs';
import { Shutdown } from '@cardano-sdk/util';

export type Assets = Map<Cardano.AssetId, Asset.AssetInfo>;

export type SignDataProps = Omit<cip8.Cip30SignDataRequest, 'keyAgent'>;

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

export type FinalizeTxProps = Omit<TxContext, 'ownAddresses'> & {
  tx: Cardano.TxBodyWithHash;
};

export type HandleInfo = HandleResolution & Asset.AssetInfo;

export interface ObservableWallet {
  readonly balance: BalanceTracker;
  readonly delegation: DelegationTracker;
  readonly utxo: UtxoTracker;
  readonly transactions: TransactionsTracker;
  readonly tip$: Observable<Cardano.Tip>;
  readonly genesisParameters$: Observable<Cardano.CompactGenesis>;
  readonly eraSummaries$: Observable<EraSummary[]>;
  readonly currentEpoch$: Observable<EpochInfo>;
  readonly protocolParameters$: Observable<Cardano.ProtocolParameters>;
  readonly addresses$: Observable<GroupedAddress[]>;
  readonly handles$: Observable<HandleInfo[]>;
  /** All owned and historical assets */
  readonly assetInfo$: Observable<Assets>;
  /**
   * This is the catch all Observable for fatal errors emitted by the Wallet.
   * Once errors are emitted, probably the only available recovery action is to
   * shutdown the Wallet and to create a new one.
   */
  readonly fatalError$: Observable<unknown>;
  readonly syncStatus: SyncStatus;

  getName(): Promise<string>;
  /**
   * @deprecated Use `createTxBuilder()` instead.
   * @throws InputSelectionError
   */
  initializeTx(props: InitializeTxProps): Promise<InitializeTxResult>;
  /** @deprecated Use `createTxBuilder()` instead. */
  finalizeTx(props: FinalizeTxProps): Promise<Cardano.Tx>;
  /**
   * @throws Cip30DataSignError
   */
  signData(props: SignDataProps): Promise<Cip30DataSignature>;
  /**
   * @throws CardanoNodeErrors.TxSubmissionError
   */
  submitTx(tx: Cardano.Tx | TxCBOR | SignedTx): Promise<Cardano.TransactionId>;

  /**
   * Create a TxBuilder from this wallet
   */
  createTxBuilder(): TxBuilder;

  shutdown(): void;
}

export type WalletNetworkInfoProvider = Pick<
  NetworkInfoProvider,
  'protocolParameters' | 'ledgerTip' | 'genesisParameters' | 'eraSummaries'
>;
