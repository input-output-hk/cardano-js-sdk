import { AddressType, GroupedAddress, KeyAgent, util as keyManagementUtil } from './KeyManagement';
import {
  AssetProvider,
  Cardano,
  EpochInfo,
  NetworkInfo,
  NetworkInfoProvider,
  ProtocolParametersRequiredByWallet,
  StakePoolSearchProvider,
  TxSubmitProvider,
  UtxoProvider,
  WalletProvider,
  coreToCsl
} from '@cardano-sdk/core';
import {
  Assets,
  InitializeTxProps,
  InitializeTxResult,
  ObservableWallet,
  Shutdown,
  SignDataProps,
  SyncStatus
} from './types';
import {
  Balance,
  BehaviorObservable,
  DelegationTracker,
  FailedTx,
  PersistentDocumentTrackerSubject,
  PollingConfig,
  SyncableIntervalPersistentDocumentTrackerSubject,
  TrackedAssetProvider,
  TrackedNetworkInfoProvider,
  TrackedStakePoolSearchProvider,
  TrackedTxSubmitProvider,
  TrackedWalletProvider,
  TrackerSubject,
  TransactionFailure,
  TransactionalTracker,
  TransactionsTracker,
  WalletUtil,
  coldObservableProvider,
  createAssetsTracker,
  createBalanceTracker,
  createDelegationTracker,
  createProviderStatusTracker,
  createTransactionsTracker,
  createUtxoTracker,
  createWalletUtil,
  currentEpochTracker,
  deepEquals,
  distinctBlock,
  distinctTimeSettings
} from './services';
import { Cip30DataSignature, cip30signData } from './KeyManagement/cip8';
import { InputSelector, defaultSelectionConstraints, roundRobinRandomImprove } from '@cardano-sdk/cip2';
import { Logger, dummyLogger } from 'ts-log';
import { Observable, Subject, combineLatest, filter, lastValueFrom, map, take } from 'rxjs';
import { RetryBackoffConfig } from 'backoff-rxjs';
import { TrackedUtxoProvider } from './services/ProviderTracker/TrackedUtxoProvider';
import { TxInternals, createTransactionInternals, ensureValidityInterval } from './Transaction';
import { WalletStores, createInMemoryWalletStores } from './persistence';
import { isEqual } from 'lodash-es';

export interface SingleAddressWalletProps {
  readonly name: string;
  readonly polling?: PollingConfig;
  readonly retryBackoffConfig?: RetryBackoffConfig;
}

export interface SingleAddressWalletDependencies {
  readonly keyAgent: KeyAgent;
  readonly txSubmitProvider: TxSubmitProvider;
  readonly walletProvider: WalletProvider;
  readonly stakePoolSearchProvider: StakePoolSearchProvider;
  readonly assetProvider: AssetProvider;
  readonly networkInfoProvider: NetworkInfoProvider;
  readonly utxoProvider: UtxoProvider;
  readonly inputSelector?: InputSelector;
  readonly stores?: WalletStores;
  readonly logger?: Logger;
}

