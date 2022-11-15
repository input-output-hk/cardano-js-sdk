import { ObservableWallet } from '@cardano-sdk/wallet';
import { env } from '../../environment';
import { firstValueFrom } from 'rxjs';
import { getWallet } from '../../../src/factories';
import { logger } from '@cardano-sdk/util-dev';
import { submitAndConfirm, walletReady } from '../../util';

describe('SingleAddressWallet', () => {
  let wallet: ObservableWallet;

  beforeAll(async () => {
    jest.setTimeout(180_000);
    wallet = (await getWallet({ env, logger, name: 'Test Wallet' })).wallet;

    await walletReady(wallet);
  });

  afterAll(() => {
    wallet.shutdown();
  });

  test('txChaining', async () => {
    const { address } = (await firstValueFrom(wallet.addresses$))[0];
    const { coins } = await firstValueFrom(wallet.balance.utxo.available$);

    const moreThanHalfOfTheBalanceCoins = (coins * 60n) / 100n;

    const tx1 = await wallet.initializeTx({
      outputs: new Set([{ address, value: { coins: moreThanHalfOfTheBalanceCoins } }])
    });

    const finalizedTx1 = await wallet.finalizeTx({ tx: tx1 });
    await wallet.submitTx(finalizedTx1);

    const tx2 = await wallet.initializeTx({
      outputs: new Set([{ address, value: { coins: moreThanHalfOfTheBalanceCoins } }])
    });

    // Assert attempting to do tx chaining
    const usingTx1OutputAsInput = [...tx2.inputSelection.inputs].some(([txIn]) => txIn.txId === finalizedTx1.id);
    expect(usingTx1OutputAsInput).toBe(true);

    const finalizedTx2 = await wallet.finalizeTx({ tx: tx2 });

    // 1st tx must also be confirmed because the 2nd one uses output from the 1st one
    await submitAndConfirm(wallet, finalizedTx2);
  });
});
