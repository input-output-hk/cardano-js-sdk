import { ObservableWallet } from '@cardano-sdk/wallet';
import { RemoteApiProperties, RemoteApiPropertyType } from '../messaging';

export const observableWalletChannel = (walletName: string) => `${walletName}$`;

export const observableWalletProperties: RemoteApiProperties<ObservableWallet> = {
  addresses$: RemoteApiPropertyType.HotObservable,
  assets$: RemoteApiPropertyType.HotObservable,
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
  currentEpoch$: RemoteApiPropertyType.HotObservable,
  delegation: {
    rewardAccounts$: RemoteApiPropertyType.HotObservable,
    rewardsHistory$: RemoteApiPropertyType.HotObservable
  },
  eraSummaries$: RemoteApiPropertyType.HotObservable,
  fatalError$: RemoteApiPropertyType.HotObservable,
  finalizeTx: RemoteApiPropertyType.MethodReturningPromise,
  genesisParameters$: RemoteApiPropertyType.HotObservable,
  getName: RemoteApiPropertyType.MethodReturningPromise,
  initializeTx: RemoteApiPropertyType.MethodReturningPromise,
  protocolParameters$: RemoteApiPropertyType.HotObservable,
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
      confirmed$: RemoteApiPropertyType.HotObservable,
      failed$: RemoteApiPropertyType.HotObservable,
      inFlight$: RemoteApiPropertyType.HotObservable,
      pending$: RemoteApiPropertyType.HotObservable,
      submitting$: RemoteApiPropertyType.HotObservable
    },
    rollback$: RemoteApiPropertyType.HotObservable
  },
  utxo: {
    available$: RemoteApiPropertyType.HotObservable,
    total$: RemoteApiPropertyType.HotObservable,
    unspendable$: RemoteApiPropertyType.HotObservable
  }
};
