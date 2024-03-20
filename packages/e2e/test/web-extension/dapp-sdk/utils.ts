/* eslint-disable promise/no-nesting */
/* eslint-disable @typescript-eslint/no-explicit-any */
import { UnwitnessedTx } from '@cardano-sdk/tx-construction';
import type { ObservableWallet } from '@cardano-sdk/wallet';

export const inspectAndSignTx = async ({
  connectedWallet,
  builtTx,
  textElement
}: {
  connectedWallet: ObservableWallet;
  builtTx: UnwitnessedTx;
  textElement: any;
}) => {
  const txDetails = await builtTx.inspect();
  textElement.textContent = `Built: ${txDetails.hash}`;
  const signedTx = await builtTx.sign();
  textElement.textContent = `Signed: ${signedTx.tx.id}`;
  await connectedWallet.submitTx(signedTx);
  textElement.textContent = `Submitted: ${signedTx.tx.id}`;
};
