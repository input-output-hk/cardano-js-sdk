/* eslint-disable unicorn/no-nested-ternary */
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
  CardanoNodeErrors,
  ChainHistoryProvider,
  EpochInfo,
  EraSummary,
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
  InitializeTxProps,
  InitializeTxResult,
  ObservableWallet,
  SignDataProps,
  SyncStatus,
  WalletNetworkInfoProvider
} from '../types';
import {
  BalanceTracker,
  ConnectionStatus,
  ConnectionStatusTracker,
  DelegationTracker,
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
import { BehaviorObservable, TrackerSubject } from '@cardano-sdk/util-rxjs';
import {
  BehaviorSubject,
  EMPTY,
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
  tap
} from 'rxjs';
import { Cip30DataSignature } from '@cardano-sdk/dapp-connector';
import { InputSelector, roundRobinRandomImprove } from '@cardano-sdk/input-selection';
import { Logger } from 'ts-log';
import { ManagedFreeableScope, Shutdown, contextLogger, deepEquals } from '@cardano-sdk/util';
import { PrepareTx, createTxPreparer } from './prepareTx';
import { RetryBackoffConfig } from 'backoff-rxjs';
import { TrackedUtxoProvider } from '../services/ProviderTracker/TrackedUtxoProvider';
import { WalletStores, createInMemoryWalletStores } from '../persistence';
import { createTransactionInternals } from '../Transaction';
import { createTransactionReemitter } from '../services/TransactionReemitter';
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

export interface SubmitTxOptions {
  mightBeAlreadySubmitted?: boolean;
}

export const DEFAULT_POLLING_CONFIG = {
  maxInterval: 5000 * 20,
  maxIntervalMultiplier: 20,
  pollInterval: 5000
};

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

export class SingleAddressWallet implements ObservableWallet {
  #inputSelector: InputSelector;
  #logger: Logger;
  #tip$: TipTracker;
  #prepareTx: PrepareTx;
  #newTransactions = {
    failedToSubmit$: new Subject<FailedTx>(),
    pending$: new Subject<OutgoingTx>(),
    submitting$: new Subject<OutgoingTx>()
  };
  #reemitSubscriptions: Subscription;
  #failedFromReemitter$: Subject<FailedTx>;
  #trackedTxSubmitProvider: TrackedTxSubmitProvider;

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
  readonly assets$: TrackerSubject<Assets>;
  readonly fatalError$: Subject<unknown>;
  readonly syncStatus: SyncStatus;
  readonly name: string;
  readonly util: WalletUtil;
  readonly rewardsProvider: TrackedRewardsProvider;

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
    this.#trackedTxSubmitProvider = new TrackedTxSubmitProvider(txSubmitProvider);

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

    this.fatalError$ = new Subject();

    const onFatalError = this.fatalError$.next.bind(this.fatalError$);

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
      maxInterval,
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
    this.assets$ = new PersistentDocumentTrackerSubject(
      createAssetsTracker({
        assetProvider: this.assetProvider,
        balanceTracker: this.balance,
        logger: contextLogger(this.#logger, 'assets$'),
        onFatalError,
        retryBackoffConfig
      }),
      stores.assets
    );
    this.util = createWalletUtil(this);
    this.#prepareTx = createTxPreparer({
      logger: this.#logger,
      signer: {
        stubFinalizeTx: (finalizeTxProps) => from(this.finalizeTx(finalizeTxProps, true))
      },
      wallet: this
    });
    this.#logger.debug('Created');
  }

  async getName(): Promise<string> {
    return this.name;
  }

  async initializeTx(props: InitializeTxProps): Promise<InitializeTxResult> {
    const scope = new ManagedFreeableScope();
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

    scope.dispose();
    return { body, hash, inputSelection };
  }

  async finalizeTx(props: FinalizeTxProps, stubSign = false): Promise<Cardano.Tx> {
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
          error.innerError instanceof CardanoNodeErrors.TxSubmissionErrors.UnknownOrIncompleteWithdrawalsError)
      ) {
        this.#logger.debug(`Transaction ${outgoingTx.id} appears to be already submitted...`);
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
    this.assets$.complete();
    this.fatalError$.complete();
    this.syncStatus.shutdown();
    this.#newTransactions.failedToSubmit$.complete();
    this.#newTransactions.pending$.complete();
    this.#newTransactions.submitting$.complete();
    this.#reemitSubscriptions.unsubscribe();
    this.#failedFromReemitter$.complete();
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
}
