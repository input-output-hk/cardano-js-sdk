/* eslint-disable @typescript-eslint/no-explicit-any */
import { UnsignedTx } from '@cardano-sdk/tx-construction';
import type { ObservableWallet } from '@cardano-sdk/wallet';

export const buildAndSignTx = async ({
  connectedWallet,
  builtTx,
  textElement
}: {
  connectedWallet: ObservableWallet;
  builtTx: UnsignedTx;
  textElement: any;
}) => {
  const txDetails = await builtTx.inspect();
  textElement.textContent = `Built: ${txDetails.hash}`;
  const signedTx = await builtTx.sign();
  textElement.textContent = `Signed: ${signedTx.tx.id}`;
  await connectedWallet.submitTx(signedTx);
  textElement.textContent = `Submitted: ${signedTx.tx.id}`;
};
