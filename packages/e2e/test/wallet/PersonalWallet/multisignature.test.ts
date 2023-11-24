/* eslint-disable sonarjs/no-duplicate-string */
import { Cardano, nativeScriptPolicyId } from '@cardano-sdk/core';
import { FinalizeTxProps, PersonalWallet } from '@cardano-sdk/wallet';
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
import { filter, firstValueFrom } from 'rxjs';

const env = getEnv(walletVariables);
const logger = createLogger();

describe('PersonalWallet/multisignature', () => {
  let wallet: PersonalWallet;
  const assetName = '3030303030';

  afterAll(() => {
    wallet.shutdown();
  });

  it('can create a transaction with multiple signatures to mint an asset', async () => {
    wallet = (await getWallet({ env, logger, name: 'Minting Wallet', polling: { interval: 50 } })).wallet;

    const coins = 3_000_000n;
    await walletReady(wallet, coins);

    const genesis = await firstValueFrom(wallet.genesisParameters$);

    const bip32Ed25519 = await bip32Ed25519Factory.create(env.KEY_MANAGEMENT_PARAMS.bip32Ed25519, null, logger);
    const aliceKeyAgent = await createStandaloneKeyAgent(
      env.KEY_MANAGEMENT_PARAMS.mnemonic.split(' '),
      genesis,
      bip32Ed25519
    );
    const bobKeyAgent = await createStandaloneKeyAgent(
      env.KEY_MANAGEMENT_PARAMS.mnemonic.split(' '),
      genesis,
      bip32Ed25519
    );

    const aliceDerivationPath = {
      index: 2,
      role: KeyRole.External
    };

    const bobDerivationPath = {
      index: 3,
      role: KeyRole.External
    };

    const alicePubKey = await aliceKeyAgent.derivePublicKey(aliceDerivationPath);
    const aliceKeyHash = await aliceKeyAgent.bip32Ed25519.getPubKeyHash(alicePubKey);

    const bobPubKey = await bobKeyAgent.derivePublicKey(bobDerivationPath);
    const bobKeyHash = await bobKeyAgent.bip32Ed25519.getPubKeyHash(bobPubKey);

    const alicePolicySigner = new util.KeyAgentTransactionSigner(aliceKeyAgent, aliceDerivationPath);
    const bobPolicySigner = new util.KeyAgentTransactionSigner(bobKeyAgent, bobDerivationPath);

    const policyScript: Cardano.NativeScript = {
      __type: Cardano.ScriptType.Native,
      kind: Cardano.NativeScriptKind.RequireAllOf,
      scripts: [
        {
          __type: Cardano.ScriptType.Native,
          keyHash: aliceKeyHash,
          kind: Cardano.NativeScriptKind.RequireSignature
        },
        {
          __type: Cardano.ScriptType.Native,
          keyHash: bobKeyHash,
          kind: Cardano.NativeScriptKind.RequireSignature
        }
      ]
    };

    const policyId = nativeScriptPolicyId(policyScript);
    const assetId = Cardano.AssetId(`${policyId}${assetName}`);
    const tokens = new Map([[assetId, 10n]]);

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
      witness: { extraSigners: [alicePolicySigner, bobPolicySigner], scripts: [policyScript] }
    };

    const unsignedTx = await wallet.initializeTx(txProps);

    const finalizeProps: FinalizeTxProps = {
      tx: unsignedTx,
      witness: { extraSigners: [alicePolicySigner, bobPolicySigner], scripts: [policyScript] }
    };

    const signedTx = await wallet.finalizeTx(finalizeProps);
    await submitAndConfirm(wallet, signedTx);

    // Wait until wallet is aware of the minted token.
    const value = await firstValueFrom(
      wallet.balance.utxo.total$.pipe(filter(({ assets }) => (assets ? assets.has(assetId) : false)))
    );

    expect(value).toBeDefined();
    expect(value!.assets!.has(assetId)).toBeTruthy();
    expect(value!.assets!.get(assetId)).toBe(10n);

    await burnTokens({
      policySigners: [alicePolicySigner, bobPolicySigner],
      scripts: [policyScript],
      wallet
    });
  });
});
