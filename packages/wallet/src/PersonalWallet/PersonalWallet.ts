/* eslint-disable unicorn/no-nested-ternary */
// eslint-disable-next-line import/no-extraneous-dependencies
import {
  AddressDiscovery,
  AddressTracker,
  BalanceTracker,
  ConnectionStatus,
  ConnectionStatusTracker,
  DelegationTracker,
  DynamicChangeAddressResolver,
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
  TrackedUtxoProvider,
  TrackedWalletNetworkInfoProvider,
  TransactionFailure,
  TransactionsTracker,
  UtxoTracker,
  WalletUtil,
  createAddressTracker,
  createAssetsTracker,
  createBalanceTracker,
  createDelegationTracker,
  createHandlesTracker,
  createProviderStatusTracker,
  createSimpleConnectionStatusTracker,
  createTransactionReemitter,
  createTransactionsTracker,
  createUtxoTracker,
  createWalletUtil,
  currentEpochTracker,
  distinctBlock,
  distinctEraSummaries
} from '../services';
import {
  AssetProvider,
  Cardano,
  CardanoNodeUtil,
  ChainHistoryProvider,
  EpochInfo,
  EraSummary,
  HandleProvider,
  ProviderError,
  RewardsProvider,
  Serialization,
  StakePoolProvider,
  TxCBOR,
  TxSubmitProvider,
  UtxoProvider
} from '@cardano-sdk/core';
import {
  Assets,
  FinalizeTxProps,
  HandleInfo,
  ObservableWallet,
  SignDataProps,
  SyncStatus,
  WalletNetworkInfoProvider
} from '../types';
import { BehaviorObservable, TrackerSubject, coldObservableProvider } from '@cardano-sdk/util-rxjs';
import {
  BehaviorSubject,
  EMPTY,
  Observable,
  Subject,
  Subscription,
  catchError,
  filter,
  firstValueFrom,
  from,
  map,
  mergeMap,
  switchMap,
  take,
  tap,
  throwError
} from 'rxjs';
import {
  Bip32Account,
  GroupedAddress,
  Witnesser,
  cip8,
  util as keyManagementUtil,
  util
} from '@cardano-sdk/key-management';
import { ChangeAddressResolver, InputSelector, roundRobinRandomImprove } from '@cardano-sdk/input-selection';
import { Cip30DataSignature } from '@cardano-sdk/dapp-connector';
import { Ed25519PublicKeyHex } from '@cardano-sdk/crypto';
import {
  GenericTxBuilder,
  InitializeTxProps,
  InitializeTxResult,
  InvalidConfigurationError,
  SignedTx,
  TxBuilderDependencies,
  finalizeTx,
  initializeTx
} from '@cardano-sdk/tx-construction';
import { Logger } from 'ts-log';
import { PubStakeKeyAndStatus, createPublicStakeKeysTracker } from '../services/PublicStakeKeysTracker';
import { RetryBackoffConfig } from 'backoff-rxjs';
import { Shutdown, contextLogger, deepEquals } from '@cardano-sdk/util';
import { WalletStores, createInMemoryWalletStores } from '../persistence';
import isEqual from 'lodash/isEqual';
import uniq from 'lodash/uniq';
import type { KoraLabsHandleProvider } from '@cardano-sdk/cardano-services-client';

export interface PersonalWalletProps {
  readonly name: string;
  readonly polling?: PollingConfig;
  readonly retryBackoffConfig?: RetryBackoffConfig;
}

