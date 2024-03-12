/* eslint-disable @typescript-eslint/no-explicit-any */
import { buildAndSignTx } from '../utils';
import type { ObservableWallet } from '@cardano-sdk/wallet';

export const sendCoins = async ({ connectedWallet }: { connectedWallet: ObservableWallet }) => {
  const sendInfoElement = document.querySelector('#info-send')!;

  const builder = connectedWallet.createTxBuilder();
  const builtTx = builder.addOutput(await builder.buildOutput().handle('rhys').coin(10_000_000n).build()).build();
  buildAndSignTx({ builtTx, connectedWallet, textElement: sendInfoElement });
};
