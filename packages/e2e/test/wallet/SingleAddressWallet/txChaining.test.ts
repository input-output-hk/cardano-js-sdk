import { Cardano } from '@cardano-sdk/core';
import { ObservableWallet } from '@cardano-sdk/wallet';
import { env } from '../environment';
import { filter, firstValueFrom } from 'rxjs';
import { getWallet } from '../../../src/factories';
import { waitForWalletStateSettle } from '../util';

describe('SingleAddressWallet', () => {
  let wallet: ObservableWallet;

  beforeAll(async () => {
    jest.setTimeout(180_000);
    wallet = (await getWallet({ env, name: 'Test Wallet' })).wallet;
    await waitForWalletStateSettle(wallet);
  });

  afterAll(() => {
    wallet.shutdown();
  });

  const waitForTxInBlockchain = (txId: Cardano.TransactionId) =>
    firstValueFrom(wallet.transactions.history$.pipe(filter((txs) => txs.filter((tx) => tx.id === txId).length === 1)));

  test('txChaining', async () => {
    const { address } = (await firstValueFrom(wallet.addresses$))[0];
    const { coins } = await firstValueFrom(wallet.balance.utxo.available$);

    const moreThanHalfOfTheBalanceCoins = (coins * 60n) / 100n;

    const tx1 = await wallet.initializeTx({
      outputs: new Set([{ address, value: { coins: moreThanHalfOfTheBalanceCoins } }])
    });

    const finalizedTx1 = await wallet.finalizeTx(tx1);
    await wallet.submitTx(finalizedTx1);

    const tx2 = await wallet.initializeTx({
      outputs: new Set([{ address, value: { coins: moreThanHalfOfTheBalanceCoins } }])
    });

    // Assert attempting to do tx chaining
    const usingTx1OutputAsInput = [...tx2.inputSelection.inputs].some(([txIn]) => txIn.txId === finalizedTx1.id);
    expect(usingTx1OutputAsInput).toBe(true);

    const finalizedTx2 = await wallet.finalizeTx(tx2);

    try {
      await wallet.submitTx(finalizedTx2);
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
    } catch (error: any) {
      throw error.innerError ? error.innerError : error;
    }

    // Wait for txs in the blockchain to increase test consistency with subsequential executions
    await Promise.all([waitForTxInBlockchain(finalizedTx1.id), waitForTxInBlockchain(finalizedTx2.id)]);
  });
});
