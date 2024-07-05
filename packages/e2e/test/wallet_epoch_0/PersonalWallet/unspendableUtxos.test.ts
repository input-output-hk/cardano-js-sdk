/* eslint-disable sonarjs/no-duplicate-string */
import { BaseWallet, utxoEquals } from '@cardano-sdk/wallet';
import { createLogger } from '@cardano-sdk/util-dev';
import { filter, firstValueFrom, map, take } from 'rxjs';
import { firstValueFromTimed, getEnv, getWallet, walletReady, walletVariables } from '../../../src';
import { isNotNil } from '@cardano-sdk/util';

const env = getEnv(walletVariables);
const logger = createLogger();

describe('PersonalWallet/unspendableUtxos', () => {
  let wallet1: BaseWallet;
  let wallet2: BaseWallet;

  afterAll(() => {
    wallet1.shutdown();
    wallet2.shutdown();
  });

  // TODO: troubleshot, this is a flaky test, sometimes `expect(unspendableUtxo).toEqual([]);` is not empty
  // eslint-disable-next-line max-statements
  it.skip('unsets unspendable UTxOs when no longer in the wallets UTxO set', async () => {
    // Here we will simulate the scenario of collateral consumption by spending it from another wallet instance.
    wallet1 = (await getWallet({ env, logger, name: 'Wallet 1' })).wallet;
    wallet2 = (await getWallet({ env, logger, name: 'Wallet 2' })).wallet;

    const coins = 5_000_000n;
    await walletReady(wallet1, coins);
    await walletReady(wallet2, coins);

    const txBuilder1 = wallet1.createTxBuilder();
    const txBuilder2 = wallet2.createTxBuilder();

    const address = (await firstValueFrom(wallet1.addresses$))[0].address;

    // Create a new UTxO to be use as collateral.
    const txOutput = await txBuilder1.buildOutput().address(address).coin(5_000_000n).build();

    const { tx: signedTx } = await txBuilder1.addOutput(txOutput).build().sign();
    await wallet1.submitTx(signedTx);

    // Search chain history to see if the transaction is there.
    let txFoundInHistory = await firstValueFromTimed(
      wallet1.transactions.history$.pipe(
        map((txs) => txs.find((tx) => tx.id === signedTx.id)),
        filter(isNotNil),
        take(1)
      ),
      `Failed to find transaction ${signedTx.id} in src wallet history`
    );

    // Find the UTxO in the UTxO set.
    const utxo = await firstValueFromTimed(
      wallet1.utxo.available$.pipe(
        map((utxos) => utxos.find((o) => o[0].txId === signedTx.id && o[1].value.coins === 5_000_000n)),
        filter(isNotNil),
        take(1)
      ),
      `Failed to find utxo from txId ${signedTx.id} with coin value 5_000_000n in src wallet`
    );

    // Set UTxO as unspendable.
    await wallet1.utxo.setUnspendable([utxo]);

    // Get unspendable UTxO from wallet 1
    let unspendableUtxo = await firstValueFrom(wallet1.utxo.unspendable$);
    let totalUtxos = await firstValueFrom(wallet1.utxo.total$);
    let availableUtxo = await firstValueFrom(wallet1.utxo.available$);

    let totalUtxoHasUnspendable = totalUtxos.find((totalUtxoEntry) => utxoEquals([totalUtxoEntry], unspendableUtxo));
    let availableUtxoHasUnspendable = availableUtxo.find((availableUtxoEntry) =>
      utxoEquals([availableUtxoEntry], unspendableUtxo)
    );

    expect(unspendableUtxo).toEqual([utxo]);
    expect(totalUtxoHasUnspendable).toBeTruthy();
    expect(availableUtxoHasUnspendable).toBeFalsy();

    // Spend the UTxO from the second wallet which uses a different store. We will transfer the whole balance
    // to force the input selection to select our UTxO
    const totalBalance = await firstValueFrom(wallet1.balance.utxo.total$);
    // We must leave some ADA behind to cover for transaction fees and min ADA of change output, however; this amount
    // must be less than the collateral UTxO to guarantee that the UTxO is moved.
    totalBalance.coins -= 4_500_000n;

    // Wait until wallet2 has the transaction in chain history
    txFoundInHistory = await firstValueFromTimed(
      wallet2.transactions.history$.pipe(
        map((txs) => txs.find((tx) => tx.id === signedTx.id)),
        filter(isNotNil),
        take(1)
      ),
      `Failed to find transaction ${signedTx.id} in dest wallet history`
    );

    const { tx: signedMoveAdaTx } = await txBuilder2
      .addOutput(await txBuilder2.buildOutput().address(address).value(totalBalance).build())
      .build()
      .sign();
    await wallet2.submitTx(signedMoveAdaTx);

    // Search chain history to see if the transaction is there.
    txFoundInHistory = await firstValueFromTimed(
      wallet1.transactions.history$.pipe(
        map((txs) => txs.find((tx) => tx.id === signedMoveAdaTx.id)),
        filter(isNotNil),
        take(1)
      ),
      `Failed to find second transaction ${signedMoveAdaTx.id} in dest wallet history`
    );

    expect(txFoundInHistory.id).toEqual(signedMoveAdaTx.id);

    // Try to get the unspendable UTxO from wallet1 again
    unspendableUtxo = await firstValueFrom(wallet1.utxo.unspendable$);
    totalUtxos = await firstValueFrom(wallet1.utxo.total$);
    availableUtxo = await firstValueFrom(wallet1.utxo.available$);

    totalUtxoHasUnspendable = totalUtxos.find((totalUtxoEntry) => utxoEquals([totalUtxoEntry], unspendableUtxo));
    availableUtxoHasUnspendable = availableUtxo.find((availableUtxoEntry) =>
      utxoEquals([availableUtxoEntry], unspendableUtxo)
    );

    expect(unspendableUtxo).toEqual([]);
    expect(totalUtxoHasUnspendable).toBeFalsy();
    expect(availableUtxoHasUnspendable).toBeFalsy();
  });
});
