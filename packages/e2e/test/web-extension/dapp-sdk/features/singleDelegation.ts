import { Cardano } from '@cardano-sdk/core';
import { ObservableWallet } from '@cardano-sdk/wallet';
import { inspectAndSignTx } from '../utils';
import { take, tap } from 'rxjs';
import { toSerializableObject } from '@cardano-sdk/util';

export const singleDelegation = ({
  connectedWallet
}: {
  logger: typeof console;
  connectedWallet: ObservableWallet;
}) => {
  const delegateElement = document.querySelector('#info-delegate-assets')!;
  const delegateAssetsElement = document.querySelector('#info-delegate-asset-id')!;

  connectedWallet.balance.utxo.available$
    .pipe(
      take(1),
      tap(async (availableBalance) => {
        if (availableBalance.coins === 0n) {
          throw new Error('Your wallet has no coins');
        }

        const poolId = Cardano.PoolId.toKeyHash(
          Cardano.PoolId('pool1pzdqdxrv0k74p4q33y98f2u7vzaz95et7mjeedjcfy0jcgk754f')
        );
        const poolIdHex = Cardano.PoolIdHex(poolId);
        const txBuilder = connectedWallet.createTxBuilder();
        const portfolio = {
          name: 'SMAUG',
          pools: [
            {
              id: Cardano.PoolIdHex(poolIdHex),
              weight: 1
            }
          ]
        };

        const builtTx = txBuilder.delegatePortfolio(portfolio).build();

        const inspection = await builtTx.inspect();
        delegateElement.textContent = `Built: ${JSON.stringify(toSerializableObject(inspection))}`;

        inspectAndSignTx({ builtTx, connectedWallet, textElement: delegateAssetsElement });
      })
    )
    .subscribe();
};
