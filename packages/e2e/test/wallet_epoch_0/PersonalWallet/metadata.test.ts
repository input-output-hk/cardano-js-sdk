import { BaseWallet, createWalletUtil } from '@cardano-sdk/wallet';
import { Cardano } from '@cardano-sdk/core';
import { KeyPurpose } from '@cardano-sdk/key-management';
import { filter, firstValueFrom, map } from 'rxjs';
import { getEnv, getWallet, walletReady, walletVariables } from '../../../src';
import { isNotNil } from '@cardano-sdk/util';
import { logger } from '@cardano-sdk/util-dev';

const env = getEnv(walletVariables);

describe('PersonalWallet/metadata', () => {
  let wallet: BaseWallet;
  let ownAddress: Cardano.PaymentAddress;

  beforeAll(async () => {
    wallet = (await getWallet({ env, logger, name: 'Test Wallet', purpose: KeyPurpose.STANDARD })).wallet;
    ownAddress = (await firstValueFrom(wallet.addresses$))[0].address;

    await walletReady(wallet);
  });

  afterAll(() => wallet.shutdown());

  test('can submit tx with metadata and then query it', async () => {
    const metadata: Cardano.TxMetadata = new Map([[123n, '1234']]);
    const walletUtil = createWalletUtil(wallet);
    const { minimumCoin } = await walletUtil.validateValue({ coins: 0n });

    // Make sure the wallet has sufficient funds to run this test
    await walletReady(wallet, minimumCoin);

    const { tx: signedTx } = await wallet
      .createTxBuilder()
      .addOutput({ address: ownAddress, value: { coins: minimumCoin } })
      .metadata(metadata)
      .build()
      .sign();

    const outgoingTx = signedTx;
    await wallet.submitTx(signedTx);

    const loadedTx = await firstValueFrom(
      wallet.transactions.history$.pipe(
        map((txs) => txs.find((tx) => tx.id === outgoingTx.id)),
        filter(isNotNil)
      )
    );
    expect(loadedTx.auxiliaryData?.blob).toEqual(metadata);
  });
});
