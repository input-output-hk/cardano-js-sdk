import { EMPTY, catchError, take, tap } from 'rxjs';
import { ObservableWallet } from '@cardano-sdk/wallet';
import { inspectAndSignTx } from '../utils';
import { logger } from '@cardano-sdk/util-dev';

export const singleUndelegation = ({
  connectedWallet
}: {
  connectedWallet: ObservableWallet;
}): Promise<{ hash: string; txId: string }> =>
  new Promise((resolve, reject) => {
    connectedWallet.balance.utxo.available$
      .pipe(
        take(1),
        tap(async (availableBalance) => {
          if (availableBalance.coins === 0n) {
            reject(new Error('Your wallet has no assets'));
          }

          if (!connectedWallet) {
            return null;
          }

          const builtTx = connectedWallet.createTxBuilder().delegatePortfolio(null).build();
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
