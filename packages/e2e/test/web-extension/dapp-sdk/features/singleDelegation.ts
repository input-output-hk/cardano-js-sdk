import { Cardano } from '@cardano-sdk/core';
import { EMPTY, catchError, take, tap } from 'rxjs';
import { Logger } from '@cardano-sdk/util-dev';
import { ObservableWallet } from '@cardano-sdk/wallet';
import { inspectAndSignTx } from '../utils';
import { toSerializableObject } from '@cardano-sdk/util';

type PoolData = {
  poolName: string;
  poolId: string;
};

export const singleDelegation = ({
  connectedWallet,
  logger,
  poolData
}: {
  logger: Logger;
  connectedWallet: ObservableWallet;
  poolData: PoolData;
}) => {
  const delegateElement = document.querySelector('#info-delegate-assets')!;
  const delegateAssetsElement = document.querySelector('#info-delegate-asset-id')!;
  const { poolName, poolId } = poolData;
  if (!poolName || !poolId) {
    throw new Error('Missing poolId and / or poolName');
  }

  connectedWallet.balance.utxo.available$
    .pipe(
      take(1),
      tap(async (availableBalance) => {
        if (availableBalance.coins === 0n) {
          throw new Error('Your wallet has no coins');
        }

        const poolIdHash = Cardano.PoolId.toKeyHash(Cardano.PoolId(poolId));
        const poolIdHex = Cardano.PoolIdHex(poolIdHash);
        const txBuilder = connectedWallet.createTxBuilder();
        const portfolio = {
          name: poolName,
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

        await inspectAndSignTx({ builtTx, connectedWallet, textElement: delegateAssetsElement });
      }),
      catchError((error) => {
        logger.error('Error fetching assets:', error);
        return EMPTY;
      })
    )
    .subscribe();
};
