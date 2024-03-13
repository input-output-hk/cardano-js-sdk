/* eslint-disable sonarjs/no-nested-template-literals */
import { EMPTY, catchError, take, tap } from 'rxjs';

import { inspectAndSignTx } from '../utils';
import type { ObservableWallet } from '@cardano-sdk/wallet';

export const sendSeveralAssets = ({
  connectedWallet,
  logger
}: {
  logger: typeof console;
  connectedWallet: ObservableWallet;
}) => {
  const addressAssetsElement = document.querySelector('#info-send')!;
  const transactionInfoElement = document.querySelector('#info-several-assets-tokens-transaction')!;

  connectedWallet.balance.utxo.available$
    .pipe(
      take(1),
      tap(async (availableBalance) => {
        if (!availableBalance.assets || availableBalance.assets?.size === 0) {
          throw new Error('Your wallet has no assets');
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

        inspectAndSignTx({ builtTx, connectedWallet, textElement: transactionInfoElement });

        addressAssetsElement.textContent += `
Assets and quantity:
${[...assetMap].map(([key, value]) => `- ${key} : ${value}`).join('\r\n')}
              `;
      }),
      catchError((error) => {
        logger.error('Error fetching assets:', error);
        return EMPTY;
      })
    )
    .subscribe();
};
