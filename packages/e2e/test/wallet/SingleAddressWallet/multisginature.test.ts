/* eslint-disable sonarjs/no-duplicate-string */
import { Cardano } from '@cardano-sdk/core';
import { KeyManagement, SingleAddressWallet } from '@cardano-sdk/wallet';
import { env } from '../environment';
import { filter, firstValueFrom } from 'rxjs';
import { getLogger, getWallet } from '../../../src/factories';

const logger = getLogger(env.LOGGER_MIN_SEVERITY);

/**
 * Gets a key agent from a random set of mnemonics and the network id.
 *
 * @param mnemonics The random set of mnemonics.
 * @param networkId the network id.
 */
const getKeyAgent = async (mnemonics: string[], networkId: Cardano.NetworkId) =>
  await KeyManagement.InMemoryKeyAgent.fromBip39MnemonicWords(
    {
      getPassword: async () => Buffer.from(''),
      mnemonicWords: mnemonics,
      networkId
    },
    { inputResolver: { resolveInputAddress: async () => null } }
  );

describe('SingleAddressWallet/multisignature', () => {
  let wallet: SingleAddressWallet;
  const assetName = '3030303030';

  afterAll(() => {
    wallet.shutdown();
  });

  it('can create a transaction with multiple signatures to mint an asset', async () => {
    wallet = (await getWallet({ env, idx: 0, logger, name: 'Minting Wallet', polling: { interval: 50 } })).wallet;

    await firstValueFrom(wallet.syncStatus.isSettled$.pipe(filter((isSettled) => isSettled)));

    const params = await firstValueFrom(wallet.genesisParameters$);

    const aliceKeyAgent = await getKeyAgent(KeyManagement.util.generateMnemonicWords(), params.networkId);
    const bobKeyAgent = await getKeyAgent(KeyManagement.util.generateMnemonicWords(), params.networkId);

    const derivationPath = {
      index: 0,
      role: KeyManagement.KeyRole.External
    };

    const alicePubKey = await aliceKeyAgent.derivePublicKey(derivationPath);
    const aliceKeyHash = Cardano.Ed25519KeyHash.fromKey(alicePubKey);

    const bobPubKey = await bobKeyAgent.derivePublicKey(derivationPath);
    const bobKeyHash = Cardano.Ed25519KeyHash.fromKey(bobPubKey);

    const alicePolicySigner = new KeyManagement.util.KeyAgentTransactionSigner(aliceKeyAgent, derivationPath);
    const bobPolicySigner = new KeyManagement.util.KeyAgentTransactionSigner(bobKeyAgent, derivationPath);

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

    const policyId = Cardano.util.nativeScriptPolicyId(policyScript);
    const assetId = Cardano.AssetId(`${policyId}${assetName}`);
    const tokens = new Map([[assetId, 10n]]);

    const walletAddress = (await firstValueFrom(wallet.addresses$))[0].address;

    const txProps = {
      extraSigners: [alicePolicySigner, bobPolicySigner],
      mint: tokens,
      outputs: new Set([
        {
          address: walletAddress,
          value: {
            assets: tokens,
            coins: 3_000_000n
          }
        }
      ]),
      scripts: [policyScript]
    };

    const unsignedTx = await wallet.initializeTx(txProps);

    const finalizeProps = {
      extraSigners: [alicePolicySigner, bobPolicySigner],
      scripts: [policyScript],
      tx: unsignedTx
    };

    const signedTx = await wallet.finalizeTx(finalizeProps);
    await wallet.submitTx(signedTx);

    // Wait until wallet is aware of the minted token.
    const value = await firstValueFrom(
      wallet.balance.utxo.total$.pipe(filter(({ assets }) => (assets ? assets.has(assetId) : false)))
    );

    expect(value).toBeDefined();
    expect(value!.assets!.has(assetId)).toBeTruthy();
    expect(value!.assets!.get(assetId)).toBe(10n);
  });
});
