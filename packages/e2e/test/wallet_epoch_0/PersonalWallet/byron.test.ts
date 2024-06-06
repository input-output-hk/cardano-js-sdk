/* eslint-disable sonarjs/no-duplicate-string */
import { Cardano } from '@cardano-sdk/core';
import { createLogger } from '@cardano-sdk/util-dev';
import { filter, firstValueFrom, map, take } from 'rxjs';
import { getEnv, walletVariables } from '../../../src/environment.js';
import { getWallet, normalizeTxBody, walletReady } from '../../../src/index.js';
import { isNotNil } from '@cardano-sdk/util';
import type { BaseWallet } from '@cardano-sdk/wallet';

const env = getEnv(walletVariables);
const logger = createLogger();

describe('PersonalWallet/byron', () => {
  let wallet: BaseWallet;

  beforeAll(async () => {
    wallet = (await getWallet({ env, idx: 0, logger, name: 'Wallet' })).wallet;
  });

  afterAll(() => {
    wallet.shutdown();
  });

  it('can transfer tADA to a byron address', async () => {
    await walletReady(wallet);

    const txBuilder = wallet.createTxBuilder();

    const txOutput = await txBuilder
      .buildOutput()
      .address(Cardano.PaymentAddress('5oP9ib6ym3Xc2XrPGC6S7AaJeHYBCmLjt98bnjKR58xXDhSDgLHr8tht3apMDXf2Mg'))
      .coin(3_000_000n)
      .build();

    const { tx: signedTx } = await txBuilder.addOutput(txOutput).build().sign();
    await wallet.submitTx(signedTx);

    // Search chain history to see if the transaction is there.
    const txFoundInHistory = await firstValueFrom(
      wallet.transactions.history$.pipe(
        map((txs) => txs.find((tx) => tx.id === signedTx.id)),
        filter(isNotNil),
        take(1)
      )
    );

    // Assert
    expect(txFoundInHistory).toBeDefined();
    expect(txFoundInHistory.id).toEqual(signedTx.id);
    expect(normalizeTxBody(txFoundInHistory.body)).toEqual(normalizeTxBody(signedTx.body));
  });
});
