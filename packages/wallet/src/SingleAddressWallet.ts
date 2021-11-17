import { AddressType, GroupedAddress, KeyManager } from './KeyManagement';
import {
  Balance,
  BehaviorObservable,
  DelegationTracker,
  FailedTx,
  PollingConfig,
  SyncableIntervalTrackerSubject,
  TrackerSubject,
  TransactionFailure,
  TransactionalTracker,
  TransactionsTracker,
  coldObservableProvider,
  createBalanceTracker,
  createDelegationTracker,
  createTransactionsTracker,
  createUtxoTracker,
  sharedDistinctBlock,
  sharedDistinctEpoch
} from './services';
import { BehaviorSubject, Subject, combineLatest, from, lastValueFrom, map, mergeMap, take } from 'rxjs';
import {
  Cardano,
  NetworkInfo,
  ProtocolParametersRequiredByWallet,
  StakePoolSearchProvider,
  WalletProvider,
  coreToCsl
} from '@cardano-sdk/core';
import { InitializeTxProps, Wallet } from './types';
import { InputSelector, defaultSelectionConstraints, roundRobinRandomImprove } from '@cardano-sdk/cip2';
import { Logger, dummyLogger } from 'ts-log';
import { RetryBackoffConfig } from 'backoff-rxjs';
import { TxInternals, computeImplicitCoin, createTransactionInternals, ensureValidityInterval } from './Transaction';
import { isEqual } from 'lodash-es';

export interface SingleAddressWalletProps {
  readonly name: string;
  readonly polling?: PollingConfig;
  readonly address?: GroupedAddress;
  readonly retryBackoffConfig?: RetryBackoffConfig;
}

export interface SingleAddressWalletDependencies {
  readonly keyManager: KeyManager;
  readonly walletProvider: WalletProvider;
  readonly stakePoolSearchProvider: StakePoolSearchProvider;
  readonly inputSelector?: InputSelector;
  readonly logger?: Logger;
}

