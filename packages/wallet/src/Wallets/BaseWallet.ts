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
  createDRepRegistrationTracker,
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
  UpdateWitnessProps,
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
  distinctUntilChanged,
  filter,
  firstValueFrom,
  from,
  map,
  mergeMap,
  of,
  switchMap,
  take,
  tap,
  throwError
} from 'rxjs';
import { Bip32Account, GroupedAddress, WitnessedTx, Witnesser, cip8, util } from '@cardano-sdk/key-management';
import { ChangeAddressResolver, InputSelector, roundRobinRandomImprove } from '@cardano-sdk/input-selection';
import { Cip30DataSignature } from '@cardano-sdk/dapp-connector';
import { Ed25519PublicKey, Ed25519PublicKeyHex } from '@cardano-sdk/crypto';
import {
  GenericTxBuilder,
  GreedyTxEvaluator,
  InitializeTxProps,
  InitializeTxResult,
  InvalidConfigurationError,
  TxBuilderDependencies,
  initializeTx
} from '@cardano-sdk/tx-construction';
import { Logger } from 'ts-log';
import { PubStakeKeyAndStatus, createPublicStakeKeysTracker } from '../services/PublicStakeKeysTracker';
import { RetryBackoffConfig } from 'backoff-rxjs';
import { Shutdown, contextLogger, deepEquals } from '@cardano-sdk/util';
import { WalletStores, createInMemoryWalletStores } from '../persistence';
import { getScriptAddress } from './internals';
import isEqual from 'lodash/isEqual.js';
import uniq from 'lodash/uniq.js';

export interface BaseWalletProps {
  readonly name: string;
  readonly polling?: PollingConfig;
  readonly retryBackoffConfig?: RetryBackoffConfig;
}

export enum PublicCredentialsManagerType {
  SCRIPT_CREDENTIALS_MANAGER = 'SCRIPT_CREDENTIALS_MANAGER',
  BIP32_CREDENTIALS_MANAGER = 'BIP32_CREDENTIALS_MANAGER'
}

export interface Bip32PublicCredentialsManager {
  __type: PublicCredentialsManagerType.BIP32_CREDENTIALS_MANAGER;
  bip32Account: Bip32Account;
  addressDiscovery: AddressDiscovery;
}

export interface ScriptPublicCredentialsManager {
  __type: PublicCredentialsManagerType.SCRIPT_CREDENTIALS_MANAGER;
  paymentScript: Cardano.RequireAllOfScript | Cardano.RequireAnyOfScript | Cardano.RequireAtLeastScript;
  stakingScript: Cardano.RequireAllOfScript | Cardano.RequireAnyOfScript | Cardano.RequireAtLeastScript;
}

export type PublicCredentialsManager = ScriptPublicCredentialsManager | Bip32PublicCredentialsManager;

export const isScriptPublicCredentialsManager = (
  credManager: PublicCredentialsManager
): credManager is ScriptPublicCredentialsManager =>
  credManager.__type === PublicCredentialsManagerType.SCRIPT_CREDENTIALS_MANAGER;

export const isBip32PublicCredentialsManager = (
  credManager: PublicCredentialsManager
): credManager is Bip32PublicCredentialsManager => !isScriptPublicCredentialsManager(credManager);

export interface BaseWalletDependencies {
  readonly witnesser: Witnesser;
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
  readonly publicCredentialsManager: PublicCredentialsManager;
}

export interface SubmitTxOptions {
  mightBeAlreadySubmitted?: boolean;
}

export const DEFAULT_POLLING_CONFIG = {
  maxInterval: 5000 * 20,
  maxIntervalMultiplier: 20,
  pollInterval: 5000
};

// Adjust the number of slots to wait until a transaction is considered lost (send but not found on chain)
// Configured to 2.5 because on preprod/mainnet, blocks produced at more than 250 slots apart are very rare (1 per epoch or less).
// Ideally we should calculate this based on the activeSlotsCoeff and probability of a single block per epoch.
const BLOCK_SLOT_GAP_MULTIPLIER = 2.5;

const isOutgoingTx = (input: Cardano.Tx | TxCBOR | OutgoingTx | WitnessedTx): input is OutgoingTx =>
  typeof input === 'object' && 'cbor' in input;
const isTxCBOR = (input: Cardano.Tx | TxCBOR | OutgoingTx | WitnessedTx): input is TxCBOR => typeof input === 'string';
const isWitnessedTx = (input: Cardano.Tx | TxCBOR | OutgoingTx | WitnessedTx): input is WitnessedTx =>
  typeof input === 'object' && 'context' in input;
