import { Address, AddressType, InitializeTxProps, Wallet } from './types';
import {
  Balance,
  BehaviorObservable,
  Delegation,
  FailedTx,
  PollingConfig,
  SyncableIntervalTrackerSubject,
  TrackerSubject,
  TransactionFailure,
  TransactionalTracker,
  Transactions,
  coldObservableProvider,
  createBalanceTracker,
  createDelegationTracker,
  createRewardsTracker,
  createTransactionsTracker,
  createUtxoTracker,
  sharedDistinctBlock,
  sharedDistinctEpoch
} from './services';
import {
  Cardano,
  NetworkInfo,
  ProtocolParametersRequiredByWallet,
  StakePoolSearchProvider,
  WalletProvider,
  coreToCsl
} from '@cardano-sdk/core';
import { InputSelector, defaultSelectionConstraints, roundRobinRandomImprove } from '@cardano-sdk/cip2';
import { KeyManager } from './KeyManagement';
import { Logger, dummyLogger } from 'ts-log';
import { RetryBackoffConfig } from 'backoff-rxjs';
import { Subject, combineLatest, from, lastValueFrom, mergeMap, take } from 'rxjs';
import { TxInternals, computeImplicitCoin, createTransactionInternals, ensureValidityInterval } from './Transaction';
import { isEqual } from 'lodash-es';

export interface SingleAddressWalletProps {
  readonly name: string;
  readonly polling?: PollingConfig;
  readonly address?: Address;
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
  #address: Address;
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
  #rewards: TransactionalTracker<Cardano.Lovelace>;
  utxo: TransactionalTracker<Cardano.Utxo[]>;
  balance: TransactionalTracker<Balance>;
  transactions: Transactions;
  delegation: Delegation;
  tip$: BehaviorObservable<Cardano.Tip>;
  networkInfo$: BehaviorObservable<NetworkInfo>;
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
    this.#address = address || {
      accountIndex: 0,
      bech32: keyManager.deriveAddress(0, 0),
      index: 0,
      type: AddressType.External
    };
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
    const addresses = this.addresses.map(({ bech32 }) => bech32);
    this.transactions = createTransactionsTracker({
      addresses,
      newTransactions: this.#newTransactions,
      retryBackoffConfig,
      tip$: this.tip$,
      walletProvider
    });
    this.utxo = createUtxoTracker({
      addresses,
      retryBackoffConfig,
      tipBlockHeight$,
      transactionsInFlight$: this.transactions.outgoing.inFlight$,
      walletProvider
    });
    this.#rewards = createRewardsTracker({
      epoch$,
      keyManager,
      retryBackoffConfig,
      transactionsInFlight$: this.transactions.outgoing.inFlight$,
      walletProvider
    });
    this.balance = createBalanceTracker(this.utxo, this.#rewards);
    this.delegation = createDelegationTracker({
      epoch$,
      keyManager,
      retryBackoffConfig,
      stakePoolSearchProvider,
      transactionsTracker: this.transactions,
      walletProvider
    });
  }
  get addresses(): Address[] {
    return [this.#address];
  }
  initializeTx(props: InitializeTxProps): Promise<TxInternals> {
    return lastValueFrom(
      combineLatest([this.tip$, this.utxo.available$, this.protocolParameters$]).pipe(
        take(1),
        mergeMap(([tip, utxo, protocolParameters]) => {
          const validityInterval = ensureValidityInterval(tip.slot, props.options?.validityInterval);
          const txOutputs = new Set([...props.outputs].map((output) => coreToCsl.txOut(output)));
          const changeAddress = this.addresses[0].bech32;
          const constraints = defaultSelectionConstraints({
            buildTx: async (inputSelection) => {
              this.#logger.debug('Building TX for selection constraints', inputSelection);
              const txInternals = await createTransactionInternals({
                changeAddress,
                inputSelection,
                validityInterval
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
                  changeAddress,
                  inputSelection: inputSelectionResult.selection,
                  validityInterval
                })
              )
          );
        })
      )
    );
  }
  async finalizeTx({ body, hash }: TxInternals, auxiliaryData?: Cardano.AuxiliaryData): Promise<Cardano.NewTxAlonzo> {
    const signatures = await this.#keyManager.signTransaction(hash);
    return {
      auxiliaryData,
      body,
      id: hash,
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
    this.#rewards.shutdown();
    this.utxo.shutdown();
    this.transactions.shutdown();
    this.#networkInfo$.complete();
    this.#protocolParameters$.complete();
    this.#genesisParameters$.complete();
    this.#tip$.complete();
  }
}
