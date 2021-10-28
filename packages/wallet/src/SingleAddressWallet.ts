import { Balance } from './types';
import {
  BehaviorObservable,
  DirectionalTransaction,
  FailedTx,
  NewTx,
  PollingConfig,
  ProviderTrackerSubject,
  SimpleProvider,
  SourceTrackerConfig,
  SourceTransactionalTracker,
  TransactionalTracker,
  Transactions,
  Wallet,
  createAddressTransactionsProvider$,
  createTransactionsTracker,
  createUtxoProvider$,
  createUtxoTracker
} from './prototype';
import { CSL, Cardano, ProtocolParametersRequiredByWallet, WalletProvider, coreToCsl } from '@cardano-sdk/core';
import {
  InitializeTxProps,
  TxInternals,
  computeImplicitCoin,
  createTransactionInternals,
  ensureValidityInterval
} from './Transaction';
import { InputSelector, defaultSelectionConstraints, roundRobinRandomImprove } from '@cardano-sdk/cip2';
import { KeyManager } from './KeyManagement';
import { Logger, dummyLogger } from 'ts-log';
import { Subject, combineLatest, from, lastValueFrom, mergeMap, take } from 'rxjs';
import { TransactionFailure } from './TransactionError';
import { createBalanceTracker, createRewardsProvider$, createRewardsTracker } from './services';

export interface SingleAddressWalletProps {
  readonly name: string;
  readonly polling?: PollingConfig;
}

export interface SingleAddressWalletDependencies {
  readonly keyManager: KeyManager;
  readonly walletProvider: WalletProvider;
  readonly inputSelector?: InputSelector;
  readonly logger?: Logger;
}

export interface SingleAddressWalletConfiguration {
  readonly address?: Cardano.Address;
  // TODO: change function naming convention to not have $ suffix
  readonly utxoProvider$?: SimpleProvider<Cardano.Utxo[]>;
  readonly tipProvider$?: SimpleProvider<Cardano.Tip>;
  readonly rewardsProvider$?: SimpleProvider<Cardano.Lovelace>;
  readonly protocolParametersProvider$?: SimpleProvider<ProtocolParametersRequiredByWallet>;
  readonly transactionsProvider$?: SimpleProvider<DirectionalTransaction[]>;
  readonly sourceTrackerConfig?: SourceTrackerConfig;
}

export class SingleAddressWallet implements Wallet {
  #inputSelector: InputSelector;
  #keyManager: KeyManager;
  #walletProvider: WalletProvider;
  #address: Cardano.Address;
  #logger: Logger;
  #tip$: ProviderTrackerSubject<Cardano.Tip>;
  #protocolParameters$: ProviderTrackerSubject<ProtocolParametersRequiredByWallet>;
  #newTransactions = {
    failedToSubmit$: new Subject<FailedTx>(),
    pending$: new Subject<NewTx>(),
    submitting$: new Subject<NewTx>()
  };
  #rewards: SourceTransactionalTracker<Cardano.Lovelace>;
  utxo: SourceTransactionalTracker<Cardano.Utxo[]>;
  balance: TransactionalTracker<Balance>;
  transactions: Transactions;
  tip$: BehaviorObservable<Cardano.Tip>;
  protocolParameters$: BehaviorObservable<ProtocolParametersRequiredByWallet>;
  name: string;

  constructor(
    {
      name,
      polling: { interval, maxInterval } = { interval: 15_000, maxInterval: 15_000 * 10 }
    }: SingleAddressWalletProps,
    {
      walletProvider,
      keyManager,
      logger = dummyLogger,
      inputSelector = roundRobinRandomImprove()
    }: SingleAddressWalletDependencies,
    {
      address = keyManager.deriveAddress(0, 0),
      utxoProvider$ = createUtxoProvider$(walletProvider, [address]),
      tipProvider$ = () => from(walletProvider.ledgerTip()),
      rewardsProvider$ = createRewardsProvider$(walletProvider, [address], keyManager),
      transactionsProvider$ = createAddressTransactionsProvider$(walletProvider, [address]),
      protocolParametersProvider$ = () => from(walletProvider.currentWalletProtocolParameters()),
      sourceTrackerConfig: config = {
        maxInterval,
        pollInterval: interval
      }
    }: SingleAddressWalletConfiguration = {}
  ) {
    this.#logger = logger;
    this.#inputSelector = inputSelector;
    this.#walletProvider = walletProvider;
    this.#keyManager = keyManager;
    this.#address = address;
    this.#tip$ = this.tip$ = new ProviderTrackerSubject({ config, provider: tipProvider$ });
    this.#protocolParameters$ = this.protocolParameters$ = new ProviderTrackerSubject({
      config,
      provider: protocolParametersProvider$
    });

    this.name = name;
    this.transactions = createTransactionsTracker({
      config,
      newTransactions: this.#newTransactions,
      tip$: this.tip$,
      transactionsProvider: transactionsProvider$
    });
    this.utxo = createUtxoTracker({
      config,
      transactionsInFlight$: this.transactions.outgoing.inFlight$,
      utxoProvider: utxoProvider$
    });
    this.#rewards = createRewardsTracker({
      config,
      keyManager,
      rewardsProvider: rewardsProvider$,
      transactionsInFlight$: this.transactions.outgoing.inFlight$
    });
    this.balance = createBalanceTracker(this.utxo, this.#rewards);
  }
  get addresses(): string[] {
    return [this.#address];
  }
  initializeTx(props: InitializeTxProps): Promise<TxInternals> {
    return lastValueFrom(
      combineLatest([this.tip$, this.utxo.available$, this.protocolParameters$]).pipe(
        take(1),
        mergeMap(([tip, utxo, protocolParameters]) => {
          const validityInterval = ensureValidityInterval(tip.slot, props.options?.validityInterval);
          const txOutputs = new Set([...props.outputs].map((output) => coreToCsl.txOut(output)));
          const changeAddress = this.addresses[0];
          const constraints = defaultSelectionConstraints({
            buildTx: async (inputSelection) => {
              this.#logger.debug('Building TX for selection constraints', inputSelection);
              const { body, hash } = await createTransactionInternals({
                changeAddress,
                inputSelection,
                validityInterval
              });
              return this.finalizeTx({ body, hash });
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
  async finalizeTx({ body, hash }: TxInternals): Promise<CSL.Transaction> {
    const witnessSet = await this.#keyManager.signTransaction(hash);
    return CSL.Transaction.new(body, witnessSet);
  }
  async submitTx(tx: CSL.Transaction): Promise<void> {
    this.#newTransactions.submitting$.next(tx);
    try {
      await this.#walletProvider.submitTx(tx);
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
    this.utxo.sync();
    this.transactions.sync();
    this.#tip$.sync();
    this.#protocolParameters$.sync();
    this.#rewards.sync();
  }
  shutdown() {
    this.#rewards.shutdown();
    this.utxo.shutdown();
    this.transactions.shutdown();
    this.#tip$.complete();
    this.#protocolParameters$.complete();
  }
}
