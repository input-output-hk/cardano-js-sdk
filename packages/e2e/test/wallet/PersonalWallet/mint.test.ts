import { BaseWallet } from '@cardano-sdk/wallet';
import { Cardano } from '@cardano-sdk/core';
import { burnTokens, getEnv, getWallet, submitAndConfirm, walletReady, walletVariables } from '../../../src';
import { createLogger } from '@cardano-sdk/util-dev';
import { filter, firstValueFrom, map, take } from 'rxjs';
import { isNotNil } from '@cardano-sdk/util';

const env = getEnv(walletVariables);
const logger = createLogger();

describe('PersonalWallet/mint', () => {
  let wallet: BaseWallet;
  let scripts: Cardano.NativeScript[];

  afterAll(() => {
    wallet.shutdown();
  });

  afterEach(async () => {
    await burnTokens({ scripts, wallet });
  });

  it('can mint a token with no asset name', async () => {
    wallet = (await getWallet({ env, logger, name: 'Minting Wallet', polling: { interval: 50 } })).wallet;

    const coins = 3_000_000n;
    await walletReady(wallet, coins);
    const txBuilder = wallet.createTxBuilder();
    const policy = txBuilder.buildPolicy();
    scripts = [await policy.getPolicyScript()];
    const policyId = await policy.getPolicyId();
    const assetId = Cardano.AssetId(`${policyId}`); // skip asset name
    const tokens = new Map([[assetId, 1n]]);
    const walletAddress = (await firstValueFrom(wallet.addresses$))[0].address;
    const { tx: signedTx } = await txBuilder
      .addMint(tokens)
      .addNativeScripts(scripts)
      .addOutput(await txBuilder.buildOutput().address(walletAddress).coin(coins).assets(tokens).build())
      .build()
      .sign();

    await submitAndConfirm(wallet, signedTx);

    // Search chain history to see if the transaction is there.
    const txFoundInHistory = await firstValueFrom(
      wallet.transactions.history$.pipe(
        map((txs) => txs.find((tx) => tx.id === signedTx.id)),
        filter(isNotNil),
        take(1)
      )
    );

    expect(txFoundInHistory.id).toEqual(signedTx.id);

    // Wait until wallet is aware of the minted token.
    const value = await firstValueFrom(
      wallet.balance.utxo.total$.pipe(filter(({ assets }) => (assets ? assets.has(assetId) : false)))
    );

    expect(value).toBeDefined();
    expect(value!.assets!.has(assetId)).toBeTruthy();
    expect(value!.assets!.get(assetId)).toBe(1n);
    expect(txFoundInHistory.inputSource).toBe(Cardano.InputSource.inputs);

    await burnTokens({ scripts, wallet });
  });
});
