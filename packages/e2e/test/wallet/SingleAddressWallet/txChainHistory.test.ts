/* eslint-disable max-len */
import { SingleAddressWallet, buildTx } from '@cardano-sdk/wallet';
import { assertTxIsValid } from '../../../../wallet/test/util';
import { env } from '../environment';
import { filter, firstValueFrom, map, take } from 'rxjs';
import { getWallet } from '../../../src';
import { isNotNil } from '@cardano-sdk/util';
import { logger } from '@cardano-sdk/util-dev';
import { normalizeTxBody } from '../util';

describe('tx chain history', () => {
  let wallet: SingleAddressWallet;

  beforeEach(async () => {
    ({ wallet } = await getWallet({ env, logger, name: 'Sending Wallet', polling: { interval: 50 } }));
  });

  afterEach(() => {
    wallet.shutdown();
  });

  it('submit a transaction and find it in chain history', async () => {
    const tAdaToSend = 10_000_000n;

    await firstValueFrom(wallet.syncStatus.isSettled$.pipe(filter((isSettled) => isSettled)));

    const [{ address: sendingAddress }] = await firstValueFrom(wallet.addresses$);
    const receivingAddress = sendingAddress;

    logger.info(
      `Address ${sendingAddress.toString()} will send ${tAdaToSend} lovelace to address ${receivingAddress.toString()}.`
    );

    // Send 10 tADA to the same wallet.
    const txBuilder = buildTx({ logger, observableWallet: wallet });
    const txOutput = txBuilder.buildOutput().address(receivingAddress).coin(tAdaToSend).toTxOut();
    const unsignedTx = await txBuilder.addOutput(txOutput).build();

    assertTxIsValid(unsignedTx);

    const signedTx = await unsignedTx.sign();
    await signedTx.submit();

    logger.info(
      `Submitted transaction id: ${signedTx.tx.id}, inputs: ${signedTx.tx.body.inputs} and outputs:${signedTx.tx.body.outputs}.`
    );

    // Search chain history to see if the transaction is there.
    const txFoundInHistory = await firstValueFrom(
      wallet.transactions.history$.pipe(
        map((txs) => txs.find((tx) => tx.id === signedTx.tx.id)),
        filter(isNotNil),
        take(1)
      )
    );

    logger.info(
      `Found transaction id in chain history: ${txFoundInHistory.id}, inputs: ${txFoundInHistory.body.inputs} and outputs:${txFoundInHistory.body.outputs}.`
    );

    // Assert
    expect(txFoundInHistory).toBeDefined();
    expect(txFoundInHistory.id).toEqual(signedTx.tx.id);
    expect(normalizeTxBody(signedTx.tx.body)).toEqual(txFoundInHistory.body);
  });
});
