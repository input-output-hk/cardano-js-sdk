import { AddressType, AsyncKeyAgent, GroupedAddress, util as keyManagementUtil } from './KeyManagement';
import {
  AssetProvider,
  Cardano,
  ChainHistoryProvider,
  EpochInfo,
  NetworkInfoProvider,
  ProtocolParametersRequiredByWallet,
  RewardsProvider,
  StakePoolProvider,
  StakeSummary,
  SupplySummary,
  TimeSettings,
  TxSubmitProvider,
  UtxoProvider,
  coreToCsl
} from '@cardano-sdk/core';
import { Assets, InitializeTxProps, InitializeTxResult, ObservableWallet, SignDataProps, SyncStatus } from './types';
import {
  BalanceTracker,
  ConnectionStatus,
  ConnectionStatusTracker,
  DelegationTracker,
  FailedTx,
  PersistentDocumentTrackerSubject,
  PollingConfig,
  TipTracker,
  TrackedAssetProvider,
  TrackedChainHistoryProvider,
  TrackedNetworkInfoProvider,
  TrackedRewardsProvider,
  TrackedStakePoolProvider,
  TrackedTxSubmitProvider,
  TransactionFailure,
  TransactionalTracker,
  TransactionsTracker,
  WalletUtil,
  coldObservableProvider,
  createAssetsTracker,
  createBalanceTracker,
  createDelegationTracker,
  createProviderStatusTracker,
  createSimpleConnectionStatusTracker,
  createTransactionsTracker,
  createUtxoTracker,
  createWalletUtil,
  currentEpochTracker,
  deepEquals,
  distinctBlock,
  distinctTimeSettings,
  groupedAddressesEquals
} from './services';
import { BehaviorObservable, TrackerSubject } from '@cardano-sdk/util-rxjs';
import { Cip30DataSignature } from '@cardano-sdk/cip30';
import { InputSelector, defaultSelectionConstraints, roundRobinRandomImprove } from '@cardano-sdk/cip2';
import { Logger, dummyLogger } from 'ts-log';
import { RetryBackoffConfig } from 'backoff-rxjs';
import { Shutdown } from '@cardano-sdk/util';
import {
  Subject,
  combineLatest,
  concat,
  distinctUntilChanged,
  filter,
  firstValueFrom,
  lastValueFrom,
  map,
  take,
  tap
} from 'rxjs';
import { TrackedUtxoProvider } from './services/ProviderTracker/TrackedUtxoProvider';
import { TxInternals, createTransactionInternals, ensureValidityInterval } from './Transaction';
import { WalletStores, createInMemoryWalletStores } from './persistence';
import { cip30signData } from './KeyManagement/cip8';
import isEqual from 'lodash/isEqual';

export interface SingleAddressWalletProps {
  readonly name: string;
  readonly polling?: PollingConfig;
  readonly retryBackoffConfig?: RetryBackoffConfig;
}

export interface SingleAddressWalletDependencies {
  readonly keyAgent: AsyncKeyAgent;
  readonly txSubmitProvider: TxSubmitProvider;
  readonly stakePoolProvider: StakePoolProvider;
  readonly assetProvider: AssetProvider;
  readonly networkInfoProvider: NetworkInfoProvider;
  readonly utxoProvider: UtxoProvider;
  readonly chainHistoryProvider: ChainHistoryProvider;
  readonly rewardsProvider: RewardsProvider;
  readonly inputSelector?: InputSelector;
  readonly stores?: WalletStores;
  readonly logger?: Logger;
  readonly connectionStatusTracker$?: ConnectionStatusTracker;
}

