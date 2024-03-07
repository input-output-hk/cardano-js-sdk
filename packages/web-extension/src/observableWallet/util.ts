import { ObservableWallet } from '@cardano-sdk/wallet';
import { OutputBuilder, TxBuilder } from '@cardano-sdk/tx-construction';
import { RemoteApiProperties, RemoteApiPropertyType } from '../messaging';
import { WalletRepository } from '../walletManager';

export const observableWalletChannel = (walletName: string) => `${walletName}$`;

export const outputBuilderProperties: RemoteApiProperties<OutputBuilder> = {
  address: {
    getApiProperties: () => outputBuilderProperties,
    propType: RemoteApiPropertyType.ApiFactory
  },
  asset: {
    getApiProperties: () => outputBuilderProperties,
    propType: RemoteApiPropertyType.ApiFactory
  },
  assets: {
    getApiProperties: () => outputBuilderProperties,
    propType: RemoteApiPropertyType.ApiFactory
  },
  build: RemoteApiPropertyType.MethodReturningPromise,
  coin: {
    getApiProperties: () => outputBuilderProperties,
    propType: RemoteApiPropertyType.ApiFactory
  },
  datum: {
    getApiProperties: () => outputBuilderProperties,
    propType: RemoteApiPropertyType.ApiFactory
  },
  handle: {
    getApiProperties: () => outputBuilderProperties,
    propType: RemoteApiPropertyType.ApiFactory
  },
  inspect: RemoteApiPropertyType.MethodReturningPromise,
  value: {
    getApiProperties: () => outputBuilderProperties,
    propType: RemoteApiPropertyType.ApiFactory
  }
};

export const txBuilderProperties: RemoteApiProperties<Omit<TxBuilder, 'customize'>> = {
  addOutput: {
    getApiProperties: () => txBuilderProperties,
    propType: RemoteApiPropertyType.ApiFactory
  },
  build: {
    getApiProperties: () => ({
      inspect: RemoteApiPropertyType.MethodReturningPromise,
      sign: RemoteApiPropertyType.MethodReturningPromise
    }),
    propType: RemoteApiPropertyType.ApiFactory
  },
  buildOutput: {
    getApiProperties: () => outputBuilderProperties,
    propType: RemoteApiPropertyType.ApiFactory
  },
  delegatePortfolio: {
    getApiProperties: () => txBuilderProperties,
    propType: RemoteApiPropertyType.ApiFactory
  },
  extraSigners: {
    getApiProperties: () => txBuilderProperties,
    propType: RemoteApiPropertyType.ApiFactory
  },
  inspect: RemoteApiPropertyType.MethodReturningPromise,
  metadata: {
    getApiProperties: () => txBuilderProperties,
    propType: RemoteApiPropertyType.ApiFactory
  },
  removeOutput: {
    getApiProperties: () => txBuilderProperties,
    propType: RemoteApiPropertyType.ApiFactory
  },
  signingOptions: {
    getApiProperties: () => txBuilderProperties,
    propType: RemoteApiPropertyType.ApiFactory
  }
};

export const observableWalletProperties: RemoteApiProperties<ObservableWallet> = {
  addresses$: RemoteApiPropertyType.HotObservable,
  assetInfo$: RemoteApiPropertyType.HotObservable,
  balance: {
    rewardAccounts: {
      deposit$: RemoteApiPropertyType.HotObservable,
      rewards$: RemoteApiPropertyType.HotObservable
    },
    utxo: {
      available$: RemoteApiPropertyType.HotObservable,
      total$: RemoteApiPropertyType.HotObservable,
      unspendable$: RemoteApiPropertyType.HotObservable
    }
  },
  createTxBuilder: {
    getApiProperties: () => txBuilderProperties,
    propType: RemoteApiPropertyType.ApiFactory
  },
  currentEpoch$: RemoteApiPropertyType.HotObservable,
  delegation: {
    distribution$: RemoteApiPropertyType.HotObservable,
    portfolio$: RemoteApiPropertyType.HotObservable,
    rewardAccounts$: RemoteApiPropertyType.HotObservable,
    rewardsHistory$: RemoteApiPropertyType.HotObservable
  },
  discoverAddresses: RemoteApiPropertyType.MethodReturningPromise,
  eraSummaries$: RemoteApiPropertyType.HotObservable,
  fatalError$: RemoteApiPropertyType.HotObservable,
  finalizeTx: RemoteApiPropertyType.MethodReturningPromise,
  genesisParameters$: RemoteApiPropertyType.HotObservable,
  getName: RemoteApiPropertyType.MethodReturningPromise,
  getPubDRepKey: RemoteApiPropertyType.MethodReturningPromise,
  handles$: RemoteApiPropertyType.HotObservable,
  initializeTx: RemoteApiPropertyType.MethodReturningPromise,
  protocolParameters$: RemoteApiPropertyType.HotObservable,
  publicStakeKeys$: RemoteApiPropertyType.HotObservable,
  signData: RemoteApiPropertyType.MethodReturningPromise,
  submitTx: RemoteApiPropertyType.MethodReturningPromise,
  syncStatus: {
    isAnyRequestPending$: RemoteApiPropertyType.HotObservable,
    isSettled$: RemoteApiPropertyType.HotObservable,
    isUpToDate$: RemoteApiPropertyType.HotObservable
  },
  tip$: RemoteApiPropertyType.HotObservable,
  transactions: {
    history$: RemoteApiPropertyType.HotObservable,
    outgoing: {
      failed$: RemoteApiPropertyType.HotObservable,
      inFlight$: RemoteApiPropertyType.HotObservable,
      onChain$: RemoteApiPropertyType.HotObservable,
      pending$: RemoteApiPropertyType.HotObservable,
      signed$: RemoteApiPropertyType.HotObservable,
      submitting$: RemoteApiPropertyType.HotObservable
    },
    rollback$: RemoteApiPropertyType.HotObservable
  },
  utxo: {
    available$: RemoteApiPropertyType.HotObservable,
    setUnspendable: RemoteApiPropertyType.MethodReturningPromise,
    total$: RemoteApiPropertyType.HotObservable,
    unspendable$: RemoteApiPropertyType.HotObservable
  }
};

// eslint-disable-next-line @typescript-eslint/no-explicit-any
export const walletRepositoryProperties: RemoteApiProperties<WalletRepository<any, any>> = {
  addAccount: RemoteApiPropertyType.MethodReturningPromise,
  addWallet: RemoteApiPropertyType.MethodReturningPromise,
  removeAccount: RemoteApiPropertyType.MethodReturningPromise,
  removeWallet: RemoteApiPropertyType.MethodReturningPromise,
  updateAccountMetadata: RemoteApiPropertyType.MethodReturningPromise,
  updateWalletMetadata: RemoteApiPropertyType.MethodReturningPromise,
  wallets$: RemoteApiPropertyType.HotObservable
};
