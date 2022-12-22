/* eslint-disable sonarjs/no-duplicate-string */
import { Cardano } from '@cardano-sdk/core';
import { SingleAddressWallet, buildTx } from '@cardano-sdk/wallet';
import { assertTxIsValid } from '../../../../wallet/test/util';
import { createLogger } from '@cardano-sdk/util-dev';
import { filter, firstValueFrom, map, take } from 'rxjs';
import { getEnv, walletVariables } from '../../../src/environment';
import { getWallet } from '../../../src';
import { isNotNil } from '@cardano-sdk/util';
import { normalizeTxBody, walletReady } from '../../util';

const env = getEnv(walletVariables);
const logger = createLogger();

describe('SingleAddressWallet/byron', () => {
  let wallet: SingleAddressWallet;

  beforeAll(async () => {
    wallet = (await getWallet({ env, idx: 0, logger, name: 'Wallet', polling: { interval: 50 } })).wallet;
  });

  afterAll(() => {
    wallet.shutdown();
  });

  it('can transfer tADA to a byron address', async () => {
    await walletReady(wallet);

    const txBuilder = buildTx({ logger, observableWallet: wallet });

    const txOutput = txBuilder
      .buildOutput()
      .address(Cardano.Address('5oP9ib6ym3Xc2XrPGC6S7AaJeHYBCmLjt98bnjKR58xXDhSDgLHr8tht3apMDXf2Mg'))
      .coin(3_000_000n)
      .toTxOut();

    const unsignedTx = await txBuilder.addOutput(txOutput).build();

    assertTxIsValid(unsignedTx);

    const signedTx = await unsignedTx.sign();
    await signedTx.submit();

    // Search chain history to see if the transaction is there.
    const txFoundInHistory = await firstValueFrom(
      wallet.transactions.history$.pipe(
        map((txs) => txs.find((tx) => tx.id === signedTx.tx.id)),
        filter(isNotNil),
        take(1)
      )
    );

    // Assert
    expect(txFoundInHistory).toBeDefined();
    expect(txFoundInHistory.id).toEqual(signedTx.tx.id);
    expect(normalizeTxBody(txFoundInHistory.body)).toEqual(normalizeTxBody(signedTx.tx.body));
  });
});
