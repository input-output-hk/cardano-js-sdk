import { BaseWallet, FinalizeTxProps } from '@cardano-sdk/wallet';
import { Cardano, nativeScriptPolicyId } from '@cardano-sdk/core';
import { InitializeTxProps } from '@cardano-sdk/tx-construction';
import { KeyRole, util } from '@cardano-sdk/key-management';
import {
  bip32Ed25519Factory,
  burnTokens,
  createStandaloneKeyAgent,
  getEnv,
  getWallet,
  submitAndConfirm,
  walletReady,
  walletVariables
} from '../../../src';
import { createLogger } from '@cardano-sdk/util-dev';
import { filter, firstValueFrom, map, take } from 'rxjs';
import { isNotNil } from '@cardano-sdk/util';

const env = getEnv(walletVariables);
const logger = createLogger();

describe('PersonalWallet/mint', () => {
  let wallet: BaseWallet;

  afterAll(() => {
    wallet.shutdown();
  });

  it('can mint a token with no asset name', async () => {
    wallet = (await getWallet({ env, logger, name: 'Minting Wallet' })).wallet;

    const coins = 3_000_000n;
    await walletReady(wallet, coins);

    const genesis = await firstValueFrom(wallet.genesisParameters$);

    const aliceKeyAgent = await createStandaloneKeyAgent(
      env.KEY_MANAGEMENT_PARAMS.mnemonic.split(' '),
      genesis,
      await bip32Ed25519Factory.create(env.KEY_MANAGEMENT_PARAMS.bip32Ed25519, null, logger)
    );

    const derivationPath = {
      index: 2,
      role: KeyRole.External
    };

    const alicePubKey = await aliceKeyAgent.derivePublicKey(derivationPath);
    const aliceKeyHash = await aliceKeyAgent.bip32Ed25519.getPubKeyHash(alicePubKey);

    const alicePolicySigner = new util.KeyAgentTransactionSigner(aliceKeyAgent, derivationPath);

    const policyScript: Cardano.NativeScript = {
      __type: Cardano.ScriptType.Native,
      kind: Cardano.NativeScriptKind.RequireAllOf,
      scripts: [
        {
          __type: Cardano.ScriptType.Native,
          keyHash: aliceKeyHash,
          kind: Cardano.NativeScriptKind.RequireSignature
        }
      ]
    };

    const policyId = nativeScriptPolicyId(policyScript);
    const assetId = Cardano.AssetId(`${policyId}`); // skip asset name
    const tokens = new Map([[assetId, 1n]]);

    const walletAddress = (await firstValueFrom(wallet.addresses$))[0].address;

    const txProps: InitializeTxProps = {
      mint: tokens,
      outputs: new Set([
        {
          address: walletAddress,
          value: {
            assets: tokens,
            coins
          }
        }
      ]),
      signingOptions: {
        extraSigners: [alicePolicySigner]
      },
      witness: { scripts: [policyScript] }
    };

    const unsignedTx = await wallet.initializeTx(txProps);

    const finalizeProps: FinalizeTxProps = {
      signingOptions: {
        extraSigners: [alicePolicySigner]
      },
      tx: unsignedTx,
      witness: { scripts: [policyScript] }
    };

    const signedTx = await wallet.finalizeTx(finalizeProps);
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

    await burnTokens({ policySigners: [alicePolicySigner], scripts: [policyScript], wallet });
  });
});
