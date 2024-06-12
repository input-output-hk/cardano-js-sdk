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
import { Ed25519PublicKeyHex } from '@cardano-sdk/crypto';
import { GroupedAddress, MessageSender, SignTransactionContext, WitnessedTx, cip8 } from '@cardano-sdk/key-management';
import { HexBlob, Shutdown } from '@cardano-sdk/util';
import { InitializeTxProps, InitializeTxResult, TxBuilder, TxContext } from '@cardano-sdk/tx-construction';
import { Observable } from 'rxjs';
import { PubStakeKeyAndStatus } from './services/PublicStakeKeysTracker';

export type Assets = Map<Cardano.AssetId, Asset.AssetInfo>;

export type SignDataProps = Omit<cip8.Cip30SignDataRequest, 'knownAddresses' | 'witnesser'>;

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

export type FinalizeTxProps = Omit<TxContext, 'signingContext'> & {
  tx: Cardano.TxBodyWithHash;
  bodyCbor?: HexBlob;
  signingContext?: Partial<SignTransactionContext>;
};

export type UpdateWitnessProps = {
  tx: Cardano.Tx;
  sender?: MessageSender;
};

export type HandleInfo = HandleResolution & Asset.AssetInfo;

export interface ScriptAddress {
  networkId: Cardano.NetworkId;
  address: Cardano.PaymentAddress;
  rewardAccount: Cardano.RewardAccount;
  scripts: {
    payment: Cardano.NativeScript;
    stake: Cardano.NativeScript;
  };
}

export type WalletAddress = GroupedAddress | ScriptAddress;

export const isScriptAddress = (address: WalletAddress): address is ScriptAddress => 'scripts' in address;

export const isKeyHashAddress = (address: WalletAddress): address is GroupedAddress => !isScriptAddress(address);

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
  readonly addresses$: Observable<WalletAddress[]>;
  readonly publicStakeKeys$: Observable<PubStakeKeyAndStatus[]>;
  readonly handles$: Observable<HandleInfo[]>;
  readonly governance: {
    /** true this wallet is registered as drep */
    readonly isRegisteredAsDRep$: Observable<boolean>;
    /** Returns the wallet account's public DRep Key or undefined if the wallet doesn't control any DRep key */
    getPubDRepKey(): Promise<Ed25519PublicKeyHex | undefined>;
  };
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
  submitTx(tx: Cardano.Tx | TxCBOR | WitnessedTx): Promise<Cardano.TransactionId>;

  /** Create a TxBuilder from this wallet */
  createTxBuilder(): TxBuilder;

  /**
   * Discover addresses that might have been created by other applications.
   * This is run automatically when the wallet is first created.
   *
   * @returns Promise that resolves when discovery is complete, with an updated array of wallet addresses
   */
  discoverAddresses(): Promise<WalletAddress[]>;

  shutdown(): void;
}

export type WalletNetworkInfoProvider = Pick<
  NetworkInfoProvider,
  'protocolParameters' | 'ledgerTip' | 'genesisParameters' | 'eraSummaries'
>;
