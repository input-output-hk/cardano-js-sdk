import { ObservableWallet } from '@cardano-sdk/wallet';
import { inspectAndSignTx } from '../utils';
import { take, tap } from 'rxjs';

export const singleUndelegation = ({
  connectedWallet
}: {
  logger: typeof console;
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

        inspectAndSignTx({ builtTx, connectedWallet, textElement: undelegateAssetsElement });
      })
    )
    .subscribe();
};