const processOutgoingTx = (input: Cardano.Tx | TxCBOR | OutgoingTx | WitnessedTx): OutgoingTx => {
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
  // WitnessedTx
  if (isWitnessedTx(input)) {
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
const getDRepKeyHash = async (dRepKey: Ed25519PublicKeyHex | undefined) =>
  dRepKey ? (await Ed25519PublicKey.fromHex(dRepKey).hash()).hex() : undefined;

export class BaseWallet implements ObservableWallet {
  #inputSelector: InputSelector;
  #logger: Logger;
  #tip$: TipTracker;
  #newTransactions = {
    failedToSubmit$: new Subject<FailedTx>(),
    pending$: new Subject<OutgoingTx>(),
    signed$: new Subject<WitnessedTx>(),
    submitting$: new Subject<OutgoingTx>()
  };
  #reemitSubscriptions: Subscription;
  #failedFromReemitter$: Subject<FailedTx>;
  #trackedTxSubmitProvider: TrackedTxSubmitProvider;
  #addressTracker: AddressTracker;
  #publicCredentialsManager: PublicCredentialsManager;
  #submittingPromises: Partial<Record<Cardano.TransactionId, Promise<Cardano.TransactionId>>> = {};

  readonly witnesser: Witnesser;
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
  readonly governance: {
    readonly isRegisteredAsDRep$: Observable<boolean>;
    getPubDRepKey(): Promise<Ed25519PublicKeyHex | undefined>;
  };
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
    }: BaseWalletProps,
    {
      txSubmitProvider,
      stakePoolProvider,
      witnesser,
      assetProvider,
      handleProvider,
      networkInfoProvider,
      utxoProvider,
      chainHistoryProvider,
      rewardsProvider,
      logger,
      inputSelector,
      publicCredentialsManager,
      stores = createInMemoryWalletStores(),
      connectionStatusTracker$ = createSimpleConnectionStatusTracker()
    }: BaseWalletDependencies
  ) {
    this.#logger = contextLogger(logger, name);
    this.#publicCredentialsManager = publicCredentialsManager;
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

    this.witnesser = witnesser;

    this.fatalError$ = new Subject();

    const onFatalError = this.fatalError$.next.bind(this.fatalError$);

    this.name = name;
    const cancel$ = connectionStatusTracker$.pipe(
      tap((status) => (status === ConnectionStatus.up ? 'Connection UP' : 'Connection DOWN')),
      filter((status) => status === ConnectionStatus.down)
    );

    if (isBip32PublicCredentialsManager(this.#publicCredentialsManager)) {
      this.#addressTracker = createAddressTracker({
        addressDiscovery$: coldObservableProvider({
          cancel$,
          onFatalError,
          provider: () => {
            const credManager = this.#publicCredentialsManager as Bip32PublicCredentialsManager;
            return credManager.addressDiscovery.discover(credManager.bip32Account);
          },
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
    } else {
      const credManager = this.#publicCredentialsManager as ScriptPublicCredentialsManager;
      this.addresses$ = from(this.networkInfoProvider.genesisParameters()).pipe(
        map(({ networkId }) => networkId),
        distinctUntilChanged(),
        map((networkId) => [getScriptAddress(credManager.paymentScript, credManager.stakingScript, networkId)])
      );
    }

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

    this.publicStakeKeys$ = isBip32PublicCredentialsManager(this.#publicCredentialsManager)
      ? createPublicStakeKeysTracker({
          addresses$: this.addresses$,
          bip32Account: this.#publicCredentialsManager.bip32Account,
          rewardAccounts$: this.delegation.rewardAccounts$
        })
      : new TrackerSubject(of(new Array<PubStakeKeyAndStatus>()));

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
      : throwError(() => new InvalidConfigurationError('BaseWallet is missing a "handleProvider"'));

    this.util = createWalletUtil({
      chainHistoryProvider: this.chainHistoryProvider,
      protocolParameters$: this.protocolParameters$,
      transactions: this.transactions,
      utxo: this.utxo
    });

    const getPubDRepKey = async (): Promise<Ed25519PublicKeyHex | undefined> => {
      if (isBip32PublicCredentialsManager(this.#publicCredentialsManager)) {
        return (await this.#publicCredentialsManager.bip32Account.derivePublicKey(util.DREP_KEY_DERIVATION_PATH)).hex();
      }

      return undefined;
    };

    this.governance = {
      getPubDRepKey,
      isRegisteredAsDRep$: createDRepRegistrationTracker({
        historyTransactions$: this.transactions.history$,
        pubDRepKeyHash$: from(getPubDRepKey().then(getDRepKeyHash))
      })
    };

    this.#logger.debug('Created');
  }

  async getName(): Promise<string> {
    return this.name;
  }

  async initializeTx(props: InitializeTxProps): Promise<InitializeTxResult> {
    return initializeTx(props, this.getTxBuilderDependencies());
  }

  async finalizeTx({
    tx,
    bodyCbor,
    signingOptions,
    signingContext,
    auxiliaryData,
    isValid,
    witness
  }: FinalizeTxProps): Promise<Cardano.Tx> {
    const knownAddresses = await firstValueFrom(this.addresses$);
    const dRepPublicKey = await this.governance.getPubDRepKey();

    const context = {
      ...signingContext,
      dRepPublicKey,
      knownAddresses,
      txInKeyPathMap: await util.createTxInKeyPathMap(tx.body, knownAddresses, this.util)
    };

    const emptyWitness = { signatures: new Map() };

    // The Witnesser takes a serializable transaction. We cant build that from the hash alone, if
    // the bodyCbor is available, use that instead of the coreTx type to build the transaction.
    const transaction = new Serialization.Transaction(
      bodyCbor ? Serialization.TransactionBody.fromCbor(bodyCbor) : Serialization.TransactionBody.fromCore(tx.body),
      Serialization.TransactionWitnessSet.fromCore({ ...emptyWitness, ...witness }),
      auxiliaryData ? Serialization.AuxiliaryData.fromCore(auxiliaryData) : undefined
    );

    if (isValid !== undefined) transaction.setIsValid(isValid);

    const result = await this.witnesser.witness(transaction, context, signingOptions);

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
        ((CardanoNodeUtil.isValueNotConservedError(error.innerError) && !error.innerError.data) ||
          error.innerError.data.produced.coins === 0n ||
          // TODO: check if IncompleteWithdrawals available withdrawal amount === wallet's reward acc balance?
          // Not sure what the 'Withdrawals' in error data is exactly: value being withdrawed, or reward acc balance
          CardanoNodeUtil.isIncompleteWithdrawalsError(error.innerError) ||
          CardanoNodeUtil.isUnknownOutputReferences(error.innerError))
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
    input: Cardano.Tx | TxCBOR | OutgoingTx | WitnessedTx,
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
        //   because BaseWallet takes care of it internally.
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
    this.#addressTracker?.shutdown();
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

  async #isTxInFlight(txId: Cardano.TransactionId) {
    const inFlightTxs = await firstValueFrom(this.transactions.outgoing.inFlight$);
    return inFlightTxs.some((inFlight) => inFlight.id === txId);
  }

  /**
   * Utility function that creates the TxBuilderDependencies based on the BaseWallet observables.
   * All dependencies will wait until the wallet is settled before emitting.
   */
  getTxBuilderDependencies(): TxBuilderDependencies {
    return {
      bip32Account: isBip32PublicCredentialsManager(this.#publicCredentialsManager)
        ? this.#publicCredentialsManager.bip32Account
        : undefined,
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
      txEvaluator: new GreedyTxEvaluator(() => this.#firstValueFromSettled(this.protocolParameters$)),
      witnesser: this.witnesser
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

  async signData(props: SignDataProps): Promise<Cip30DataSignature> {
    if (isBip32PublicCredentialsManager(this.#publicCredentialsManager)) {
      return cip8.cip30signData({
        // LW-9989: signData probably needs to be refactored out of the wallet and supported as a stand alone util
        // as this operation doesnt require any of the wallet state. Also this operation can only be performed
        // by Bip32Ed25519 type of wallets.
        knownAddresses: await firstValueFrom(this.addresses$),
        witnesser: this.witnesser as util.Bip32Ed25519Witnesser,
        ...props
      });
    }

    throw new Error('getPubDRepKey is not supported by script wallets');
  }

  async discoverAddresses(): Promise<GroupedAddress[]> {
    if (isBip32PublicCredentialsManager(this.#publicCredentialsManager)) {
      const addresses = await this.#publicCredentialsManager.addressDiscovery.discover(
        this.#publicCredentialsManager.bip32Account
      );
      const knownAddresses = await firstValueFrom(this.addresses$);
      const newAddresses = addresses.filter(
        ({ address }) => !knownAddresses.some((knownAddr) => knownAddr.address === address)
      );
      await firstValueFrom(this.#addressTracker.addAddresses(newAddresses));
      return firstValueFrom(this.addresses$);
    }

    return firstValueFrom(this.addresses$);
  }

  /** Update the witness of a transaction with witness provided by this wallet */
  async updateWitness({ tx, sender }: UpdateWitnessProps): Promise<Cardano.Tx> {
    return this.finalizeTx({
      auxiliaryData: tx.auxiliaryData,
      signingContext: {
        sender
      },
      tx: { body: tx.body, hash: tx.id },
      witness: tx.witness
    });
  }
}
