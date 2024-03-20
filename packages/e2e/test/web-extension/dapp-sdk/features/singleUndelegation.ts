import { EMPTY, catchError, take, tap } from 'rxjs';
import { Logger } from '@cardano-sdk/util-dev';
import { ObservableWallet } from '@cardano-sdk/wallet';
import { inspectAndSignTx } from '../utils';

export const singleUndelegation = ({
  connectedWallet,
  logger
}: {
  logger: Logger;
  connectedWallet: ObservableWallet;
}) => {
  const undelegateAssetsElement = document.querySelector('#info-undelegate-assets')!;

  connectedWallet.balance.utxo.available$
    .pipe(
      take(1),
      tap(async (availableBalance) => {
        if (availableBalance.coins === 0n) {
          throw new Error('Your wallet has no assets');
        }

        const builtTx = connectedWallet.createTxBuilder().delegatePortfolio(null).build();

        await inspectAndSignTx({ builtTx, connectedWallet, textElement: undelegateAssetsElement });
      }),
      catchError((error) => {
        logger.error('Error fetching assets:', error);
        return EMPTY;
      })
    )
    .subscribe();
};
