/* eslint-disable sonarjs/no-duplicate-string */
import { BaseWallet, FinalizeTxProps } from '@cardano-sdk/wallet';
import { Cardano, Serialization, nativeScriptPolicyId } from '@cardano-sdk/core';
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
  let wallet: BaseWallet;
  const assetName = '3030303030';
  let alicePolicySigner: util.KeyAgentTransactionSigner;
  let bobPolicySigner: util.KeyAgentTransactionSigner;
  let policyScript: Cardano.NativeScript;

  afterAll(async () => {
    await burnTokens({
      policySigners: [alicePolicySigner, bobPolicySigner],
      scripts: [policyScript],
      wallet
    });

    wallet.shutdown();
  });

  it('can create a transaction with multiple signatures to mint an asset', async () => {
    wallet = (await getWallet({ env, logger, name: 'Minting Wallet' })).wallet;

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

    alicePolicySigner = new util.KeyAgentTransactionSigner(aliceKeyAgent, aliceDerivationPath);
    bobPolicySigner = new util.KeyAgentTransactionSigner(bobKeyAgent, bobDerivationPath);

    policyScript = {
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
      signingOptions: {
        extraSigners: [alicePolicySigner, bobPolicySigner]
      },
      witness: { scripts: [policyScript] }
    };

    const unsignedTx = await wallet.initializeTx(txProps);

    const witness = { redeemers: unsignedTx.redeemers, scripts: [policyScript], signatures: new Map() };

    const finalizeProps: FinalizeTxProps = {
      signingOptions: {
        extraSigners: [alicePolicySigner, bobPolicySigner]
      },
      tx: new Serialization.Transaction(
        Serialization.TransactionBody.fromCore(unsignedTx.body),
        Serialization.TransactionWitnessSet.fromCore(witness)
      )
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
  });
});
