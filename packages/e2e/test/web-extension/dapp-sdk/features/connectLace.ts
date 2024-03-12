import { ConnectWalletDependencies, connectWallet, listWallets } from '@cardano-sdk/dapp-connector-client';
import { ObservableWallet } from '@cardano-sdk/wallet';
import { combineLatest, switchMap, tap } from 'rxjs';

export const connectToLace = ({
  dependencies,
  logger,
  onWalletConnected
}: {
  dependencies: ConnectWalletDependencies;
  logger: typeof console;
  onWalletConnected: (wallet: ObservableWallet) => void;
}) => {
  const infoElement = document.querySelector('#info')!;

  const wallets = listWallets({ logger });
  const lace = wallets.find(({ id }) => id === 'lace');
  if (!lace) {
    infoElement.textContent = 'Lace not found';
    return;
  }
  connectWallet(lace, dependencies)
    .pipe(
      tap((connected) => {
        onWalletConnected(connected.wallet);
      }),
      switchMap(({ wallet }) => combineLatest([wallet.addresses$, wallet.balance.utxo.available$])),
      tap(([addresses, balance]) => {
        infoElement.textContent = `
          Addresses: ${addresses.map((addr) => addr.address).join(', ')}
          \r\n
          Balance: ${balance.coins / 1_000_000n} ADA
        `;
      })
    )
    .subscribe();
};
