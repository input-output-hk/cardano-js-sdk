import { BaseWallet } from '../../src';
import { BigIntMath } from '@cardano-sdk/util';
import { Cardano, coalesceValueQuantities } from '@cardano-sdk/core';
import { createWallet } from './util';
import { firstValueFrom } from 'rxjs';

describe('integration/txChainingBalance', () => {
  let wallet: BaseWallet;

  beforeAll(async () => {
    // Using mock TxSubmitProvider which doesn't do anything and instantly resolves
    ({ wallet } = await createWallet());
  });

  it('available balance includes change outputs from pending transaction', async () => {
    const utxo = await firstValueFrom(wallet.utxo.available$);
    const balanceBefore = await firstValueFrom(wallet.balance.utxo.available$);
    const outputCoins = utxo[0][1].value.coins + 1n; // will always select at least 2 utxo with mock utxo set
    const output: Cardano.TxOut = {
      address: Cardano.PaymentAddress(
        'addr_test1qzs0umu0s2ammmpw0hea0w2crtcymdjvvlqngpgqy76gpfnuzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475qp3y3vz'
      ),
      value: {
        coins: outputCoins
      }
    };
    const tx = await wallet.initializeTx({ outputs: new Set([output]) });
    // Precondition
    const coinsSpent = outputCoins + tx.body.fee - BigIntMath.sum((tx.body.withdrawals || []).map((w) => w.quantity));
    const totalOutputCoins = coalesceValueQuantities(tx.body.outputs.map((txOut) => txOut.value)).coins;
    expect(totalOutputCoins).toBeGreaterThan(coinsSpent);
    // Wallet will consider the transaction 'in flight' upon submission,
    // UtxoProvider will not see the new utxo from change outputs.
    // It's up to UtxoTracker to track those.
    await wallet.submitTx(await wallet.finalizeTx({ tx }));
    const balanceAfter = await firstValueFrom(wallet.balance.utxo.available$);
    expect(balanceAfter.coins).toEqual(balanceBefore.coins - coinsSpent);
  });

  afterAll(() => wallet.shutdown());
});
