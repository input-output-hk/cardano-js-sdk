/* eslint-disable sonarjs/no-duplicate-string */
import { AsyncKeyAgent, TransactionSigner, util } from '@cardano-sdk/key-management';
import { BaseWallet } from '@cardano-sdk/wallet';
import { Cardano } from '@cardano-sdk/core';
import { GenericTxBuilder } from '@cardano-sdk/tx-construction';
import { PolicyBuilder } from '@cardano-sdk/tx-construction/dist/cjs/tx-builder/PolicyBuilder';
import { burnTokens, getEnv, getWallet, txConfirmed, walletReady, walletVariables } from '../../../src';
import { createLogger } from '@cardano-sdk/util-dev';
import { filter, firstValueFrom } from 'rxjs';

const env = getEnv(walletVariables);
const logger = createLogger();

describe('PersonalWallet/multisignature', () => {
  let aliceWallet: BaseWallet;
  let bobWallet: BaseWallet;
  let aliceTxBuilder: GenericTxBuilder;
  let bobTxBuilder: GenericTxBuilder;
  let alicePolicyBuilder: PolicyBuilder;
  let bobPolicyBuilder: PolicyBuilder;
  let bobKeyAgent: AsyncKeyAgent;
  const coins = 2_000_000n;
  let policyScript: Cardano.NativeScript;
  let bobSigner: TransactionSigner;

  beforeAll(async () => {
    aliceWallet = (
      await getWallet({
        env,
        idx: 0,
        logger,
        name: 'Alice Wallet',
        polling: { interval: 50 }
      })
    ).wallet;

    const getWalletRet = await getWallet({ env, idx: 1, logger, name: 'Bob Wallet', polling: { interval: 50 } });
    bobWallet = getWalletRet.wallet;
    bobKeyAgent = getWalletRet.asyncKeyAgent;
    await walletReady(aliceWallet, coins);
  });

  beforeEach(async () => {
    aliceTxBuilder = aliceWallet.createTxBuilder();
    alicePolicyBuilder = aliceTxBuilder.buildPolicy();
    bobTxBuilder = bobWallet.createTxBuilder();
    bobPolicyBuilder = bobTxBuilder.buildPolicy();
  });

  afterEach(async () => {
    await burnTokens({ policySigners: [bobSigner], scripts: [policyScript], wallet: aliceWallet });
  });

  afterAll(() => {
    aliceWallet.shutdown();
    bobWallet.shutdown();
  });

  it('can create a transaction with multiple signatures to mint an asset', async () => {
    policyScript = {
      __type: Cardano.ScriptType.Native,
      kind: Cardano.NativeScriptKind.RequireAllOf,
      scripts: [
        {
          __type: Cardano.ScriptType.Native,
          keyHash: await alicePolicyBuilder.getKeyHash(),
          kind: Cardano.NativeScriptKind.RequireSignature
        },
        {
          __type: Cardano.ScriptType.Native,
          keyHash: await bobPolicyBuilder.getKeyHash(),
          kind: Cardano.NativeScriptKind.RequireSignature
        }
      ]
    };
    bobSigner = new util.KeyAgentTransactionSigner(bobKeyAgent, bobPolicyBuilder.getDerivationPath());
    const policyId = await alicePolicyBuilder.setPolicyScript(policyScript).getPolicyId();
    const tokens = aliceTxBuilder.buildToken(policyId).addAsset('Multisig', 10n).build();
    const walletAddress = (await firstValueFrom(aliceWallet.addresses$))[0].address;

    const { tx: signedTx } = await aliceTxBuilder
      .addMint(tokens)
      .extraSigners([bobSigner])
      .addNativeScripts([policyScript])
      .addOutput(await aliceTxBuilder.buildOutput().address(walletAddress).coin(coins).assets(tokens).build())
      .build()
      .sign();
    await aliceWallet.submitTx(signedTx);
    await txConfirmed(aliceWallet, signedTx);

    // Wait until wallet is aware of the minted token.
    const assetId = tokens.keys().next().value;
    const value = await firstValueFrom(
      aliceWallet.balance.utxo.total$.pipe(filter(({ assets }) => (assets ? assets.has(assetId) : false)))
    );

    expect(value).toBeDefined();
    expect(value!.assets!.has(assetId)).toBeTruthy();
    expect(value!.assets!.get(assetId)).toBe(10n);
  });
});
