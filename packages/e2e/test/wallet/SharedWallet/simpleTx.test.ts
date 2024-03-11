import { BaseWallet } from '@cardano-sdk/wallet';
import { Cardano } from '@cardano-sdk/core';
import { buildSharedWallets } from './ultils';
import { filter, firstValueFrom, map, take } from 'rxjs';
import {
  getEnv,
  getWallet,
  normalizeTxBody,
  waitForWalletStateSettle,
  walletReady,
  walletVariables
} from '../../../src';
import { isNotNil } from '@cardano-sdk/util';
import { logger } from '@cardano-sdk/util-dev';

const env = getEnv(walletVariables);

describe('SharedWallet/simpleTx', () => {
  let fundingTx: Cardano.Tx<Cardano.TxBody>;
  let faucetWallet: BaseWallet;
  let faucetAddress: Cardano.PaymentAddress;
  let aliceMultiSigWallet: BaseWallet;
  let bobMultiSigWallet: BaseWallet;
  let charlotteMultiSigWallet: BaseWallet;
  const initialFunds = 10_000_000n;

  beforeAll(async () => {
    ({ wallet: faucetWallet } = await getWallet({ env, logger, name: 'Sending Wallet', polling: { interval: 50 } }));

    // Make sure the wallet has sufficient funds to run this test
    await walletReady(faucetWallet, initialFunds);

    faucetAddress = (await firstValueFrom(faucetWallet.addresses$))[0].address;

    ({ aliceMultiSigWallet, bobMultiSigWallet, charlotteMultiSigWallet } = await buildSharedWallets(
      env,
      await firstValueFrom(faucetWallet.genesisParameters$),
      logger
    ));

    await Promise.all([
      waitForWalletStateSettle(aliceMultiSigWallet),
      waitForWalletStateSettle(bobMultiSigWallet),
      waitForWalletStateSettle(charlotteMultiSigWallet)
    ]);

    const [{ address: receivingAddress }] = await firstValueFrom(aliceMultiSigWallet.addresses$);

    logger.info(`Address ${faucetAddress} will send ${initialFunds} lovelace to address ${receivingAddress}.`);

    // Send 10 tADA to the shared wallet.
    const txBuilder = faucetWallet.createTxBuilder();
    const txOutput = await txBuilder.buildOutput().address(receivingAddress).coin(initialFunds).build();
    fundingTx = (await txBuilder.addOutput(txOutput).build().sign()).tx;
    await faucetWallet.submitTx(fundingTx);

    logger.info(
      `Submitted transaction id: ${fundingTx.id}, inputs: ${JSON.stringify(
        fundingTx.body.inputs.map((txIn) => [txIn.txId, txIn.index])
      )} and outputs:${JSON.stringify(
        fundingTx.body.outputs.map((txOut) => [txOut.address, Number.parseInt(txOut.value.coins.toString())])
      )}.`
    );
  });

  afterAll(() => {
    aliceMultiSigWallet.shutdown();
    bobMultiSigWallet.shutdown();
    charlotteMultiSigWallet.shutdown();
    faucetWallet.shutdown();
  });

  it('submit a transaction and find it in chain history', async () => {
    const txFoundInHistory = await firstValueFrom(
      aliceMultiSigWallet.transactions.history$.pipe(
        map((txs) => txs.find((tx) => tx.id === fundingTx.id)),
        filter(isNotNil),
        take(1)
      )
    );

    logger.info(`Found transaction id in chain history: ${txFoundInHistory.id}`);

    expect(txFoundInHistory).toBeDefined();
    expect(txFoundInHistory.id).toEqual(fundingTx.id);
    expect(normalizeTxBody(txFoundInHistory.body)).toEqual(normalizeTxBody(fundingTx.body));

    const aliceAddress = (await firstValueFrom(aliceMultiSigWallet.addresses$))[0].address;
    const bobAddress = (await firstValueFrom(bobMultiSigWallet.addresses$))[0].address;
    const charlotteAddress = (await firstValueFrom(charlotteMultiSigWallet.addresses$))[0].address;

    expect(aliceAddress).toEqual(bobAddress);
    expect(aliceAddress).toEqual(charlotteAddress);

    // Lets send ada from the shared wallet to the faucet wallet

    // Alice will initiate the transaction.
    const txBuilder = aliceMultiSigWallet.createTxBuilder();
    const txOut = await txBuilder.buildOutput().address(faucetAddress).coin(1_000_000n).build();
    let tx = (await txBuilder.addOutput(txOut).build().sign()).tx;

    // Bob updates the transaction with his witness
    tx = await bobMultiSigWallet.updateWitness({ sender: { id: 'e2e' }, tx });

    // Charlotte updates the transaction with her witness
    tx = await charlotteMultiSigWallet.updateWitness({ sender: { id: 'e2e' }, tx });
    const txId = await charlotteMultiSigWallet.submitTx(tx);

    const finalTxFound = await firstValueFrom(
      aliceMultiSigWallet.transactions.history$.pipe(
        map((txs) => txs.find((hydratedTx) => hydratedTx.id === txId)),
        filter(isNotNil),
        take(1)
      )
    );

    logger.info(`Found transaction id in chain history: ${finalTxFound.id}`);

    expect(finalTxFound).toBeDefined();
    expect(finalTxFound.id).toEqual(tx.id);
    expect(normalizeTxBody(finalTxFound.body)).toEqual(normalizeTxBody(tx.body));
  });
});
