import { Cardano } from '@cardano-sdk/core';
import { SingleAddressWallet, createWalletUtil } from '@cardano-sdk/wallet';
import { env } from '../environment';
import { filter, firstValueFrom, map } from 'rxjs';
import { getWallet } from '../../../src/factories';
import { isNotNil } from '@cardano-sdk/util';

describe('SingleAddressWallet/metadata', () => {
  let wallet: SingleAddressWallet;
  let ownAddress: Cardano.Address;

  beforeAll(async () => {
    wallet = (await getWallet({ env, name: 'Test Wallet' })).wallet;
    ownAddress = (await firstValueFrom(wallet.addresses$))[0].address;
  });

  afterAll(() => wallet.shutdown());

  test('can submit tx with metadata and then query it', async () => {
    const auxiliaryData: Cardano.AuxiliaryData = {
      body: {
        blob: new Map([[123n, '1234']])
      }
    };
    const walletUtil = createWalletUtil(wallet);
    const { minimumCoin } = await walletUtil.validateValue({ coins: 0n });
    const txInternals = await wallet.initializeTx({
      auxiliaryData,
      outputs: new Set([{ address: ownAddress, value: { coins: minimumCoin } }])
    });
    const outgoingTx = await wallet.finalizeTx(txInternals, auxiliaryData);
    await wallet.submitTx(outgoingTx);
    const loadedTx = await firstValueFrom(
      wallet.transactions.history$.pipe(
        map((txs) => txs.find((tx) => tx.id === outgoingTx.id)),
        filter(isNotNil)
      )
    );
    expect(loadedTx.auxiliaryData).toEqual(auxiliaryData);
  });
});
