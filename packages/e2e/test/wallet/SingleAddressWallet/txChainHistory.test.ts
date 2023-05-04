import { SingleAddressWallet } from '@cardano-sdk/wallet';
import { filter, firstValueFrom, map, take } from 'rxjs';
import { getEnv, getWallet, walletVariables } from '../../../src';
import { isNotNil } from '@cardano-sdk/util';
import { logger } from '@cardano-sdk/util-dev';
import { normalizeTxBody, walletReady } from '../../util';

const env = getEnv(walletVariables);

describe('SingleAddressWallet/txChainHistory', () => {
  let wallet: SingleAddressWallet;

  beforeEach(async () => {
    ({ wallet } = await getWallet({ env, logger, name: 'Sending Wallet', polling: { interval: 50 } }));
  });

  afterEach(() => {
    wallet.shutdown();
  });

  it('submit a transaction and find it in chain history', async () => {
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
    const { tx: signedTx } = await txBuilder.addOutput(txOutput).build().sign();
    await wallet.submitTx(signedTx);

    logger.info(
      `Submitted transaction id: ${signedTx.id}, inputs: ${JSON.stringify(
        signedTx.body.inputs.map((txIn) => [txIn.txId, txIn.index])
      )} and outputs:${JSON.stringify(
        signedTx.body.outputs.map((txOut) => [txOut.address, Number.parseInt(txOut.value.coins.toString())])
      )}.`
    );

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
});
