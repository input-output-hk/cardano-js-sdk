import { EMPTY, catchError, take, tap } from 'rxjs';
import { inspectAndSignTx } from '../utils';

import { Cardano } from '@cardano-sdk/core';
import type { ObservableWallet } from '@cardano-sdk/wallet';

export const setExpiredValidityInterval = async ({
  logger,
  connectedWallet
}: {
  logger: typeof console;
  connectedWallet: ObservableWallet;
}) => {
  const sendInfoElement = document.querySelector('#info-send')!;

  connectedWallet.tip$
    .pipe(
      take(1),
      tap(async (tip) => {
        const validityInterval: Cardano.ValidityInterval = { invalidHereafter: Cardano.Slot(tip.blockNo) };

        const builder = connectedWallet.createTxBuilder();

        const builtTx = builder.addOutput(await builder.buildOutput().handle('rhys').coin(10_000_000n).build());

        const expiredValidityIntervalTx = builtTx.setValidityInterval(validityInterval).build();

        inspectAndSignTx({ builtTx: expiredValidityIntervalTx, connectedWallet, textElement: sendInfoElement });
      }),
      catchError((error) => {
        logger.error('Error in fetching tip of chain', error);
        return EMPTY;
      })
    )
    .subscribe();
};
