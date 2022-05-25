import { ObservableWallet } from '@cardano-sdk/wallet';
import { RemoteApiProperties, RemoteApiPropertyType } from '../messaging';

export type ExposedObservableWalletProperties = Omit<ObservableWallet, 'shutdown'>;

export const observableWalletChannel = (walletName: string) => `${walletName}$`;

export const observableWalletProperties: RemoteApiProperties<ExposedObservableWalletProperties> = {
  addresses$: RemoteApiPropertyType.Observable,
  assets$: RemoteApiPropertyType.Observable,
  balance: {
    available$: RemoteApiPropertyType.Observable,
    total$: RemoteApiPropertyType.Observable,
    unspendable$: RemoteApiPropertyType.Observable
  },
  currentEpoch$: RemoteApiPropertyType.Observable,
  delegation: {
    rewardAccounts$: RemoteApiPropertyType.Observable,
    rewardsHistory$: RemoteApiPropertyType.Observable
  },
  finalizeTx: RemoteApiPropertyType.MethodReturningPromise,
  genesisParameters$: RemoteApiPropertyType.Observable,
  getName: RemoteApiPropertyType.MethodReturningPromise,
  initializeTx: RemoteApiPropertyType.MethodReturningPromise,
  networkInfo$: RemoteApiPropertyType.Observable,
  protocolParameters$: RemoteApiPropertyType.Observable,
  signData: RemoteApiPropertyType.MethodReturningPromise,
  submitTx: RemoteApiPropertyType.MethodReturningPromise,
  syncStatus: {
    isAnyRequestPending$: RemoteApiPropertyType.Observable,
    isSettled$: RemoteApiPropertyType.Observable,
    isUpToDate$: RemoteApiPropertyType.Observable
  },
  tip$: RemoteApiPropertyType.Observable,
  transactions: {
    history$: RemoteApiPropertyType.Observable,
    outgoing: {
      confirmed$: RemoteApiPropertyType.Observable,
      failed$: RemoteApiPropertyType.Observable,
      inFlight$: RemoteApiPropertyType.Observable,
      pending$: RemoteApiPropertyType.Observable,
      submitting$: RemoteApiPropertyType.Observable
    }
  },
  utxo: {
    available$: RemoteApiPropertyType.Observable,
    total$: RemoteApiPropertyType.Observable,
    unspendable$: RemoteApiPropertyType.Observable
  }
};
