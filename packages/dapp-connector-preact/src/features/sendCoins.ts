import { ObservableWallet } from '@cardano-sdk/wallet';
import { inspectAndSignTx } from '../utils';

export const sendCoins = async ({
  connectedWallet
}: {
  connectedWallet: ObservableWallet;
}): Promise<{ hash: string; txId: string }> => {
  const builder = connectedWallet.createTxBuilder();
  const output = await builder.buildOutput().handle('rhys').coin(10_000_000n).build();
  const builtTx = builder.addOutput(output).build();

  return new Promise(async (resolve) => {
    const { hash, txId } = await inspectAndSignTx({ builtTx, connectedWallet });
    resolve({ hash, txId });
  });
};
