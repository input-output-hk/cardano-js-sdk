import { UnwitnessedTx } from '@cardano-sdk/tx-construction';
import type { ObservableWallet } from '@cardano-sdk/wallet';

export const inspectAndSignTx = async ({
  connectedWallet,
  builtTx
}: {
  connectedWallet: ObservableWallet;
  builtTx: UnwitnessedTx;
}) => {
  const txDetails = await builtTx.inspect();
  const hash = txDetails.hash;
  const signedTx = await builtTx.sign();
  const txId = signedTx.tx.id;
  await connectedWallet.submitTx(signedTx);

  return { hash, txId };
};
