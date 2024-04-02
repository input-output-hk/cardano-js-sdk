import { EMPTY, catchError, take, tap } from 'rxjs';
import { inspectAndSignTx } from '../utils';

import { Cardano } from '@cardano-sdk/core';
import { Logger } from '@cardano-sdk/util-dev';
import type { ObservableWallet } from '@cardano-sdk/wallet';

export const buildExpiredValidityIntervalTx = ({
  logger,
  connectedWallet,
  expired
}: {
  logger: Logger;
  connectedWallet: ObservableWallet;
  expired: boolean;
}) => {
  const sendInfoElement = document.querySelector('#info-send')!;

  connectedWallet.tip$
    .pipe(
      take(1),
      tap(async (tip) => {
        const expiredValidityInterval: Cardano.ValidityInterval = { invalidHereafter: Cardano.Slot(tip.blockNo) };
        const noLimitValidityInterval: Cardano.ValidityInterval = { invalidHereafter: undefined };

        const builder = connectedWallet.createTxBuilder();

        const builtTx = builder.addOutput(await builder.buildOutput().handle('rhys').coin(10_000_000n).build());

        const expiredValidityIntervalTx = builtTx
          .setValidityInterval(expired ? expiredValidityInterval : noLimitValidityInterval)
          .build();

        await inspectAndSignTx({ builtTx: expiredValidityIntervalTx, connectedWallet, textElement: sendInfoElement });
      }),
      catchError((error) => {
        logger.error('Failed to build tx', error);
        return EMPTY;
      })
    )
    .subscribe();
};
