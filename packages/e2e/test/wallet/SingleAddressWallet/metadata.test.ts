import { Cardano } from '@cardano-sdk/core';
import { SingleAddressWallet, buildTx, createWalletUtil } from '@cardano-sdk/wallet';
import { env } from '../environment';
import { filter, firstValueFrom, map } from 'rxjs';
import { getWallet } from '../../../src/factories';
import { isNotNil } from '@cardano-sdk/util';
import { logger } from '@cardano-sdk/util-dev';

describe('SingleAddressWallet/metadata', () => {
  let wallet: SingleAddressWallet;
  let ownAddress: Cardano.Address;

  beforeAll(async () => {
    wallet = (await getWallet({ env, logger, name: 'Test Wallet' })).wallet;
    ownAddress = (await firstValueFrom(wallet.addresses$))[0].address;
  });

  afterAll(() => wallet.shutdown());

  test('can submit tx with metadata and then query it', async () => {
    const metadata: Cardano.TxMetadata = new Map([[123n, '1234']]);
    const walletUtil = createWalletUtil(wallet);
    const { minimumCoin } = await walletUtil.validateValue({ coins: 0n });

    const builtTx = await buildTx(wallet)
      .addOutput({ address: ownAddress, value: { coins: minimumCoin } })
      .setMetadata(metadata)
      .build();

    if (!builtTx.isValid) {
      throw new Error('Invalid tx');
    }

    const signedTx = await builtTx.sign();
    const outgoingTx = signedTx.tx;
    await signedTx.submit();

    const loadedTx = await firstValueFrom(
      wallet.transactions.history$.pipe(
        map((txs) => txs.find((tx) => tx.id === outgoingTx.id)),
        filter(isNotNil)
      )
    );
    expect(loadedTx.auxiliaryData?.body.blob).toEqual(metadata);
  });
});
