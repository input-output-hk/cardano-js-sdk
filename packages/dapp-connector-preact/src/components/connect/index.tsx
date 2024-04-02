import { ConnectWalletDependencies, connectWallet, listWallets } from '@cardano-sdk/dapp-connector-client';
import { ObservableWallet } from '@cardano-sdk/wallet';
import { combineLatest, switchMap, tap } from 'rxjs';
import { logger } from '@cardano-sdk/util-dev';

import { connectWalletDependencies } from '../../constants';
import { connectorStore } from '../../state/store';

export type OnWalletConnected = (wallet: ObservableWallet) => void;

const connectLace = (dependencies: ConnectWalletDependencies) => {
  const wallets = listWallets({ logger });
  const lace = wallets.find(({ id }) => id === 'lace');
  if (!lace) {
    return;
  }

  return connectWallet(lace, dependencies)
    .pipe(
      tap((connected) => {
        connectorStore.setConnectedWallet(connected.wallet);
      }),
      switchMap(({ wallet }) => combineLatest([wallet.addresses$, wallet.balance.utxo.available$])),
      tap(([addresses, balance]) => {
        connectorStore.setAddressesAndBalances(addresses, balance);
      })
    )
    .subscribe({
      error: (error) => console.error(error)
    });
};

export const Connect = () => <button onClick={() => connectLace(connectWalletDependencies)}>Connect wallet</button>;
