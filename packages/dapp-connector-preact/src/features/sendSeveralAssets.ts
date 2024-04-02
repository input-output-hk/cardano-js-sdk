import { EMPTY, catchError, take, tap } from 'rxjs';
import { ObservableWallet } from '@cardano-sdk/wallet';
import { inspectAndSignTx } from '../utils';
import { logger } from '@cardano-sdk/util-dev';

export const sendSeveralAssets = ({
  connectedWallet
}: {
  connectedWallet: ObservableWallet;
}): Promise<{ hash: string; txId: string }> =>
  new Promise((resolve, reject) => {
    connectedWallet.balance.utxo.available$
      .pipe(
        take(1),
        tap(async (availableBalance) => {
          if (!availableBalance.assets || availableBalance.assets?.size === 0) {
            reject(new Error('Your wallet has no assets'));
            return;
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

          if (assetMap.size < 2) reject(new Error("Didn't find 1NFT and FT to send"));

          if (!connectedWallet) {
            return null;
          }

          const builder = connectedWallet.createTxBuilder();
          const output = await builder.buildOutput().handle('rhys').coin(10_000_000n).build();
          const builtTx = builder.addOutput(output).build();
          const { hash, txId } = await inspectAndSignTx({ builtTx, connectedWallet });

          resolve({ hash, txId });
        }),
        catchError((error) => {
          logger.error('Error fetching assets', error);
          reject(new Error('Error fetching assets'));
          return EMPTY;
        })
      )
      .subscribe();
  });
