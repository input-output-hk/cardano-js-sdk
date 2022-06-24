import { Cardano } from '@cardano-sdk/core';
import { SingleAddressWallet } from '@cardano-sdk/wallet';
import {
  assetProvider,
  chainHistoryProvider,
  keyAgent,
  networkInfoProvider,
  rewardsProvider,
  stakePoolProvider,
  txSubmitProvider,
  utxoProvider,
  walletProvider
} from '../../config';
import { filter, firstValueFrom, map } from 'rxjs';
import { isNotNil } from '@cardano-sdk/util';

describe('SingleAddressWallet/metadata', () => {
  let wallet: SingleAddressWallet;
  let ownAddress: Cardano.Address;

  beforeAll(async () => {
    wallet = new SingleAddressWallet(
      { name: 'Test Wallet' },
      {
        assetProvider: await assetProvider,
        chainHistoryProvider: await chainHistoryProvider,
        keyAgent: await keyAgent,
        networkInfoProvider: await networkInfoProvider,
        rewardsProvider: await rewardsProvider,
        stakePoolProvider: await stakePoolProvider,
        txSubmitProvider: await txSubmitProvider,
        utxoProvider: await utxoProvider,
        walletProvider: await walletProvider
      }
    );
    ownAddress = (await firstValueFrom(wallet.addresses$))[0].address;
  });

  afterAll(() => wallet.shutdown());

  test('can submit tx with metadata and then query it', async () => {
    const auxiliaryData: Cardano.AuxiliaryData = {
      body: {
        blob: new Map([[123n, '1234']])
      }
    };
    const txInternals = await wallet.initializeTx({
      auxiliaryData,
      outputs: new Set([{ address: ownAddress, value: { coins: 1_000_000n } }])
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
