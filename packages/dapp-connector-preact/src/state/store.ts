import { Cardano } from '@cardano-sdk/core';
import { ObservableWallet, WalletAddress } from '@cardano-sdk/wallet';
import { Subject } from 'rxjs';

type LogEntry = {
  title: string;
  hash: string;
  txId: string;
};

export type Store = {
  wallet?: ObservableWallet;
  addresses?: Array<WalletAddress>;
  balance?: Cardano.Value;
  log: Array<LogEntry>;
};

const subject = new Subject<Store>();

const initialState: Store = {
  addresses: [],
  log: []
};

let state = initialState;

export const connectorStore = {
  init: () => {
    subject.next(state);
  },
  initialState,
  log: (entry: LogEntry) => {
    state = {
      ...state,
      log: [...state.log, entry]
    };
    subject.next(state);
  },
  setAddressesAndBalances: (addresses: Store['addresses'], balance: Store['balance']) => {
    // get the connected wallet and get the addresses and balances
    state = {
      ...state,
      addresses,
      balance
    };
    subject.next(state);
  },
  setConnectedWallet: (wallet: ObservableWallet) => {
    state = {
      ...state,
      wallet
    };

    subject.next(state);
  },
  subscribe: (setState: (value: Store) => void) => subject.subscribe(setState)
};
