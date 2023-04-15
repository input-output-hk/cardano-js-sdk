/* eslint-disable sonarjs/no-duplicate-string */
import { SingleAddressWallet, buildTx, utxoEquals } from '@cardano-sdk/wallet';
import { assertTxIsValid } from '../../../../wallet/test/util';
import { contextLogger, isNotNil } from '@cardano-sdk/util';
import { createLogger } from '@cardano-sdk/util-dev';
import { filter, firstValueFrom, map, take } from 'rxjs';
import { firstValueFromTimed, walletReady } from '../../util';
import { getEnv, getWallet, walletVariables } from '../../../src';

const env = getEnv(walletVariables);
const logger = createLogger();

describe('SingleAddressWallet/unspendableUtxos', () => {
  let wallet1: SingleAddressWallet;
  let wallet2: SingleAddressWallet;

  afterAll(() => {
    wallet1.shutdown();
    wallet2.shutdown();
  });

  // eslint-disable-next-line max-statements
  it('unsets unspendable UTxOs when no longer in the wallets UTxO set', async () => {
    // Here we will simulate the scenario of collateral consumption by spending it from another wallet instance.
    wallet1 = (await getWallet({ env, logger, name: 'Wallet 1', polling: { interval: 50 } })).wallet;
    wallet2 = (await getWallet({ env, logger, name: 'Wallet 2', polling: { interval: 50 } })).wallet;

    const coins = 5_000_000n;
    await walletReady(wallet1, coins);
    await walletReady(wallet2, coins);

    const txBuilder1 = buildTx({ logger: contextLogger(logger, 'txBuilder1'), observableWallet: wallet1 });
    const txBuilder2 = buildTx({ logger: contextLogger(logger, 'txBuilder2'), observableWallet: wallet2 });

    const address = (await firstValueFrom(wallet1.addresses$))[0].address;

    // Create a new UTxO to be use as collateral.
    const txOutput = txBuilder1.buildOutput().address(address).coin(5_000_000n).toTxOut();

    const unsignedTx = await txBuilder1.addOutput(txOutput).build();

    assertTxIsValid(unsignedTx);

    const signedTx = await unsignedTx.sign();
    await signedTx.submit();

    // Search chain history to see if the transaction is there.
    let txFoundInHistory = await firstValueFromTimed(
      wallet1.transactions.history$.pipe(
        map((txs) => txs.find((tx) => tx.id === signedTx.tx.id)),
        filter(isNotNil),
        take(1)
      ),
      `Failed to find transaction ${signedTx.tx.id} in src wallet history`
    );

    // Find the UTxO in the UTxO set.
    const utxo = await firstValueFromTimed(
      wallet1.utxo.available$.pipe(
        map((utxos) => utxos.find((o) => o[0].txId === signedTx.tx.id && o[1].value.coins === 5_000_000n)),
        filter(isNotNil),
        take(1)
      ),
      `Failed to find utxo from txId ${signedTx.tx.id} with coin value 5_000_000n in src wallet`
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
        map((txs) => txs.find((tx) => tx.id === signedTx.tx.id)),
        filter(isNotNil),
        take(1)
      ),
      `Failed to find transaction ${signedTx.tx.id} in dest wallet history`
    );

    const unsignedMoveAdaTx = await txBuilder2
      .addOutput(txBuilder2.buildOutput().address(address).value(totalBalance).toTxOut())
      .build();

    assertTxIsValid(unsignedMoveAdaTx);

    const signedMoveAdaTx = await unsignedMoveAdaTx.sign();
    await signedMoveAdaTx.submit();

    // Search chain history to see if the transaction is there.
    txFoundInHistory = await firstValueFromTimed(
      wallet1.transactions.history$.pipe(
        map((txs) => txs.find((tx) => tx.id === signedMoveAdaTx.tx.id)),
        filter(isNotNil),
        take(1)
      ),
      `Failed to find second transaction ${signedMoveAdaTx.tx.id} in dest wallet history`
    );

    expect(txFoundInHistory.id).toEqual(signedMoveAdaTx.tx.id);

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
