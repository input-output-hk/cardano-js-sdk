/* eslint-disable @typescript-eslint/no-explicit-any */
import { catchError, combineLatest, tap, EMPTY } from 'rxjs';
import type { ObservableWallet } from '@cardano-sdk/wallet';

export const sendSeveralAssets = ({
  connectedWallet,
  logger
}: {
  logger: typeof console;
  connectedWallet: ObservableWallet;
}) => {
  const addressAssetsElement = document.querySelector('#info-several-assets-tokens')!;

  combineLatest([connectedWallet.addresses$, connectedWallet.balance.utxo.available$])
    .pipe(
      tap(async ([addresses, availableBalance]) => {
        if (!connectedWallet) {
          return logger.warn('Please connect the wallet first');
        }
        if (!availableBalance.assets || availableBalance.assets?.size === 0) {
          throw new Error('No assets');
        }

        let nftCount = 0;
        let tokenCount = 0;
        const assetMap = new Map();
        for (const [key, value] of availableBalance.assets) {
          if (value === 1n && nftCount < 1) {
            nftCount++;
            assetMap.set(key, value);
          } else if (value > 1n && tokenCount < 1) {
            tokenCount++;
            assetMap.set(key, 1000n);
          }
        }

        if (assetMap.size < 2) throw new Error("Didn't find 1NFT and FT to send");

        const txBuilder = connectedWallet.createTxBuilder();
        const builtTx = txBuilder
          .addOutput(await txBuilder.buildOutput().handle('rhys').coin(10_000_000n).assets(assetMap).build())
          .build();

        const txDetails = await builtTx.inspect();
        addressAssetsElement.textContent = `Built: ${txDetails.hash}`;
        const signedTx = await builtTx.sign();
        addressAssetsElement.textContent = `Signed: ${signedTx.tx.id}`;
        await connectedWallet.submitTx(signedTx);
        addressAssetsElement.textContent = `Submitted: ${signedTx.tx.id}`;

        addressAssetsElement.textContent = `
                Addresses: ${addresses.map((addr) => addr.address).join(', ')}
                \r\n
                Assets: ${availableBalance.assets}
              `;
      }),
      catchError((error) => {
        console.error('Error fetching assets:', error);
        return EMPTY;
      })
    )
    .subscribe();
};
