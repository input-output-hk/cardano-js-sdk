/* eslint-disable unicorn/no-nested-ternary */
import {
  AddressDiscovery,
  BalanceTracker,
  ConnectionStatus,
  ConnectionStatusTracker,
  DelegationTracker,
  FailedTx,
  HDSequentialDiscovery,
  OutgoingTx,
  PersistentDocumentTrackerSubject,
  PollingConfig,
  SmartTxSubmitProvider,
  TipTracker,
  TrackedAssetProvider,
  TrackedChainHistoryProvider,
  TrackedRewardsProvider,
  TrackedStakePoolProvider,
  TrackedTxSubmitProvider,
  TrackedWalletNetworkInfoProvider,
  TransactionFailure,
  TransactionsTracker,
  UtxoTracker,
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
} from '../services';
import {
  AssetProvider,
  Cardano,
  CardanoNodeErrors,
  ChainHistoryProvider,
  EpochInfo,
  EraSummary,
  HandleProvider,
  ProviderError,
  RewardsProvider,
  StakePoolProvider,
  TxBodyCBOR,
  TxCBOR,
  TxSubmitProvider,
  UtxoProvider
} from '@cardano-sdk/core';
import {
  Assets,
  FinalizeTxProps,
  ObservableWallet,
  SignDataProps,
  SyncStatus,
  WalletNetworkInfoProvider
} from '../types';
import { AsyncKeyAgent, GroupedAddress, cip8 } from '@cardano-sdk/key-management';
import { BehaviorObservable, TrackerSubject } from '@cardano-sdk/util-rxjs';
import {
  BehaviorSubject,
  EMPTY,
  Observable,
  Subject,
  Subscription,
  catchError,
  concat,
  distinctUntilChanged,
  filter,
  firstValueFrom,
  from,
  map,
  mergeMap,
  switchMap,
  tap
} from 'rxjs';
import { Cip30DataSignature } from '@cardano-sdk/dapp-connector';
import {
  GenericTxBuilder,
  InitializeTxProps,
  InitializeTxResult,
  TxBuilderDependencies,
  finalizeTx,
  initializeTx
} from '@cardano-sdk/tx-construction';
import { InputSelector, roundRobinRandomImprove } from '@cardano-sdk/input-selection';
import { Logger } from 'ts-log';
import { RetryBackoffConfig } from 'backoff-rxjs';
import { Shutdown, contextLogger, deepEquals } from '@cardano-sdk/util';
import { TrackedUtxoProvider } from '../services/ProviderTracker/TrackedUtxoProvider';
import { WalletStores, createInMemoryWalletStores } from '../persistence';
import { createTransactionReemitter } from '../services/TransactionReemitter';
import isEqual from 'lodash/isEqual';

export interface PersonalWalletProps {
  readonly name: string;
  readonly polling?: PollingConfig;
  readonly retryBackoffConfig?: RetryBackoffConfig;
}

export interface PersonalWalletDependencies {
  readonly keyAgent: AsyncKeyAgent;
  readonly txSubmitProvider: TxSubmitProvider;
  readonly stakePoolProvider: StakePoolProvider;
  readonly assetProvider: AssetProvider;
  readonly handleProvider?: HandleProvider;
  readonly networkInfoProvider: WalletNetworkInfoProvider;
  readonly utxoProvider: UtxoProvider;
  readonly chainHistoryProvider: ChainHistoryProvider;
  readonly rewardsProvider: RewardsProvider;
  readonly inputSelector?: InputSelector;
  readonly stores?: WalletStores;
  readonly logger: Logger;
  readonly connectionStatusTracker$?: ConnectionStatusTracker;
  readonly addressDiscovery?: AddressDiscovery;
}

export interface SubmitTxOptions {
  mightBeAlreadySubmitted?: boolean;
}

export const DEFAULT_POLLING_CONFIG = {
  maxInterval: 5000 * 20,
  maxIntervalMultiplier: 20,
  pollInterval: 5000
};

