import {
  AddressType,
  AsyncKeyAgent,
  GroupedAddress,
  SignTransactionOptions,
  TransactionSigner,
  cip8,
  util as keyManagementUtil
} from '@cardano-sdk/key-management';
import {
  AssetProvider,
  Cardano,
  ChainHistoryProvider,
  EpochInfo,
  EraSummary,
  ProtocolParametersRequiredByWallet,
  RewardsProvider,
  StakePoolProvider,
  TxSubmitProvider,
  UtxoProvider,
  coreToCsl
} from '@cardano-sdk/core';
import {
  Assets,
  FinalizeTxProps,
  InitializeTxProps,
  InitializeTxResult,
  ObservableWallet,
  SignDataProps,
  SyncStatus,
  WalletNetworkInfoProvider
} from './types';
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
  TrackedRewardsProvider,
  TrackedStakePoolProvider,
  TrackedTxSubmitProvider,
  TrackedWalletNetworkInfoProvider,
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
  distinctBlock,
  distinctEraSummaries,
  groupedAddressesEquals
} from './services';
import { BehaviorObservable, TrackerSubject } from '@cardano-sdk/util-rxjs';
import {
  BehaviorSubject,
  EMPTY,
  Observable,
  Subject,
  Subscription,
  catchError,
  combineLatest,
  concat,
  distinctUntilChanged,
  filter,
  firstValueFrom,
  from,
  lastValueFrom,
  map,
  mergeMap,
  take,
  tap
} from 'rxjs';
import { Cip30DataSignature } from '@cardano-sdk/cip30';
import { InputSelector, defaultSelectionConstraints, roundRobinRandomImprove } from '@cardano-sdk/cip2';
import { Logger } from 'ts-log';
import { RetryBackoffConfig } from 'backoff-rxjs';
import { Shutdown, bufferToHexString, contextLogger, deepEquals } from '@cardano-sdk/util';
import { TrackedUtxoProvider } from './services/ProviderTracker/TrackedUtxoProvider';
import { WalletStores, createInMemoryWalletStores } from './persistence';
import { createTransactionInternals, ensureValidityInterval } from './Transaction';
import { createTransactionReemitter } from './services/TransactionReemitter';
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
  readonly networkInfoProvider: WalletNetworkInfoProvider;
  readonly utxoProvider: UtxoProvider;
  readonly chainHistoryProvider: ChainHistoryProvider;
  readonly rewardsProvider: RewardsProvider;
  readonly inputSelector?: InputSelector;
  readonly stores?: WalletStores;
  readonly logger: Logger;
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
  #resubmitSubscription: Subscription;

  readonly keyAgent: AsyncKeyAgent;
  readonly currentEpoch$: TrackerSubject<EpochInfo>;
  readonly txSubmitProvider: TrackedTxSubmitProvider;
  readonly utxoProvider: TrackedUtxoProvider;
  readonly networkInfoProvider: TrackedWalletNetworkInfoProvider;
  readonly stakePoolProvider: TrackedStakePoolProvider;
  readonly assetProvider: TrackedAssetProvider;
  readonly chainHistoryProvider: TrackedChainHistoryProvider;
  readonly utxo: TransactionalTracker<Cardano.Utxo[]>;
  readonly balance: BalanceTracker;
  readonly transactions: TransactionsTracker & Shutdown;
  readonly delegation: DelegationTracker & Shutdown;
  readonly tip$: BehaviorObservable<Cardano.Tip>;
  readonly eraSummaries$: TrackerSubject<EraSummary[]>;
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
      logger,
      inputSelector = roundRobinRandomImprove(),
      stores = createInMemoryWalletStores(),
      connectionStatusTracker$ = createSimpleConnectionStatusTracker()
    }: SingleAddressWalletDependencies
  ) {
    this.#logger = contextLogger(logger, name);

    this.#inputSelector = inputSelector;

    this.txSubmitProvider = new TrackedTxSubmitProvider(txSubmitProvider);
    this.utxoProvider = new TrackedUtxoProvider(utxoProvider);
    this.networkInfoProvider = new TrackedWalletNetworkInfoProvider(networkInfoProvider);
    this.stakePoolProvider = new TrackedStakePoolProvider(stakePoolProvider);
    this.assetProvider = new TrackedAssetProvider(assetProvider);
    this.chainHistoryProvider = new TrackedChainHistoryProvider(chainHistoryProvider);
    this.rewardsProvider = new TrackedRewardsProvider(rewardsProvider);

    this.syncStatus = createProviderStatusTracker(
      {
        assetProvider: this.assetProvider,
        chainHistoryProvider: this.chainHistoryProvider,
        logger: contextLogger(this.#logger, 'syncStatus'),
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
            (addresses) => {
              if (addresses.length === 0) {
                this.#logger.debug('No addresses available; deriving one');
                void keyAgent
                  .deriveAddress({ index: 0, type: AddressType.External })
                  .catch(() => this.#logger.error('Failed to derive address'));
              }
            }
          ),
          filter((addresses) => addresses.length > 0),
          tap(stores.addresses.set.bind(stores.addresses))
        )
      )
    );

    this.name = name;
    const cancel$ = connectionStatusTracker$.pipe(
      tap((status) => (status === ConnectionStatus.up ? 'Connection UP' : 'Connection DOWN')),
      filter((status) => status === ConnectionStatus.down)
    );
    this.#tip$ = this.tip$ = new TipTracker({
      connectionStatus$: connectionStatusTracker$,
      logger: contextLogger(this.#logger, 'tip$'),
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

    // Era summaries
    const eraSummariesTrigger = new BehaviorSubject<void>(void 0);
    this.eraSummaries$ = new PersistentDocumentTrackerSubject(
      coldObservableProvider({
        cancel$,
        equals: deepEquals,
        provider: this.networkInfoProvider.eraSummaries,
        retryBackoffConfig,
        trigger$: eraSummariesTrigger.pipe(tap(() => 'Trigger request era summaries'))
      }),
      stores.eraSummaries
    );

    // Epoch tracker triggers the first eraSummaries fetch from eraSummariesTrigger
    // Epoch changes also trigger refetch of eraSummaries
    this.currentEpoch$ = currentEpochTracker(
      this.tip$,
      this.eraSummaries$.pipe(tap((es) => this.#logger.debug('Era summaries are', es)))
    );
    this.currentEpoch$.pipe(map(() => void 0)).subscribe(eraSummariesTrigger);
    const epoch$ = this.currentEpoch$.pipe(
      map((epoch) => epoch.epochNo),
      tap((epoch) => this.#logger.debug(`Current epoch is ${epoch}`))
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
      logger: contextLogger(this.#logger, 'transactions'),
      newTransactions: this.#newTransactions,
      retryBackoffConfig,
      tip$: this.tip$,
      transactionsHistoryStore: stores.transactions
    });

    this.#resubmitSubscription = createTransactionReemitter({
      confirmed$: this.transactions.outgoing.confirmed$,
      genesisParameters$: this.genesisParameters$,
      logger: contextLogger(this.#logger, 'transactionsReemitter'),
      rollback$: this.transactions.rollback$,
      store: stores.volatileTransactions,
      submitting$: this.transactions.outgoing.submitting$,
      tipSlot$: this.tip$.pipe(map((tip) => tip.slot))
    })
      .pipe(
        mergeMap((transaction) => from(this.submitTx(transaction))),
        catchError((err) => {
          this.#logger.error('Failed to resubmit transaction', err);
          return EMPTY;
        })
      )
      .subscribe();

    this.utxo = createUtxoTracker({
      addresses$,
      logger: contextLogger(this.#logger, 'utxo'),
      retryBackoffConfig,
      stores,
      tipBlockHeight$,
      transactionsInFlight$: this.transactions.outgoing.inFlight$,
      utxoProvider: this.utxoProvider
    });
    const eraSummaries$ = distinctEraSummaries(this.eraSummaries$);
    this.delegation = createDelegationTracker({
      epoch$,
      eraSummaries$,
      logger: contextLogger(this.#logger, 'delegation'),
      retryBackoffConfig,
      rewardAccountAddresses$: this.addresses$.pipe(
        map((addresses) => addresses.map((groupedAddress) => groupedAddress.rewardAccount))
      ),
      rewardsTracker: this.rewardsProvider,
      stakePoolProvider: this.stakePoolProvider,
      stores,
      transactionsTracker: this.transactions
    });

    this.balance = createBalanceTracker(this.protocolParameters$, this.utxo, this.delegation);
    this.assets$ = new PersistentDocumentTrackerSubject(
      createAssetsTracker({
        assetProvider: this.assetProvider,
        balanceTracker: this.balance,
        logger: contextLogger(this.#logger, 'assets$'),
        retryBackoffConfig
      }),
      stores.assets
    );
    this.util = createWalletUtil(this);
    this.#logger.debug('Created');
  }

  async getName(): Promise<string> {
    return this.name;
  }

  async initializeTx(props: InitializeTxProps): Promise<InitializeTxResult> {
    const { constraints, utxo, implicitCoin, validityInterval, changeAddress, withdrawals } = await this.#prepareTx(
      props
    );
    const { selection: inputSelection } = await this.#inputSelector.select({
      constraints,
      implicitValue: { coin: implicitCoin, mint: props.mint },
      outputs: props.outputs || new Set(),
      utxo: new Set(utxo)
    });
    const { body, hash } = await createTransactionInternals({
      auxiliaryData: props.auxiliaryData,
      certificates: props.certificates,
      changeAddress,
      collaterals: props.collaterals,
      inputSelection,
      mint: props.mint,
      requiredExtraSignatures: props.requiredExtraSignatures,
      scriptIntegrityHash: props.scriptIntegrityHash,
      validityInterval,
      withdrawals
    });
    return { body, hash, inputSelection };
  }

  async finalizeTx(props: FinalizeTxProps, stubSign = false): Promise<Cardano.NewTxAlonzo> {
    const addresses = await firstValueFrom(this.addresses$);
    const signatures = stubSign
      ? await keyManagementUtil.stubSignTransaction(
          props.tx.body,
          addresses,
          this.util,
          props.extraSigners,
          props.signingOptions
        )
      : await this.#getSignatures(props.tx, props.extraSigners, props.signingOptions);
    return {
      auxiliaryData: props.auxiliaryData,
      body: props.tx.body,
      id: props.tx.hash,
      // TODO: add support for the rest of the witness properties
      witness: { scripts: props.scripts, signatures }
    };
  }

  async submitTx(tx: Cardano.NewTxAlonzo): Promise<void> {
    this.#logger.debug(`Submitting transaction ${tx.id}`);
    this.#newTransactions.submitting$.next(tx);
    try {
      await this.txSubmitProvider.submitTx({
        signedTransaction: bufferToHexString(Buffer.from(coreToCsl.tx(tx).to_bytes()))
      });
      this.#logger.debug(`Submitted transaction ${tx.id}`);
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
    return cip8.cip30signData({ keyAgent: this.keyAgent, ...props });
  }
  sync() {
    this.#tip$.sync();
  }
  shutdown() {
    this.utxo.shutdown();
    this.transactions.shutdown();
    this.eraSummaries$.complete();
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
    this.#resubmitSubscription.unsubscribe();
    this.#logger.debug('Shutdown');
  }

  async #getSignatures(
    txInternals: Cardano.TxBodyWithHash,
    extraSigners?: TransactionSigner[],
    signingOptions?: SignTransactionOptions
  ) {
    const signatures: Cardano.Signatures = await this.keyAgent.signTransaction(txInternals, signingOptions);

    if (extraSigners) {
      for (const extraSigner of extraSigners) {
        const extraSignature = await extraSigner.sign(txInternals);
        signatures.set(extraSignature.pubKey, extraSignature.signature);
      }
    }

    return signatures;
  }

  #prepareTx(props: InitializeTxProps) {
    const withdrawals$: Observable<Cardano.Withdrawal[] | undefined> = this.delegation.rewardAccounts$.pipe(
      map((accounts) => accounts.filter((account) => account.rewardBalance)),
      map((accounts) =>
        accounts.map((account) => ({ quantity: account.rewardBalance, stakeAddress: account.address }))
      ),
      map((withdrawals) => (withdrawals.length > 0 ? withdrawals : undefined))
    );

    return lastValueFrom(
      combineLatest([this.tip$, this.utxo.available$, this.protocolParameters$, this.addresses$, withdrawals$]).pipe(
        take(1),
        map(([tip, utxo, protocolParameters, [{ address: changeAddress }], withdrawals]) => {
          const validityInterval = ensureValidityInterval(tip.slot, props.options?.validityInterval);
          const constraints = defaultSelectionConstraints({
            buildTx: async (inputSelection) => {
              this.#logger.debug('Building TX for selection constraints', inputSelection);
              if (withdrawals?.length) {
                this.#logger.debug('Adding rewards withdrawal in the transaction', withdrawals);
              }
              const txInternals = await createTransactionInternals({
                auxiliaryData: props.auxiliaryData,
                certificates: props.certificates,
                changeAddress,
                collaterals: props.collaterals,
                inputSelection,
                mint: props.mint,
                requiredExtraSignatures: props.requiredExtraSignatures,
                scriptIntegrityHash: props.scriptIntegrityHash,
                validityInterval,
                withdrawals
              });
              return coreToCsl.tx(
                await this.finalizeTx(
                  {
                    auxiliaryData: props.auxiliaryData,
                    extraSigners: props.extraSigners,
                    scripts: props.scripts,
                    signingOptions: props.signingOptions,
                    tx: txInternals
                  },
                  true
                )
              );
            },
            protocolParameters
          });
          const implicitCoin = Cardano.util.computeImplicitCoin(protocolParameters, props);
          return { changeAddress, constraints, implicitCoin, utxo, validityInterval, withdrawals };
        })
      )
    );
  }
}
