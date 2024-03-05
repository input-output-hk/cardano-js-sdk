/* eslint-disable @typescript-eslint/no-explicit-any */
import { ConnectWalletDependencies, connectWallet, listWallets } from '@cardano-sdk/dapp-connector-client';
import {
  assetInfoHttpProvider,
  chainHistoryHttpProvider,
  handleHttpProvider,
  networkInfoHttpProvider,
  rewardsHttpProvider,
  stakePoolHttpProvider
} from '@cardano-sdk/cardano-services-client';
import { combineLatest, switchMap, tap } from 'rxjs';
import type { ObservableWallet } from '@cardano-sdk/wallet';

const logger = console;
const httpProviderDependencies = {
  baseUrl: 'https://dev-preprod.lw.iog.io',
  logger
};
const dependencies: ConnectWalletDependencies = {
  assetProvider: assetInfoHttpProvider(httpProviderDependencies),
  chainHistoryProvider: chainHistoryHttpProvider(httpProviderDependencies),
  handleProvider: handleHttpProvider(httpProviderDependencies),
  logger,
  networkInfoProvider: networkInfoHttpProvider(httpProviderDependencies),
  rewardsProvider: rewardsHttpProvider(httpProviderDependencies),
  stakePoolProvider: stakePoolHttpProvider(httpProviderDependencies)
};

const infoElement = document.querySelector('#info')!;
const sendInfoElement = document.querySelector('#info-send')!;
let connectedWallet: ObservableWallet | null;

(window as any).connectLace = async () => {
  const wallets = listWallets({ logger });
  const lace = wallets.find(({ id }) => id === 'lace');
  if (!lace) {
    infoElement.textContent = 'Lace not found';
    return;
  }
  connectWallet(lace, dependencies)
    .pipe(
      tap((connected) => (connectedWallet = connected.wallet)),
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

(window as any).sendCoins = async () => {
  if (!connectedWallet) {
    return logger.warn('Please connect the wallet first');
  }
  const builder = connectedWallet.createTxBuilder();
  const builtTx = builder.addOutput(await builder.buildOutput().handle('rhys').coin(10_000_000n).build()).build();
  const txDetails = await builtTx.inspect();
  sendInfoElement.textContent = `Built: ${txDetails.hash}`;
  const signedTx = await builtTx.sign();
  sendInfoElement.textContent = `Signed: ${signedTx.tx.id}`;
  await connectedWallet.submitTx(signedTx);
  sendInfoElement.textContent = `Submitted: ${signedTx.tx.id}`;
};