export class SingleAddressWallet implements Wallet {
  #inputSelector: InputSelector;
  #keyManager: KeyManager;
  #walletProvider: WalletProvider;
  #logger: Logger;
  #tip$: SyncableIntervalTrackerSubject<Cardano.Tip>;
  #networkInfo$: TrackerSubject<NetworkInfo>;
  #protocolParameters$: TrackerSubject<ProtocolParametersRequiredByWallet>;
  #genesisParameters$: TrackerSubject<Cardano.CompactGenesis>;
  #newTransactions = {
    failedToSubmit$: new Subject<FailedTx>(),
    pending$: new Subject<Cardano.NewTxAlonzo>(),
    submitting$: new Subject<Cardano.NewTxAlonzo>()
  };
  utxo: TransactionalTracker<Cardano.Utxo[]>;
  balance: TransactionalTracker<Balance>;
  transactions: TransactionsTracker;
  delegation: DelegationTracker;
  tip$: BehaviorObservable<Cardano.Tip>;
  networkInfo$: BehaviorObservable<NetworkInfo>;
  addresses$: BehaviorSubject<GroupedAddress[]>;
  protocolParameters$: BehaviorObservable<ProtocolParametersRequiredByWallet>;
  genesisParameters$: BehaviorObservable<Cardano.CompactGenesis>;
  name: string;

  constructor(
    {
      name,
      polling: { interval: pollInterval = 15_000, maxInterval = 15_000 * 10 } = {},
      address,
      retryBackoffConfig = {
        initialInterval: Math.min(pollInterval, 1000),
        maxInterval
      }
    }: SingleAddressWalletProps,
    {
      walletProvider,
      stakePoolSearchProvider,
      keyManager,
      logger = dummyLogger,
      inputSelector = roundRobinRandomImprove()
    }: SingleAddressWalletDependencies
  ) {
    this.#logger = logger;
    this.#inputSelector = inputSelector;
    this.#walletProvider = walletProvider;
    this.#keyManager = keyManager;
    this.addresses$ = new BehaviorSubject([address || keyManager.deriveAddress(AddressType.External, 0)]);
    this.name = name;
    this.#tip$ = this.tip$ = new SyncableIntervalTrackerSubject({
      pollInterval,
      provider$: coldObservableProvider(walletProvider.ledgerTip, retryBackoffConfig)
    });
    const tipBlockHeight$ = sharedDistinctBlock(this.tip$);
    this.#networkInfo$ = this.networkInfo$ = new TrackerSubject(
      coldObservableProvider(walletProvider.networkInfo, retryBackoffConfig, tipBlockHeight$, isEqual)
    );
    const epoch$ = sharedDistinctEpoch(this.networkInfo$);
    this.#protocolParameters$ = this.protocolParameters$ = new TrackerSubject(
      coldObservableProvider(walletProvider.currentWalletProtocolParameters, retryBackoffConfig, epoch$, isEqual)
    );
    this.#genesisParameters$ = this.genesisParameters$ = new TrackerSubject(
      coldObservableProvider(walletProvider.genesisParameters, retryBackoffConfig, epoch$, isEqual)
    );

    const addresses$ = this.addresses$.pipe(
      map((addresses) => addresses.map((groupedAddress) => groupedAddress.address))
    );
    this.transactions = createTransactionsTracker({
      addresses$,
      newTransactions: this.#newTransactions,
      retryBackoffConfig,
      tip$: this.tip$,
      walletProvider
    });
    this.utxo = createUtxoTracker({
      addresses$,
      retryBackoffConfig,
      tipBlockHeight$,
      transactionsInFlight$: this.transactions.outgoing.inFlight$,
      walletProvider
    });
    this.delegation = createDelegationTracker({
      epoch$,
      retryBackoffConfig,
      rewardAccountAddresses$: this.addresses$.pipe(
        map((addresses) => addresses.map((groupedAddress) => groupedAddress.rewardAccount))
      ),
      stakePoolSearchProvider,
      transactionsTracker: this.transactions,
      walletProvider
    });
    this.balance = createBalanceTracker(this.protocolParameters$, this.utxo, this.delegation);
  }
  initializeTx(props: InitializeTxProps): Promise<TxInternals> {
    return lastValueFrom(
      combineLatest([this.tip$, this.utxo.available$, this.protocolParameters$]).pipe(
        take(1),
        mergeMap(([tip, utxo, protocolParameters]) => {
          const validityInterval = ensureValidityInterval(tip.slot, props.options?.validityInterval);
          const txOutputs = new Set([...(props.outputs || [])].map((output) => coreToCsl.txOut(output)));
          const changeAddress = this.addresses$.value[0].address;
          const constraints = defaultSelectionConstraints({
            buildTx: async (inputSelection) => {
              this.#logger.debug('Building TX for selection constraints', inputSelection);
              const txInternals = await createTransactionInternals({
                certificates: props.certificates,
                changeAddress,
                inputSelection,
                validityInterval,
                withdrawals: props.withdrawals
              });
              return coreToCsl.tx(await this.finalizeTx(txInternals));
            },
            protocolParameters
          });
          const implicitCoin = computeImplicitCoin(protocolParameters, props);
          return from(
            this.#inputSelector
              .select({
                constraints,
                implicitCoin,
                outputs: txOutputs,
                utxo: new Set(coreToCsl.utxo(utxo))
              })
              .then((inputSelectionResult) =>
                createTransactionInternals({
                  certificates: props.certificates,
                  changeAddress,
                  inputSelection: inputSelectionResult.selection,
                  validityInterval,
                  withdrawals: props.withdrawals
                })
              )
          );
        })
      )
    );
  }
  async finalizeTx(tx: TxInternals, auxiliaryData?: Cardano.AuxiliaryData): Promise<Cardano.NewTxAlonzo> {
    const signatures = await this.#keyManager.signTransaction(tx);
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
      await this.#walletProvider.submitTx(coreToCsl.tx(tx).to_bytes());
      this.#newTransactions.pending$.next(tx);
    } catch (error) {
      this.#newTransactions.failedToSubmit$.next({
        reason: TransactionFailure.FailedToSubmit,
        tx
      });
      throw error;
    }
  }
  sync() {
    this.#tip$.sync();
  }
  shutdown() {
    this.balance.shutdown();
    this.utxo.shutdown();
    this.transactions.shutdown();
    this.#networkInfo$.complete();
    this.#protocolParameters$.complete();
    this.#genesisParameters$.complete();
    this.#tip$.complete();
  }
}
