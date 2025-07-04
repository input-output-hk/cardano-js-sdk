import { BaseWallet, createWalletUtil } from '@cardano-sdk/wallet';
import { Cardano } from '@cardano-sdk/core';
import { firstValueFrom } from 'rxjs';
import { getEnv, getWallet, submitAndConfirm, walletReady, walletVariables } from '../../../src';
import { logger } from '@cardano-sdk/util-dev';

const env = getEnv(walletVariables);

describe('PersonalWallet/metadata', () => {
  let wallet: BaseWallet;
  let ownAddress: Cardano.PaymentAddress;

  beforeAll(async () => {
    wallet = (await getWallet({ env, logger, name: 'Test Wallet' })).wallet;
    ownAddress = (await firstValueFrom(wallet.addresses$))[0].address;

    await walletReady(wallet);
  });

  afterAll(() => wallet.shutdown());

  test('can submit tx with metadata and then query it', async () => {
    const metadata: Cardano.TxMetadata = new Map([[123n, '1234']]);
    const walletUtil = createWalletUtil(wallet);
    const { minimumCoin } = await walletUtil.validateOutput({
      address: Cardano.PaymentAddress(
        'addr_test1qqydn46r6mhge0kfpqmt36m6q43knzsd9ga32n96m89px3nuzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475qypp3m9'
      ),
      value: { coins: 0n }
    });

    // Make sure the wallet has sufficient funds to run this test
    await walletReady(wallet, minimumCoin);

    const { tx: signedTx } = await wallet
      .createTxBuilder()
      .addOutput({ address: ownAddress, value: { coins: minimumCoin } })
      .metadata(metadata)
      .build()
      .sign();

    const [, loadedTx] = await submitAndConfirm(wallet, signedTx, 1);

    expect(loadedTx.auxiliaryData?.blob).toEqual(metadata);
  });
});
