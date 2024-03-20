/* eslint-disable promise/no-nesting */
/* eslint-disable @typescript-eslint/no-explicit-any */
import { Logger } from '@cardano-sdk/util-dev';
import { UnwitnessedTx } from '@cardano-sdk/tx-construction';
import type { ObservableWallet } from '@cardano-sdk/wallet';

export const inspectAndSignTx = async ({
  connectedWallet,
  builtTx,
  textElement,
  logger
}: {
  connectedWallet: ObservableWallet;
  builtTx: UnwitnessedTx;
  textElement: any;
  logger: Logger;
}) => {
  builtTx
    .inspect()
    .then((txDetails) => {
      textElement.textContent = `Built: ${txDetails.hash}`;
      return builtTx.sign();
    })
    .then((signedTx) => {
      textElement.textContent = `Signed: ${signedTx.tx.id}`;
      return connectedWallet.submitTx(signedTx).catch((error) => {
        logger.error('Error on submit:', error);
      });
    })
    .then((signedTxId) => {
      if (signedTxId === undefined || signedTxId === null) {
        return 'No signedTx was made';
      }
      textElement.textContent = `Submitted: ${signedTxId}`;
      return null;
    })
    .catch((error) => {
      logger.error('Error:', error);
    });
};
