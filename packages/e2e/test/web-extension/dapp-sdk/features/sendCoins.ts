/* eslint-disable @typescript-eslint/no-explicit-any */
import { inspectAndSignTx } from '../utils';
import type { ObservableWallet } from '@cardano-sdk/wallet';

export const sendCoins = async ({ connectedWallet }: { connectedWallet: ObservableWallet }) => {
  const sendInfoElement = document.querySelector('#info-send')!;

  const builder = connectedWallet.createTxBuilder();
  const builtTx = builder.addOutput(await builder.buildOutput().handle('rhys').coin(10_000_000n).build()).build();
  inspectAndSignTx({ builtTx, connectedWallet, textElement: sendInfoElement });
};
