import { AddressType, GroupedAddress, KeyAgent } from './KeyManagement';
import {
  AssetProvider,
  BigIntMath,
  Cardano,
  NetworkInfo,
  ProtocolParametersRequiredByWallet,
  StakePoolSearchProvider,
  TimeSettings,
  TimeSettingsProvider,
  WalletProvider,
  coreToCsl
} from '@cardano-sdk/core';
import { Assets, InitializeTxResult, KeyManagement } from '.';
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
  createAssetsTracker,
  createBalanceTracker,
  createDelegationTracker,
  createNftMetadataProvider,
  createTransactionsTracker,
  createUtxoTracker,
  distinctBlock,
  distinctEpoch
} from './services';
import { InitializeTxProps, InitializeTxPropsValidationResult, MinimumCoinQuantity, Wallet } from './types';
import {
  InputSelector,
  computeMinimumCoinQuantity,
  defaultSelectionConstraints,
  roundRobinRandomImprove
} from '@cardano-sdk/cip2';
import { Logger, dummyLogger } from 'ts-log';
import { Observable, Subject, combineLatest, firstValueFrom, lastValueFrom, map, take } from 'rxjs';
import { RetryBackoffConfig } from 'backoff-rxjs';
import { TxInternals, createTransactionInternals, ensureValidityInterval } from './Transaction';
import { isEqual } from 'lodash-es';

export interface SingleAddressWalletProps {
  readonly name: string;
  readonly polling?: PollingConfig;
  readonly address?: GroupedAddress;
  readonly retryBackoffConfig?: RetryBackoffConfig;
}

export interface SingleAddressWalletDependencies {
  readonly keyAgent: KeyAgent;
  readonly walletProvider: WalletProvider;
  readonly stakePoolSearchProvider: StakePoolSearchProvider;
  readonly assetProvider: AssetProvider;
  readonly timeSettingsProvider: TimeSettingsProvider;
  readonly inputSelector?: InputSelector;
  readonly logger?: Logger;
}

export class SingleAddressWallet implements Wallet {
  #inputSelector: InputSelector;
  #keyAgent: KeyAgent;
  #walletProvider: WalletProvider;
  #logger: Logger;
  #tip$: SyncableIntervalTrackerSubject<Cardano.Tip>;
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
  networkInfo$: TrackerSubject<NetworkInfo>;
  addresses$: TrackerSubject<GroupedAddress[]>;
  protocolParameters$: TrackerSubject<ProtocolParametersRequiredByWallet>;
  genesisParameters$: TrackerSubject<Cardano.CompactGenesis>;
  timeSettings$: TrackerSubject<TimeSettings[]>;
  assets$: TrackerSubject<Assets>;
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
      keyAgent,
      assetProvider,
      timeSettingsProvider,
      logger = dummyLogger,
      inputSelector = roundRobinRandomImprove()
    }: SingleAddressWalletDependencies
  ) {
    this.#logger = logger;
    this.#inputSelector = inputSelector;
    this.#walletProvider = walletProvider;
    this.#keyAgent = keyAgent;
    this.addresses$ = new TrackerSubject<GroupedAddress[]>(this.#initializeAddress(address));
    this.name = name;
    this.#tip$ = this.tip$ = new SyncableIntervalTrackerSubject({
      pollInterval,
      provider$: coldObservableProvider(walletProvider.ledgerTip, retryBackoffConfig)
    });
    const tipBlockHeight$ = distinctBlock(this.tip$);
    this.networkInfo$ = new TrackerSubject(
      coldObservableProvider(walletProvider.networkInfo, retryBackoffConfig, tipBlockHeight$, isEqual)
    );
    const epoch$ = distinctEpoch(this.networkInfo$);
    this.timeSettings$ = new TrackerSubject(
      coldObservableProvider(timeSettingsProvider, retryBackoffConfig, epoch$, isEqual)
    );
    this.protocolParameters$ = new TrackerSubject(
      coldObservableProvider(walletProvider.currentWalletProtocolParameters, retryBackoffConfig, epoch$, isEqual)
    );
    this.genesisParameters$ = new TrackerSubject(
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
    this.assets$ = new TrackerSubject(
      createAssetsTracker({
        assetProvider,
        balanceTracker: this.balance,
        nftMetadataProvider: createNftMetadataProvider(
          walletProvider,
          // this is not very efficient, consider storing TxAlonzo[] in transactions tracker history
          this.transactions.history.all$.pipe(map((txs) => txs.map(({ tx }) => tx)))
        ),
        retryBackoffConfig
      })
    );
  }
  async validateInitializeTxProps(props: InitializeTxProps): Promise<InitializeTxPropsValidationResult> {
    const { coinsPerUtxoWord } = await firstValueFrom(this.protocolParameters$);
    const minimumCoinQuantities = new Map<Cardano.TxOut, MinimumCoinQuantity>();
    for (const output of props.outputs || []) {
      const minimumCoin = BigInt(computeMinimumCoinQuantity(coinsPerUtxoWord)(output.value.assets));
      minimumCoinQuantities.set(output, {
        coinMissing: BigIntMath.max([minimumCoin - output.value.coins, 0n])!,
        minimumCoin
      });
    }
    return { minimumCoinQuantities };
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
      ? KeyManagement.util.stubSignTransaction(tx.body, this.#keyAgent.knownAddresses)
      : await this.#keyAgent.signTransaction(tx);
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
        error: error as Cardano.TxSubmissionError,
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
    this.networkInfo$.complete();
    this.protocolParameters$.complete();
    this.genesisParameters$.complete();
    this.#tip$.complete();
    this.addresses$.complete();
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

  #initializeAddress(existingAddress?: GroupedAddress): Observable<GroupedAddress[]> {
    return new Observable((observer) => {
      if (existingAddress) {
        observer.next([existingAddress]);
        return;
      }
      this.#keyAgent
        .deriveAddress({
          index: 0,
          type: AddressType.External
        })
        .then((newAddress) => observer.next([newAddress]))
        .catch(observer.error);
    });
  }
}