export const DEFAULT_LOOK_AHEAD_SEARCH = 20;

// Adjust the number of slots to wait until a transaction is considered lost (send but not found on chain)
// Configured to 2.5 because on preprod/mainnet, blocks produced at more than 250 slots apart are very rare (1 per epoch or less).
// Ideally we should calculate this based on the activeSlotsCoeff and probability of a single block per epoch.
const BLOCK_SLOT_GAP_MULTIPLIER = 2.5;

const isOutgoingTx = (input: Cardano.Tx | TxCBOR | OutgoingTx): input is OutgoingTx =>
  typeof input === 'object' && 'cbor' in input;
const isTxCBOR = (input: Cardano.Tx | TxCBOR | OutgoingTx): input is TxCBOR => typeof input === 'string';
const processOutgoingTx = (input: Cardano.Tx | TxCBOR | OutgoingTx): OutgoingTx => {
  // TxCbor
  if (isTxCBOR(input)) {
    return {
      body: TxCBOR.deserialize(input).body,
      cbor: input,
      // Do not re-serialize transaction body to compute transaction id
      id: Cardano.TransactionId.fromTxBodyCbor(TxBodyCBOR.fromTxCBOR(input))
    };
  }
  // OutgoingTx (resubmitted)
  if (isOutgoingTx(input)) {
    return input;
  }
  return {
    body: input.body,
    cbor: TxCBOR.serialize(input),
    id: input.id
  };
};