export interface PersonalWalletDependencies {
  readonly witnesser: Witnesser;
  readonly bip32Account: Bip32Account;
  readonly txSubmitProvider: TxSubmitProvider;
  readonly stakePoolProvider: StakePoolProvider;
  readonly assetProvider: AssetProvider;
  readonly handleProvider?: HandleProvider | KoraLabsHandleProvider;
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

const isOutgoingTx = (input: Cardano.Tx | TxCBOR | OutgoingTx | SignedTx): input is OutgoingTx =>
  typeof input === 'object' && 'cbor' in input;
const isTxCBOR = (input: Cardano.Tx | TxCBOR | OutgoingTx | SignedTx): input is TxCBOR => typeof input === 'string';
const isSignedTx = (input: Cardano.Tx | TxCBOR | OutgoingTx | SignedTx): input is SignedTx =>
  typeof input === 'object' && 'context' in input;
const processOutgoingTx = (input: Cardano.Tx | TxCBOR | OutgoingTx | SignedTx): OutgoingTx => {
  // TxCbor
  if (isTxCBOR(input)) {
    const tx = Serialization.Transaction.fromCbor(input);
    return {
      body: tx.toCore().body,
      cbor: input,
      // Do not re-serialize transaction body to compute transaction id
      id: tx.getId()
    };
  }
  // SignedTx
  if (isSignedTx(input)) {
    return {
      body: input.tx.body,
      cbor: input.cbor,
      context: input.context,
      // Do not re-serialize transaction body to compute transaction id
      id: input.tx.id
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
    signed$: new Subject<SignedTx>(),
    submitting$: new Subject<OutgoingTx>()
  };
  #reemitSubscriptions: Subscription;
  #failedFromReemitter$: Subject<FailedTx>;
  #trackedTxSubmitProvider: TrackedTxSubmitProvider;
  #addressTracker: AddressTracker;
  #addressDiscovery: AddressDiscovery;
  #submittingPromises: Partial<Record<Cardano.TransactionId, Promise<Cardano.TransactionId>>> = {};

  readonly witnesser: Witnesser;
  readonly bip32Account: Bip32Account;
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
  readonly addresses$: Observable<GroupedAddress[]>;
  readonly protocolParameters$: TrackerSubject<Cardano.ProtocolParameters>;
  readonly genesisParameters$: TrackerSubject<Cardano.CompactGenesis>;
  readonly assetInfo$: TrackerSubject<Assets>;
  readonly fatalError$: Subject<unknown>;
  readonly syncStatus: SyncStatus;
  readonly name: string;
  readonly util: WalletUtil;
  readonly rewardsProvider: TrackedRewardsProvider;
  readonly handleProvider: HandleProvider;
  readonly changeAddressResolver: ChangeAddressResolver;
  readonly publicStakeKeys$: TrackerSubject<PubStakeKeyAndStatus[]>;
  private drepPubKey: Ed25519PublicKeyHex;
  handles$: Observable<HandleInfo[]>;

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
      witnesser,
      bip32Account: addressManager,
      assetProvider,
      handleProvider,
      networkInfoProvider,
      utxoProvider,
      chainHistoryProvider,
      rewardsProvider,
      logger,
      inputSelector,
      stores = createInMemoryWalletStores(),
      connectionStatusTracker$ = createSimpleConnectionStatusTracker(),
      addressDiscovery = new HDSequentialDiscovery(chainHistoryProvider, DEFAULT_LOOK_AHEAD_SEARCH)
    }: PersonalWalletDependencies
  ) {
    this.#logger = contextLogger(logger, name);

    this.#trackedTxSubmitProvider = new TrackedTxSubmitProvider(txSubmitProvider);

    this.utxoProvider = new TrackedUtxoProvider(utxoProvider);
    this.networkInfoProvider = new TrackedWalletNetworkInfoProvider(networkInfoProvider);
    this.stakePoolProvider = new TrackedStakePoolProvider(stakePoolProvider);
    this.assetProvider = new TrackedAssetProvider(assetProvider);
    this.handleProvider = handleProvider as HandleProvider;
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

    this.bip32Account = addressManager;
    this.witnesser = witnesser;

    this.fatalError$ = new Subject();

    const onFatalError = this.fatalError$.next.bind(this.fatalError$);

    this.name = name;
    const cancel$ = connectionStatusTracker$.pipe(
      tap((status) => (status === ConnectionStatus.up ? 'Connection UP' : 'Connection DOWN')),
      filter((status) => status === ConnectionStatus.down)
    );

    this.#addressDiscovery = addressDiscovery;
    this.#addressTracker = createAddressTracker({
      addressDiscovery$: coldObservableProvider({
        cancel$,
        onFatalError,
        provider: () => addressDiscovery.discover(this.bip32Account),
        retryBackoffConfig
      }).pipe(
        take(1),
        catchError((error) => {
          this.#logger.error('Failed to complete the address discovery process', error);
          throw error;
        })
      ),
      logger: this.#logger,
      store: stores.addresses
    });
    this.addresses$ = this.#addressTracker.addresses$;

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
      signedTransactionsStore: stores.signedTransactions,
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
      knownAddresses$: this.addresses$,
      logger: contextLogger(this.#logger, 'delegation'),
      onFatalError,
      retryBackoffConfig,
      rewardAccountAddresses$: this.addresses$.pipe(
        map((addresses) => uniq(addresses.map((groupedAddress) => groupedAddress.rewardAccount)))
      ),
      rewardsTracker: this.rewardsProvider,
      stakePoolProvider: this.stakePoolProvider,
      stores,
      transactionsTracker: this.transactions,
      utxoTracker: this.utxo
    });

    this.#inputSelector = inputSelector
      ? inputSelector
      : roundRobinRandomImprove({
          changeAddressResolver: new DynamicChangeAddressResolver(
            this.syncStatus.isSettled$.pipe(
              filter((isSettled) => isSettled),
              switchMap(() => this.addresses$)
            ),
            this.delegation.distribution$,
            () => firstValueFrom(this.delegation.portfolio$),
            logger
          )
        });

    this.publicStakeKeys$ = createPublicStakeKeysTracker({
      addresses$: this.addresses$,
      bip32Account: this.bip32Account,
      rewardAccounts$: this.delegation.rewardAccounts$
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

    this.handles$ = this.handleProvider
      ? this.initializeHandles(
          new PersistentDocumentTrackerSubject(
            coldObservableProvider({
              cancel$,
              equals: isEqual,
              onFatalError,
              provider: () => this.handleProvider.getPolicyIds(),
              retryBackoffConfig
            }),
            stores.policyIds
          )
        )
      : throwError(() => new InvalidConfigurationError('PersonalWallet is missing a "handleProvider"'));

    this.util = createWalletUtil({
      protocolParameters$: this.protocolParameters$,
      transactions: this.transactions,
      utxo: this.utxo
    });

    this.getPubDRepKey().catch(() => void 0);

    this.#logger.debug('Created');
  }

  async getName(): Promise<string> {
    return this.name;
  }

  async initializeTx(props: InitializeTxProps): Promise<InitializeTxResult> {
    return initializeTx(props, this.getTxBuilderDependencies());
  }

  async finalizeTx({ tx, sender, ...rest }: FinalizeTxProps, stubSign = false): Promise<Cardano.Tx> {
    const knownAddresses = await firstValueFrom(this.addresses$);
    const result = await finalizeTx(
      tx,
      {
        ...rest,
        signingContext: {
          knownAddresses,
          sender,
          txInKeyPathMap: await util.createTxInKeyPathMap(tx.body, knownAddresses, this.util)
        }
      },
      { bip32Account: this.bip32Account, witnesser: this.witnesser },
      stubSign
    );
    this.#newTransactions.signed$.next(result);
    return result.tx;
  }

  private initializeHandles(handlePolicyIds$: Observable<Cardano.PolicyId[]>): Observable<HandleInfo[]> {
    return createHandlesTracker({
      assetInfo$: this.assetInfo$,
      handlePolicyIds$,
      handleProvider: this.handleProvider,
      logger: contextLogger(this.#logger, 'handles$'),
      utxo$: this.utxo.total$
    });
  }

  createTxBuilder() {
    return new GenericTxBuilder(this.getTxBuilderDependencies());
  }

  async #submitTx(
    outgoingTx: OutgoingTx,
    { mightBeAlreadySubmitted }: SubmitTxOptions = {}
  ): Promise<Cardano.TransactionId> {
    this.#logger.debug(`Submitting transaction ${outgoingTx.id}`);
    this.#newTransactions.submitting$.next(outgoingTx);
    try {
      await this.txSubmitProvider.submitTx({
        context: outgoingTx.context,
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
        // Review: not sure if those 2 errors cover the original ones: there is no longer a CollectErrorsError or BadInputsError
        // Re-add error.innerError.data.produced.coins === 0n check once Ogmios6 is released. It is not part of the error in pre-ogmios6.
        (CardanoNodeUtil.isValueNotConservedError(error.innerError) ||
          // TODO: check if IncompleteWithdrawals available withdrawal amount === wallet's reward acc balance?
          // Not sure what the 'Withdrawals' in error data is exactly: value being withdrawed, or reward acc balance
          CardanoNodeUtil.isIncompleteWithdrawalsError(error.innerError))
      ) {
        this.#logger.debug(
          `Transaction ${outgoingTx.id} failed with ${error.innerError}, but it appears to be already submitted...`
        );
        this.#newTransactions.pending$.next(outgoingTx);
        return outgoingTx.id;
      }
      this.#newTransactions.failedToSubmit$.next({
        error,
        reason: TransactionFailure.FailedToSubmit,
        ...outgoingTx
      });
      throw error;
    }
  }

  async submitTx(
    input: Cardano.Tx | TxCBOR | OutgoingTx | SignedTx,
    options: SubmitTxOptions = {}
  ): Promise<Cardano.TransactionId> {
    const outgoingTx = processOutgoingTx(input);
    if (this.#submittingPromises[outgoingTx.id]) {
      return this.#submittingPromises[outgoingTx.id]!;
    }
    return (this.#submittingPromises[outgoingTx.id] = (async () => {
      try {
        // Submit to provider only if it's either:
        // - an internal re-submission. External re-submissions are ignored,
        //   because PersonalWallet takes care of it internally.
        // - is a new submission
        if (options.mightBeAlreadySubmitted || !(await this.#isTxInFlight(outgoingTx.id))) {
          await this.#submitTx(outgoingTx, options);
        }
      } finally {
        delete this.#submittingPromises[outgoingTx.id];
      }
      return outgoingTx.id;
    })());
  }

  async signData(props: SignDataProps): Promise<Cip30DataSignature> {
    return cip8.cip30signData({
      // TODO: signData probably needs to be refactored out of the wallet and supported as a stand alone util
      // as this operation doesnt require any of the wallet state. Also this operation can only be performed
      // by Bip32Ed25519 type of wallets.
      knownAddresses: await firstValueFrom(this.addresses$),
      witnesser: this.witnesser as keyManagementUtil.Bip32Ed25519Witnesser,
      ...props
    });
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
    this.#addressTracker.shutdown();
    this.assetProvider.stats.shutdown();
    this.#trackedTxSubmitProvider.stats.shutdown();
    this.networkInfoProvider.stats.shutdown();
    this.stakePoolProvider.stats.shutdown();
    this.utxoProvider.stats.shutdown();
    this.rewardsProvider.stats.shutdown();
    this.chainHistoryProvider.stats.shutdown();
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
    this.publicStakeKeys$.complete();
    this.#logger.debug('Shutdown');
  }

  /**
   * Sets the wallet input selector.
   *
   * @param selector The input selector to be used.
   */
  setInputSelector(selector: InputSelector) {
    this.#inputSelector = selector;
  }

  /** Gets the wallet input selector. */
  getInputSelector() {
    return this.#inputSelector;
  }

  /**
   * Utility function that creates the TxBuilderDependencies based on the PersonalWallet observables.
   * All dependencies will wait until the wallet is settled before emitting.
   */
  getTxBuilderDependencies(): TxBuilderDependencies {
    return {
      bip32Account: this.bip32Account,
      handleProvider: this.handleProvider,
      inputResolver: this.util,
      inputSelector: this.#inputSelector,
      logger: this.#logger,
      outputValidator: this.util,
      txBuilderProviders: {
        addresses: {
          add: (...newAddresses) => firstValueFrom(this.#addressTracker.addAddresses(newAddresses)),
          get: () => firstValueFrom(this.addresses$)
        },
        genesisParameters: () => this.#firstValueFromSettled(this.genesisParameters$),
        protocolParameters: () => this.#firstValueFromSettled(this.protocolParameters$),
        rewardAccounts: () => this.#firstValueFromSettled(this.delegation.rewardAccounts$),
        tip: () => this.#firstValueFromSettled(this.tip$),
        utxoAvailable: () => this.#firstValueFromSettled(this.utxo.available$)
      },
      witnesser: this.witnesser
    };
  }

  async #isTxInFlight(txId: Cardano.TransactionId) {
    const inFlightTxs = await firstValueFrom(this.transactions.outgoing.inFlight$);
    return inFlightTxs.some((inFlight) => inFlight.id === txId);
  }

  #firstValueFromSettled<T>(o$: Observable<T>): Promise<T> {
    return firstValueFrom(
      this.syncStatus.isSettled$.pipe(
        filter((isSettled) => isSettled),
        switchMap(() => o$)
      )
    );
  }

  async getPubDRepKey(): Promise<Ed25519PublicKeyHex> {
    if (!this.drepPubKey) {
      try {
        this.drepPubKey = (await this.bip32Account.derivePublicKey(keyManagementUtil.DREP_KEY_DERIVATION_PATH)).hex();
      } catch (error) {
        this.#logger.error(error);
        throw error;
      }
    }
    return Promise.resolve(this.drepPubKey);
  }

  async discoverAddresses(): Promise<GroupedAddress[]> {
    const addresses = await this.#addressDiscovery.discover(this.bip32Account);
    const knownAddresses = await firstValueFrom(this.addresses$);
    const newAddresses = addresses.filter(
      ({ address }) => !knownAddresses.some((knownAddr) => knownAddr.address === address)
    );
    await firstValueFrom(this.#addressTracker.addAddresses(newAddresses));
    return firstValueFrom(this.addresses$);
  }
}
