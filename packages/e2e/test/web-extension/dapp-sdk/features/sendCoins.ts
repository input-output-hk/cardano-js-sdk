/* eslint-disable @typescript-eslint/no-explicit-any */
import type { ObservableWallet } from '@cardano-sdk/wallet';

export const sendCoins = async ({ connectedWallet }: { connectedWallet: ObservableWallet }) => {
  const sendInfoElement = document.querySelector('#info-send')!;

  const builder = connectedWallet.createTxBuilder();
  const builtTx = builder.addOutput(await builder.buildOutput().handle('rhys').coin(10_000_000n).build()).build();
  const txDetails = await builtTx.inspect();
  sendInfoElement.textContent = `Built: ${txDetails.hash}`;
  const signedTx = await builtTx.sign();
  sendInfoElement.textContent = `Signed: ${signedTx.tx.id}`;
  await connectedWallet.submitTx(signedTx);
  sendInfoElement.textContent = `Submitted: ${signedTx.tx.id}`;
};
