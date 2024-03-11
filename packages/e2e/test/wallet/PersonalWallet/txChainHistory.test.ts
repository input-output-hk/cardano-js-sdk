import { BaseWallet } from '@cardano-sdk/wallet';
import { Cardano, CardanoNodeUtil, ProviderError } from '@cardano-sdk/core';
import { filter, firstValueFrom, map, take } from 'rxjs';
import { getEnv, getWallet, normalizeTxBody, walletReady, walletVariables } from '../../../src';
import { isNotNil } from '@cardano-sdk/util';
import { logger } from '@cardano-sdk/util-dev';

const env = getEnv(walletVariables);

describe('PersonalWallet/txChainHistory', () => {
  let wallet: BaseWallet;
  let signedTx: Cardano.Tx<Cardano.TxBody>;

  beforeEach(async () => {
    ({ wallet } = await getWallet({ env, logger, name: 'Sending Wallet', polling: { interval: 50 } }));
    const tAdaToSend = 10_000_000n;
    // Make sure the wallet has sufficient funds to run this test
    await walletReady(wallet, tAdaToSend);

    await firstValueFrom(wallet.syncStatus.isSettled$.pipe(filter((isSettled) => isSettled)));

    const [{ address: sendingAddress }] = await firstValueFrom(wallet.addresses$);
    const receivingAddress = sendingAddress;

    logger.info(`Address ${sendingAddress} will send ${tAdaToSend} lovelace to address ${receivingAddress}.`);

    // Send 10 tADA to the same wallet.
    const txBuilder = wallet.createTxBuilder();
    const txOutput = await txBuilder.buildOutput().address(receivingAddress).coin(tAdaToSend).build();
    signedTx = (await txBuilder.addOutput(txOutput).build().sign()).tx;
    await wallet.submitTx(signedTx);

    logger.info(
      `Submitted transaction id: ${signedTx.id}, inputs: ${JSON.stringify(
        signedTx.body.inputs.map((txIn) => [txIn.txId, txIn.index])
      )} and outputs:${JSON.stringify(
        signedTx.body.outputs.map((txOut) => [txOut.address, Number.parseInt(txOut.value.coins.toString())])
      )}.`
    );
  });

  afterEach(() => {
    wallet.shutdown();
  });

  it('submit a transaction and find it in chain history', async () => {
    // Search chain history to see if the transaction is there.
    const txFoundInHistory = await firstValueFrom(
      wallet.transactions.history$.pipe(
        map((txs) => txs.find((tx) => tx.id === signedTx.id)),
        filter(isNotNil),
        take(1)
      )
    );

    logger.info(`Found transaction id in chain history: ${txFoundInHistory.id}`);

    // Assert
    expect(txFoundInHistory).toBeDefined();
    expect(txFoundInHistory.id).toEqual(signedTx.id);
    expect(normalizeTxBody(txFoundInHistory.body)).toEqual(normalizeTxBody(signedTx.body));
  });

  // TODO LW-9972
  it.skip('can detect a ValueNotConserved error', async () => {
    expect.assertions(1);
    // Search chain history to see if the transaction is there.
    await firstValueFrom(
      wallet.transactions.history$.pipe(
        map((txs) => txs.find((tx) => tx.id === signedTx.id)),
        filter(isNotNil),
        take(1)
      )
    );

    try {
      // Submit the same transaction again.
      await wallet.submitTx(signedTx);
    } catch (error) {
      if (error instanceof ProviderError) {
        expect(CardanoNodeUtil.isValueNotConservedError(error?.innerError)).toBeTruthy();
      }
    }
  });
});
