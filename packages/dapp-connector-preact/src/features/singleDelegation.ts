import { Cardano } from '@cardano-sdk/core';
import { EMPTY, catchError, take, tap } from 'rxjs';
import { ObservableWallet } from '@cardano-sdk/wallet';
import { inspectAndSignTx } from '../utils';
import { logger } from '@cardano-sdk/util-dev';

export const singleDelegation = ({
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
            reject(new Error('Your wallet has no coins'));
          }

          const poolId = Cardano.PoolId.toKeyHash(
            Cardano.PoolId('pool1pzdqdxrv0k74p4q33y98f2u7vzaz95et7mjeedjcfy0jcgk754f')
          );
          const poolIdHex = Cardano.PoolIdHex(poolId);
          const portfolio = {
            name: 'SMAUG',
            pools: [
              {
                id: Cardano.PoolIdHex(poolIdHex),
                weight: 1
              }
            ]
          };
          if (!connectedWallet) {
            return null;
          }

          const builder = connectedWallet.createTxBuilder();
          const builtTxDelegatingPortfolio = builder.delegatePortfolio(portfolio).build();
          const { hash, txId } = await inspectAndSignTx({
            builtTx: builtTxDelegatingPortfolio,
            connectedWallet
          });

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
