import { Cardano, util } from '@cardano-sdk/core';
import { SingleAddressWallet } from '../../../src';
import {
  assetProvider,
  keyAgentReady,
  stakePoolSearchProvider,
  timeSettingsProvider,
  txSubmitProvider,
  walletProvider
} from '../config';
import { filter, firstValueFrom, map } from 'rxjs';

describe('SingleAddressWallet/metadata', () => {
  let wallet: SingleAddressWallet;
  let ownAddress: Cardano.Address;

  beforeAll(async () => {
    wallet = new SingleAddressWallet(
      { name: 'Test Wallet' },
      {
        assetProvider,
        keyAgent: await keyAgentReady,
        stakePoolSearchProvider,
        timeSettingsProvider,
        txSubmitProvider,
        walletProvider
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
      wallet.transactions.history.outgoing$.pipe(
        map((txs) => txs.find((tx) => tx.id === outgoingTx.id)),
        filter(util.isNotNil)
      )
    );
    expect(loadedTx.auxiliaryData).toEqual(auxiliaryData);
  });
});