export class PersonalWallet implements ObservableWallet {
  #inputSelector: InputSelector;
  #logger: Logger;
  #tip$: TipTracker;
  #newTransactions = {
    failedToSubmit$: new Subject<FailedTx>(),
    pending$: new Subject<OutgoingTx>(),
    submitting$: new Subject<OutgoingTx>()
  };
  #reemitSubscriptions: Subscription;
  #failedFromReemitter$: Subject<FailedTx>;
  #trackedTxSubmitProvider: TrackedTxSubmitProvider;
  #addressDiscovery: AddressDiscovery;

  readonly keyAgent: AsyncKeyAgent;
  readonly currentEpoch$: TrackerSubject<EpochInfo>;
  readonly txSubmitProvider: TxSubmitProvider;
  readonly utxoProvider: TrackedUtxoProvider;
  readonly networkInfoProvider: TrackedWalletNetworkInfoProvider;
  readonly stakePoolProvider: TrackedStakePoolProvider;
  readonly assetProvider: TrackedAssetProvider;
  readonly chainHistoryProvider: TrackedChainHistoryProvider;
  readonly utxo: UtxoTracker;
  readonly balance: BalanceTracker;
  readonly transactions: TransactionsTracker & Shutdown;
  readonly delegation: DelegationTracker & Shutdown;
  readonly tip$: BehaviorObservable<Cardano.Tip>;
  readonly eraSummaries$: TrackerSubject<EraSummary[]>;
  readonly addresses$: TrackerSubject<GroupedAddress[]>;
  readonly protocolParameters$: TrackerSubject<Cardano.ProtocolParameters>;
  readonly genesisParameters$: TrackerSubject<Cardano.CompactGenesis>;
  readonly assetInfo$: TrackerSubject<Assets>;
  readonly fatalError$: Subject<unknown>;
  readonly syncStatus: SyncStatus;
  readonly name: string;
  readonly util: WalletUtil;
  readonly rewardsProvider: TrackedRewardsProvider;
  readonly handleProvider?: HandleProvider;

  // eslint-disable-next-line max-statements
  constructor(
    {
      name,
      polling: {
        interval: pollInterval = DEFAULT_POLLING_CONFIG.pollInterval,
        maxInterval = pollInterval * DEFAULT_POLLING_CONFIG.maxIntervalMultiplier,
        consideredOutOfSyncAfter = 1000 * 60 * 3
      } = {},
      retryBackoffConfig = {
        initialInterval: Math.min(pollInterval, 1000),
        maxInterval
      }
    }: PersonalWalletProps,
    {
      txSubmitProvider,
      stakePoolProvider,
      keyAgent,
      assetProvider,
      handleProvider,
      networkInfoProvider,
      utxoProvider,
      chainHistoryProvider,
      rewardsProvider,
      logger,
      inputSelector = roundRobinRandomImprove(),
      stores = createInMemoryWalletStores(),
      connectionStatusTracker$ = createSimpleConnectionStatusTracker(),
      addressDiscovery = new HDSequentialDiscovery(chainHistoryProvider, DEFAULT_LOOK_AHEAD_SEARCH)
    }: PersonalWalletDependencies
  ) {
    this.#logger = contextLogger(logger, name);

    this.#addressDiscovery = addressDiscovery;
    this.#inputSelector = inputSelector;
    this.#trackedTxSubmitProvider = new TrackedTxSubmitProvider(txSubmitProvider);

    this.utxoProvider = new TrackedUtxoProvider(utxoProvider);
    this.networkInfoProvider = new TrackedWalletNetworkInfoProvider(networkInfoProvider);
    this.stakePoolProvider = new TrackedStakePoolProvider(stakePoolProvider);
    this.assetProvider = new TrackedAssetProvider(assetProvider);
    this.handleProvider = handleProvider;
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
        utxoProvider: this.utxoProvider
      },
      { consideredOutOfSyncAfter }
    );

    this.keyAgent = keyAgent;

    this.fatalError$ = new Subject();

    const onFatalError = this.fatalError$.next.bind(this.fatalError$);

    this.name = name;
    const cancel$ = connectionStatusTracker$.pipe(
      tap((status) => (status === ConnectionStatus.up ? 'Connection UP' : 'Connection DOWN')),
      filter((status) => status === ConnectionStatus.down)
    );

    this.addresses$ = new TrackerSubject<GroupedAddress[]>(
      concat(
        stores.addresses.get(),
        keyAgent.knownAddresses$.pipe(
          distinctUntilChanged(groupedAddressesEquals),
          tap(
            // derive addresses if none available
            (addresses) => {
              if (addresses.length === 0) {
                this.#logger.debug('No addresses available; initiating address discovery process');

                firstValueFrom(
                  coldObservableProvider({
                    cancel$,
                    onFatalError,
                    provider: () => this.#addressDiscovery.discover(keyAgent),
                    retryBackoffConfig
                  })
                ).catch(() => this.#logger.error('Failed to complete the address discovery process'));
              }
            }
          ),
          filter((addresses) => addresses.length > 0),
          tap(stores.addresses.set.bind(stores.addresses))
        )
      )
    );

    this.#tip$ = this.tip$ = new TipTracker({
      connectionStatus$: connectionStatusTracker$,
      logger: contextLogger(this.#logger, 'tip$'),
      maxPollInterval: maxInterval,
      minPollInterval: pollInterval,
      provider$: coldObservableProvider({
        cancel$,
        onFatalError,
        provider: this.networkInfoProvider.ledgerTip,
        retryBackoffConfig
      }),
      store: stores.tip,
      syncStatus: this.syncStatus
    });
    const tipBlockHeight$ = distinctBlock(this.tip$);

    this.txSubmitProvider = new SmartTxSubmitProvider(
      { retryBackoffConfig },
      {
        connectionStatus$: connectionStatusTracker$,
        tip$: this.tip$,
        txSubmitProvider: this.#trackedTxSubmitProvider
      }
    );

    // Era summaries
    const eraSummariesTrigger = new BehaviorSubject<void>(void 0);
    this.eraSummaries$ = new PersistentDocumentTrackerSubject(
      coldObservableProvider({
        cancel$,
        equals: deepEquals,
        onFatalError,
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
        onFatalError,
        provider: this.networkInfoProvider.protocolParameters,
        retryBackoffConfig,
        trigger$: epoch$
      }),
      stores.protocolParameters
    );
    this.genesisParameters$ = new PersistentDocumentTrackerSubject(
      coldObservableProvider({
        cancel$,
        equals: isEqual,
        onFatalError,
        provider: this.networkInfoProvider.genesisParameters,
        retryBackoffConfig,
        trigger$: epoch$
      }),
      stores.genesisParameters
    );

    const addresses$ = this.addresses$.pipe(
      map((addresses) => addresses.map((groupedAddress) => groupedAddress.address))
    );
    this.#failedFromReemitter$ = new Subject<FailedTx>();
    this.transactions = createTransactionsTracker({
      addresses$,
      chainHistoryProvider: this.chainHistoryProvider,
      failedFromReemitter$: this.#failedFromReemitter$,
      inFlightTransactionsStore: stores.inFlightTransactions,
      logger: contextLogger(this.#logger, 'transactions'),
      newTransactions: this.#newTransactions,
      onFatalError,
      retryBackoffConfig,
      tip$: this.tip$,
      transactionsHistoryStore: stores.transactions
    });

    const transactionsReemitter = createTransactionReemitter({
      genesisParameters$: this.genesisParameters$,
      logger: contextLogger(this.#logger, 'transactionsReemitter'),
      maxInterval: maxInterval * BLOCK_SLOT_GAP_MULTIPLIER,
      stores,
      tipSlot$: this.tip$.pipe(map((tip) => tip.slot)),
      transactions: this.transactions
    });

    this.#reemitSubscriptions = new Subscription();
    this.#reemitSubscriptions.add(transactionsReemitter.failed$.subscribe(this.#failedFromReemitter$));
    this.#reemitSubscriptions.add(
      transactionsReemitter.reemit$
        .pipe(
          mergeMap((tx) => from(this.submitTx(tx, { mightBeAlreadySubmitted: true }))),
          catchError((err) => {
            this.#logger.error('Failed to resubmit transaction', err);
            return EMPTY;
          })
        )
        .subscribe()
    );

    this.utxo = createUtxoTracker({
      addresses$,
      logger: contextLogger(this.#logger, 'utxo'),
      onFatalError,
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
      onFatalError,
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
    this.assetInfo$ = new PersistentDocumentTrackerSubject(
      createAssetsTracker({
        assetProvider: this.assetProvider,
        logger: contextLogger(this.#logger, 'assets$'),
        onFatalError,
        retryBackoffConfig,
        transactionsTracker: this.transactions
      }),
      stores.assets
    );
    this.util = createWalletUtil({
      protocolParameters$: this.protocolParameters$,
      utxo: this.utxo
    });

    this.#logger.debug('Created');
  }

  async getName(): Promise<string> {
    return this.name;
  }

  async initializeTx(props: InitializeTxProps): Promise<InitializeTxResult> {
    return initializeTx(props, this.getTxBuilderDependencies());
  }

  async finalizeTx({ tx, ...rest }: FinalizeTxProps, stubSign = false): Promise<Cardano.Tx> {
    const { tx: signedTx } = await finalizeTx(
      tx,
      { ...rest, ownAddresses: await firstValueFrom(this.addresses$) },
      { inputResolver: this.util, keyAgent: this.keyAgent },
      stubSign
    );
    return signedTx;
  }

  createTxBuilder() {
    return new GenericTxBuilder(this.getTxBuilderDependencies());
  }

  async submitTx(
    input: Cardano.Tx | TxCBOR | OutgoingTx,
    { mightBeAlreadySubmitted }: SubmitTxOptions = {}
  ): Promise<Cardano.TransactionId> {
    const outgoingTx = processOutgoingTx(input);
    this.#logger.debug(`Submitting transaction ${outgoingTx.id}`);
    this.#newTransactions.submitting$.next(outgoingTx);
    try {
      await this.txSubmitProvider.submitTx({
        signedTransaction: outgoingTx.cbor
      });
      const { slot: submittedAt } = await firstValueFrom(this.tip$);
      this.#logger.debug(`Submitted transaction ${outgoingTx.id} at slot ${submittedAt}`);
      this.#newTransactions.pending$.next(outgoingTx);
      return outgoingTx.id;
    } catch (error) {
      if (
        mightBeAlreadySubmitted &&
        error instanceof ProviderError &&
        // This could be improved by further parsing the error and:
        // - checking if ValueNotConservedError produced === 0 (all utxos invalid)
        // - check if UnknownOrIncompleteWithdrawalsError available withdrawal amount === wallet's reward acc balance
        (error.innerError instanceof CardanoNodeErrors.TxSubmissionErrors.ValueNotConservedError ||
          error.innerError instanceof CardanoNodeErrors.TxSubmissionErrors.UnknownOrIncompleteWithdrawalsError ||
          error.innerError instanceof CardanoNodeErrors.TxSubmissionErrors.CollectErrorsError ||
          error.innerError instanceof CardanoNodeErrors.TxSubmissionErrors.BadInputsError)
      ) {
        this.#logger.debug(
          `Transaction ${outgoingTx.id} failed with ${error.innerError}, but it appears to be already submitted...`
        );
        this.#newTransactions.pending$.next(outgoingTx);
        return outgoingTx.id;
      }
      this.#newTransactions.failedToSubmit$.next({
        error: error as CardanoNodeErrors.TxSubmissionError,
        reason: TransactionFailure.FailedToSubmit,
        ...outgoingTx
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
    this.#trackedTxSubmitProvider.stats.shutdown();
    this.networkInfoProvider.stats.shutdown();
    this.stakePoolProvider.stats.shutdown();
    this.utxoProvider.stats.shutdown();
    this.rewardsProvider.stats.shutdown();
    this.chainHistoryProvider.stats.shutdown();
    this.keyAgent.shutdown();
    this.currentEpoch$.complete();
    this.delegation.shutdown();
    this.assetInfo$.complete();
    this.fatalError$.complete();
    this.syncStatus.shutdown();
    this.#newTransactions.failedToSubmit$.complete();
    this.#newTransactions.pending$.complete();
    this.#newTransactions.submitting$.complete();
    this.#reemitSubscriptions.unsubscribe();
    this.#failedFromReemitter$.complete();
    this.#logger.debug('Shutdown');
  }

  /**
   * Utility function that creates the TxBuilderDependencies based on the PersonalWallet observables.
   * All dependencies will wait until the wallet is settled before emitting.
   */
  getTxBuilderDependencies(): TxBuilderDependencies {
    return {
      handleProvider: this.handleProvider,
      inputResolver: this.util,
      inputSelector: this.#inputSelector,
      keyAgent: this.keyAgent,
      logger: this.#logger,
      outputValidator: this.util,
      txBuilderProviders: {
        changeAddress: () =>
          this.#firstValueFromSettled(this.addresses$.pipe(map(([{ address: changeAddress }]) => changeAddress))),
        genesisParameters: () => this.#firstValueFromSettled(this.genesisParameters$),
        protocolParameters: () => this.#firstValueFromSettled(this.protocolParameters$),
        rewardAccounts: () => this.#firstValueFromSettled(this.delegation.rewardAccounts$),
        tip: () => this.#firstValueFromSettled(this.tip$),
        utxoAvailable: () => this.#firstValueFromSettled(this.utxo.available$)
      }
    };
  }

  #firstValueFromSettled<T>(o$: Observable<T>): Promise<T> {
    return firstValueFrom(
      this.syncStatus.isSettled$.pipe(
        filter((isSettled) => isSettled),
        switchMap(() => o$)
      )
    );
  }
}