export class SingleAddressWallet implements ObservableWallet {
  #inputSelector: InputSelector;
  #logger: Logger;
  #tip$: SyncableIntervalPersistentDocumentTrackerSubject<Cardano.Tip>;
  #newTransactions = {
    failedToSubmit$: new Subject<FailedTx>(),
    pending$: new Subject<Cardano.NewTxAlonzo>(),
    submitting$: new Subject<Cardano.NewTxAlonzo>()
  };
  readonly keyAgent: KeyAgent;
  readonly currentEpoch$: BehaviorObservable<EpochInfo>;
  readonly txSubmitProvider: TrackedTxSubmitProvider;
  readonly walletProvider: TrackedWalletProvider;
  readonly utxoProvider: TrackedUtxoProvider;
  readonly networkInfoProvider: TrackedNetworkInfoProvider;
  readonly stakePoolSearchProvider: TrackedStakePoolSearchProvider;
  readonly assetProvider: TrackedAssetProvider;
  readonly utxo: TransactionalTracker<Cardano.Utxo[]>;
  readonly balance: TransactionalTracker<Balance>;
  readonly transactions: TransactionsTracker & Shutdown;
  readonly delegation: DelegationTracker & Shutdown;
  readonly tip$: BehaviorObservable<Cardano.Tip>;
  readonly networkInfo$: TrackerSubject<NetworkInfo>;
  readonly addresses$: TrackerSubject<GroupedAddress[]>;
  readonly protocolParameters$: TrackerSubject<ProtocolParametersRequiredByWallet>;
  readonly genesisParameters$: TrackerSubject<Cardano.CompactGenesis>;
  readonly assets$: TrackerSubject<Assets>;
  readonly syncStatus: SyncStatus;
  readonly name: string;
  readonly util: WalletUtil;

  constructor(
    {
      name,
      polling: {
        interval: pollInterval = 5000,
        maxInterval = pollInterval * 20,
        consideredOutOfSyncAfter = 1000 * 60 * 3
      } = {},
      retryBackoffConfig = {
        initialInterval: Math.min(pollInterval, 1000),
        maxInterval
      }
    }: SingleAddressWalletProps,
    {
      txSubmitProvider,
      walletProvider,
      stakePoolSearchProvider,
      keyAgent,
      assetProvider,
      networkInfoProvider,
      utxoProvider,
      logger = dummyLogger,
      inputSelector = roundRobinRandomImprove(),
      stores = createInMemoryWalletStores()
    }: SingleAddressWalletDependencies
  ) {
    this.#logger = logger;
    this.#inputSelector = inputSelector;
    this.txSubmitProvider = new TrackedTxSubmitProvider(txSubmitProvider);
    this.walletProvider = new TrackedWalletProvider(walletProvider);
    this.utxoProvider = new TrackedUtxoProvider(utxoProvider);
    this.networkInfoProvider = new TrackedNetworkInfoProvider(networkInfoProvider);
    this.stakePoolSearchProvider = new TrackedStakePoolSearchProvider(stakePoolSearchProvider);
    this.assetProvider = new TrackedAssetProvider(assetProvider);
    this.syncStatus = createProviderStatusTracker(
      {
        assetProvider: this.assetProvider,
        networkInfoProvider: this.networkInfoProvider,
        stakePoolSearchProvider: this.stakePoolSearchProvider,
        txSubmitProvider: this.txSubmitProvider,
        utxoProvider: this.utxoProvider,
        walletProvider: this.walletProvider
      },
      { consideredOutOfSyncAfter }
    );
    this.keyAgent = keyAgent;
    this.addresses$ = new TrackerSubject<GroupedAddress[]>(this.#initializeAddress(keyAgent.knownAddresses));
    this.name = name;
    this.#tip$ = this.tip$ = new SyncableIntervalPersistentDocumentTrackerSubject({
      maxPollInterval: maxInterval,
      pollInterval,
      provider$: coldObservableProvider(this.walletProvider.ledgerTip, retryBackoffConfig),
      store: stores.tip,
      trigger$: this.syncStatus.isSettled$.pipe(filter((isSettled) => isSettled))
    });
    const tipBlockHeight$ = distinctBlock(this.tip$);
    this.networkInfo$ = new PersistentDocumentTrackerSubject(
      // TODO: it only really needs to be fetched once per epoch,
      // so we should replace the trigger from tipBlockHeight$ to epoch$.
      // This is a little complicated since there is a circular dependency.
      // Some logic is needed to initiate a fetch if epoch is not available in store already.
      coldObservableProvider(this.networkInfoProvider.networkInfo, retryBackoffConfig, tipBlockHeight$, deepEquals),
      stores.networkInfo
    );
    this.currentEpoch$ = currentEpochTracker(this.tip$, this.networkInfo$);
    const epoch$ = this.currentEpoch$.pipe(map((epoch) => epoch.epochNo));
    this.protocolParameters$ = new PersistentDocumentTrackerSubject(
      coldObservableProvider(this.walletProvider.currentWalletProtocolParameters, retryBackoffConfig, epoch$, isEqual),
      stores.protocolParameters
    );
    this.genesisParameters$ = new PersistentDocumentTrackerSubject(
      coldObservableProvider(this.walletProvider.genesisParameters, retryBackoffConfig, epoch$, isEqual),
      stores.genesisParameters
    );

    const addresses$ = this.addresses$.pipe(
      map((addresses) => addresses.map((groupedAddress) => groupedAddress.address))
    );
    this.transactions = createTransactionsTracker({
      addresses$,
      newTransactions: this.#newTransactions,
      retryBackoffConfig,
      store: stores.transactions,
      tip$: this.tip$,
      walletProvider: this.walletProvider
    });
    this.utxo = createUtxoTracker({
      addresses$,
      retryBackoffConfig,
      stores,
      tipBlockHeight$,
      transactionsInFlight$: this.transactions.outgoing.inFlight$,
      utxoProvider: this.utxoProvider
    });
    const timeSettings$ = distinctTimeSettings(this.networkInfo$);
    this.delegation = createDelegationTracker({
      epoch$,
      retryBackoffConfig,
      rewardAccountAddresses$: this.addresses$.pipe(
        map((addresses) => addresses.map((groupedAddress) => groupedAddress.rewardAccount))
      ),
      stakePoolSearchProvider: this.stakePoolSearchProvider,
      stores,
      timeSettings$,
      transactionsTracker: this.transactions,
      walletProvider: this.walletProvider
    });
    this.balance = createBalanceTracker(this.protocolParameters$, this.utxo, this.delegation);
    this.assets$ = new PersistentDocumentTrackerSubject(
      createAssetsTracker({
        assetProvider: this.assetProvider,
        balanceTracker: this.balance,
        retryBackoffConfig
      }),
      stores.assets
    );
    this.util = createWalletUtil(this);
  }

  async getNetworkId(): Promise<Cardano.NetworkId> {
    return this.keyAgent.networkId;
  }

  async getName(): Promise<string> {
    return this.name;
  }

  async initializeTx(props: InitializeTxProps): Promise<InitializeTxResult> {
    const { constraints, utxo, implicitCoin, validityInterval, changeAddress } = await this.#prepareTx(props);
    const { selection: inputSelection } = await this.#inputSelector.select({
      constraints,
      implicitCoin,
      outputs: props.outputs || new Set(),
      utxo: new Set(utxo)
    });
    const { body, hash } = await createTransactionInternals({
      auxiliaryData: props.auxiliaryData,
      certificates: props.certificates,
      changeAddress,
      inputSelection,
      validityInterval,
      withdrawals: props.withdrawals
    });
    return { body, hash, inputSelection };
  }
  async finalizeTx(
    tx: TxInternals,
    auxiliaryData?: Cardano.AuxiliaryData,
    stubSign = false
  ): Promise<Cardano.NewTxAlonzo> {
    const signatures = stubSign
      ? keyManagementUtil.stubSignTransaction(tx.body, this.keyAgent.knownAddresses, this.util.resolveInputAddress)
      : await this.keyAgent.signTransaction(tx, {
          inputAddressResolver: this.util.resolveInputAddress
        });
    return {
      auxiliaryData,
      body: tx.body,
      id: tx.hash,
      // TODO: add support for the rest of the witness properties
      witness: { signatures }
    };
  }
  async submitTx(tx: Cardano.NewTxAlonzo): Promise<void> {
    this.#newTransactions.submitting$.next(tx);
    try {
      await this.txSubmitProvider.submitTx(coreToCsl.tx(tx).to_bytes());
      this.#newTransactions.pending$.next(tx);
    } catch (error) {
      this.#newTransactions.failedToSubmit$.next({
        error: error as Cardano.TxSubmissionError,
        reason: TransactionFailure.FailedToSubmit,
        tx
      });
      throw error;
    }
  }
  signData(props: SignDataProps): Promise<Cip30DataSignature> {
    return cip30signData({ keyAgent: this.keyAgent, ...props });
  }
  sync() {
    this.#tip$.sync();
  }
  shutdown() {
    this.balance.shutdown();
    this.utxo.shutdown();
    this.transactions.shutdown();
    this.networkInfo$.complete();
    this.protocolParameters$.complete();
    this.genesisParameters$.complete();
    this.#tip$.complete();
    this.addresses$.complete();
    this.assetProvider.stats.shutdown();
    this.walletProvider.stats.shutdown();
    this.txSubmitProvider.stats.shutdown();
    this.networkInfoProvider.stats.shutdown();
    this.stakePoolSearchProvider.stats.shutdown();
  }

  #prepareTx(props: InitializeTxProps) {
    return lastValueFrom(
      combineLatest([this.tip$, this.utxo.available$, this.protocolParameters$, this.addresses$]).pipe(
        take(1),
        map(([tip, utxo, protocolParameters, [{ address: changeAddress }]]) => {
          const validityInterval = ensureValidityInterval(tip.slot, props.options?.validityInterval);
          const constraints = defaultSelectionConstraints({
            buildTx: async (inputSelection) => {
              this.#logger.debug('Building TX for selection constraints', inputSelection);
              const txInternals = await createTransactionInternals({
                auxiliaryData: props.auxiliaryData,
                certificates: props.certificates,
                changeAddress,
                inputSelection,
                validityInterval,
                withdrawals: props.withdrawals
              });
              return coreToCsl.tx(await this.finalizeTx(txInternals, props.auxiliaryData, true));
            },
            protocolParameters
          });
          const implicitCoin = Cardano.util.computeImplicitCoin(protocolParameters, props);
          return { changeAddress, constraints, implicitCoin, utxo, validityInterval };
        })
      )
    );
  }

  #initializeAddress(knownAddresses?: GroupedAddress[]): Observable<GroupedAddress[]> {
    return new Observable((observer) => {
      const existingAddress = knownAddresses?.length && knownAddresses?.[0];
      if (existingAddress) {
        observer.next([existingAddress]);
        return;
      }
      this.keyAgent
        .deriveAddress({
          index: 0,
          type: AddressType.External
        })
        .then((newAddress) => observer.next([newAddress]))
        .catch(observer.error);
    });
  }
}