export class SingleAddressWallet implements ObservableWallet {
  #inputSelector: InputSelector;
  #logger: Logger;
  #tip$: TipTracker;
  #newTransactions = {
    failedToSubmit$: new Subject<FailedTx>(),
    pending$: new Subject<Cardano.NewTxAlonzo>(),
    submitting$: new Subject<Cardano.NewTxAlonzo>()
  };
  readonly keyAgent: AsyncKeyAgent;
  readonly currentEpoch$: TrackerSubject<EpochInfo>;
  readonly txSubmitProvider: TrackedTxSubmitProvider;
  readonly utxoProvider: TrackedUtxoProvider;
  readonly networkInfoProvider: TrackedNetworkInfoProvider;
  readonly stakePoolProvider: TrackedStakePoolProvider;
  readonly assetProvider: TrackedAssetProvider;
  readonly chainHistoryProvider: TrackedChainHistoryProvider;
  readonly utxo: TransactionalTracker<Cardano.Utxo[]>;
  readonly balance: BalanceTracker;
  readonly transactions: TransactionsTracker & Shutdown;
  readonly delegation: DelegationTracker & Shutdown;
  readonly tip$: BehaviorObservable<Cardano.Tip>;
  readonly lovelaceSupply$: TrackerSubject<SupplySummary>;
  readonly stake$: TrackerSubject<StakeSummary>;
  readonly timeSettings$: TrackerSubject<TimeSettings[]>;
  readonly addresses$: TrackerSubject<GroupedAddress[]>;
  readonly protocolParameters$: TrackerSubject<ProtocolParametersRequiredByWallet>;
  readonly genesisParameters$: TrackerSubject<Cardano.CompactGenesis>;
  readonly assets$: TrackerSubject<Assets>;
  readonly syncStatus: SyncStatus;
  readonly name: string;
  readonly util: WalletUtil;
  readonly rewardsProvider: TrackedRewardsProvider;

  // eslint-disable-next-line max-statements
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
      stakePoolProvider,
      keyAgent,
      assetProvider,
      networkInfoProvider,
      utxoProvider,
      chainHistoryProvider,
      rewardsProvider,
      logger = dummyLogger,
      inputSelector = roundRobinRandomImprove(),
      stores = createInMemoryWalletStores(),
      connectionStatusTracker$ = createSimpleConnectionStatusTracker()
    }: SingleAddressWalletDependencies
  ) {
    this.#logger = logger;
    this.#inputSelector = inputSelector;
    this.txSubmitProvider = new TrackedTxSubmitProvider(txSubmitProvider);
    this.utxoProvider = new TrackedUtxoProvider(utxoProvider);
    this.networkInfoProvider = new TrackedNetworkInfoProvider(networkInfoProvider);
    this.stakePoolProvider = new TrackedStakePoolProvider(stakePoolProvider);
    this.assetProvider = new TrackedAssetProvider(assetProvider);
    this.chainHistoryProvider = new TrackedChainHistoryProvider(chainHistoryProvider);
    this.rewardsProvider = new TrackedRewardsProvider(rewardsProvider);
    this.syncStatus = createProviderStatusTracker(
      {
        assetProvider: this.assetProvider,
        chainHistoryProvider: this.chainHistoryProvider,
        networkInfoProvider: this.networkInfoProvider,
        rewardsProvider: this.rewardsProvider,
        stakePoolProvider: this.stakePoolProvider,
        txSubmitProvider: this.txSubmitProvider,
        utxoProvider: this.utxoProvider
      },
      { consideredOutOfSyncAfter }
    );
    this.keyAgent = keyAgent;
    this.addresses$ = new TrackerSubject<GroupedAddress[]>(
      concat(
        stores.addresses.get(),
        keyAgent.knownAddresses$.pipe(
          distinctUntilChanged(groupedAddressesEquals),
          tap(
            // derive an address if none available
            (addresses) =>
              addresses.length === 0 &&
              void keyAgent
                .deriveAddress({ index: 0, type: AddressType.External })
                .catch(() => logger.error('SingleAddressWallet failed to derive address'))
          ),
          filter((addresses) => addresses.length > 0),
          tap(stores.addresses.set.bind(stores.addresses))
        )
      )
    );
    this.name = name;
    const cancel$ = connectionStatusTracker$.pipe(filter((status) => status === ConnectionStatus.down));
    this.#tip$ = this.tip$ = new TipTracker({
      connectionStatus$: connectionStatusTracker$,
      maxPollInterval: maxInterval,
      minPollInterval: pollInterval,
      provider$: coldObservableProvider({
        cancel$,
        provider: this.networkInfoProvider.ledgerTip,
        retryBackoffConfig
      }),
      store: stores.tip,
      syncStatus: this.syncStatus
    });
    const tipBlockHeight$ = distinctBlock(this.tip$);
    this.timeSettings$ = new PersistentDocumentTrackerSubject(
      // TODO: it only really needs to be fetched once per epoch,
      // so we should replace the trigger from tipBlockHeight$ to epoch$.
      // This is a little complicated since there is a circular dependency.
      // Some logic is needed to initiate a fetch if epoch is not available in store already.
      coldObservableProvider({
        cancel$,
        equals: deepEquals,
        provider: this.networkInfoProvider.timeSettings,
        retryBackoffConfig,
        trigger$: tipBlockHeight$
      }),
      stores.timeSettings
    );
    this.currentEpoch$ = currentEpochTracker(this.tip$, this.timeSettings$);
    const epoch$ = this.currentEpoch$.pipe(map((epoch) => epoch.epochNo));

    this.stake$ = new PersistentDocumentTrackerSubject(
      coldObservableProvider({
        equals: isEqual,
        provider: this.networkInfoProvider.stake,
        retryBackoffConfig,
        trigger$: epoch$
      }),
      stores.stake
    );

    this.lovelaceSupply$ = new PersistentDocumentTrackerSubject(
      coldObservableProvider({
        equals: isEqual,
        provider: this.networkInfoProvider.lovelaceSupply,
        retryBackoffConfig,
        trigger$: epoch$
      }),
      stores.lovelaceSupply
    );

    this.protocolParameters$ = new PersistentDocumentTrackerSubject(
      coldObservableProvider({
        cancel$,
        equals: isEqual,
        provider: this.networkInfoProvider.currentWalletProtocolParameters,
        retryBackoffConfig,
        trigger$: epoch$
      }),
      stores.protocolParameters
    );
    this.genesisParameters$ = new PersistentDocumentTrackerSubject(
      coldObservableProvider({
        cancel$,
        equals: isEqual,
        provider: this.networkInfoProvider.genesisParameters,
        retryBackoffConfig,
        trigger$: epoch$
      }),
      stores.genesisParameters
    );

    const addresses$ = this.addresses$.pipe(
      map((addresses) => addresses.map((groupedAddress) => groupedAddress.address))
    );
    this.transactions = createTransactionsTracker({
      addresses$,
      chainHistoryProvider: this.chainHistoryProvider,
      inFlightTransactionsStore: stores.inFlightTransactions,
      newTransactions: this.#newTransactions,
      retryBackoffConfig,
      tip$: this.tip$,
      transactionsHistoryStore: stores.transactions
    });
    this.utxo = createUtxoTracker({
      addresses$,
      retryBackoffConfig,
      stores,
      tipBlockHeight$,
      transactionsInFlight$: this.transactions.outgoing.inFlight$,
      utxoProvider: this.utxoProvider
    });
    const timeSettings$ = distinctTimeSettings(this.timeSettings$);
    this.delegation = createDelegationTracker({
      epoch$,
      retryBackoffConfig,
      rewardAccountAddresses$: this.addresses$.pipe(
        map((addresses) => addresses.map((groupedAddress) => groupedAddress.rewardAccount))
      ),
      rewardsTracker: this.rewardsProvider,
      stakePoolProvider: this.stakePoolProvider,
      stores,
      timeSettings$,
      transactionsTracker: this.transactions
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
    const addresses = await firstValueFrom(this.addresses$);
    const signatures = stubSign
      ? await keyManagementUtil.stubSignTransaction(tx.body, addresses, this.util.resolveInputAddress)
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
    this.utxo.shutdown();
    this.transactions.shutdown();
    this.stake$.complete();
    this.lovelaceSupply$.complete();
    this.timeSettings$.complete();
    this.protocolParameters$.complete();
    this.genesisParameters$.complete();
    this.#tip$.complete();
    this.addresses$.complete();
    this.assetProvider.stats.shutdown();
    this.txSubmitProvider.stats.shutdown();
    this.networkInfoProvider.stats.shutdown();
    this.stakePoolProvider.stats.shutdown();
    this.utxoProvider.stats.shutdown();
    this.chainHistoryProvider.stats.shutdown();
    this.keyAgent.shutdown();
    this.currentEpoch$.complete();
    this.delegation.shutdown();
    this.assets$.complete();
    this.syncStatus.shutdown();
    this.#newTransactions.failedToSubmit$.complete();
    this.#newTransactions.pending$.complete();
    this.#newTransactions.submitting$.complete();
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
}
