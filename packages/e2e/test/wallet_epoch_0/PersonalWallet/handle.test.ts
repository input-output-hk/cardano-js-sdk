/* eslint-disable sonarjs/no-duplicate-string */
import { Cardano, metadatum } from '@cardano-sdk/core';
import {
  bip32Ed25519Factory,
  burnTokens,
  coinsRequiredByHandleMint,
  createHandleMetadata,
  createHandlePolicy,
  createStandaloneKeyAgent,
  getEnv,
  getHandlePolicyId,
  getWallet,
  handleNames,
  mint,
  mintCIP25andCIP68Handles,
  txConfirmed,
  walletReady,
  walletVariables
} from '../../../src/index.js';
import { createLogger } from '@cardano-sdk/util-dev';
import { firstValueFrom } from 'rxjs';
import path from 'path';
import type { BaseWallet } from '@cardano-sdk/wallet';
import type { KeyAgent, TransactionSigner } from '@cardano-sdk/key-management';

const env = getEnv(walletVariables);
const logger = createLogger();

const toHex = (value: string) =>
  value
    .split('')
    .map((s) => s.charCodeAt(0).toString(16))
    .join('');

describe('Ada handle', () => {
  let wallet: BaseWallet;
  let keyAgent: KeyAgent;
  let receivingWallet: BaseWallet;
  let policySigner: TransactionSigner;
  let policyId: Cardano.PolicyId;
  let policyScript: Cardano.NativeScript;
  let cip25AssetIds: Cardano.AssetId[];

  const coins = coinsRequiredByHandleMint + 10_000_000n; // maximum number of coins to use in each transaction

  const initPolicyId = async () => {
    wallet = (await getWallet({ env, idx: 0, logger, name: 'Handle Init Wallet' })).wallet;
    await walletReady(wallet, coins);

    keyAgent = await createStandaloneKeyAgent(
      env.KEY_MANAGEMENT_PARAMS.mnemonic.split(' '),
      await firstValueFrom(wallet.genesisParameters$),
      await bip32Ed25519Factory.create(env.KEY_MANAGEMENT_PARAMS.bip32Ed25519, null, logger)
    );
    ({ policyScript, policySigner, policyId } = await createHandlePolicy(keyAgent));
    const handleProviderPolicyId = await getHandlePolicyId(
      path.join(__dirname, '..', '..', '..', 'local-network', 'sdk-ipc')
    );
    expect(policyId).toEqual(handleProviderPolicyId);
    wallet.shutdown();
  };

  const restartWallet = async () => {
    wallet.shutdown();
    wallet = (
      await getWallet({
        env,
        handlePolicyIds: [policyId],
        idx: 0,
        logger,
        name: 'Minting Wallet',
        polling: { interval: 50 }
      })
    ).wallet;
    await walletReady(wallet, coins);
  };

  beforeAll(async () => {
    await initPolicyId();
    wallet = (
      await getWallet({
        env,
        handlePolicyIds: [policyId],
        idx: 0,
        logger,
        name: 'Minting Wallet',
        polling: { interval: 50 }
      })
    ).wallet;
    receivingWallet = (
      await getWallet({
        env,
        handlePolicyIds: [policyId],
        idx: 1,
        logger,
        name: 'Receiving Wallet',
        polling: { interval: 50 }
      })
    ).wallet;
    await Promise.all([walletReady(wallet, coins), walletReady(receivingWallet, 0n)]);
    cip25AssetIds = [
      Cardano.AssetId(`${policyId}${toHex(handleNames[0])}`),
      Cardano.AssetId(`${policyId}${toHex(handleNames[1])}`)
    ];
  });

  afterEach(async () => {
    await burnTokens({
      policySigners: [policySigner],
      scripts: [policyScript],
      wallet
    });
    await burnTokens({
      policySigners: [policySigner],
      scripts: [policyScript],
      wallet: receivingWallet
    });
  });

  afterAll(async () => {
    wallet.shutdown();
    receivingWallet.shutdown();
  });

  // eslint-disable-next-line max-statements
  it("BaseWallet discovers it's own cip25 and cip68 handles", async () => {
    await mintCIP25andCIP68Handles(wallet, keyAgent, policyId);
    let utxo = await firstValueFrom(wallet.balance.utxo.available$);
    let receivingUtxo = await firstValueFrom(receivingWallet.balance.utxo.available$);
    expect(utxo.assets?.size).toEqual(6);
    expect(receivingUtxo.assets).toBeUndefined();
    let handles = await firstValueFrom(wallet.handles$);
    let receivingHandles = await firstValueFrom(receivingWallet.handles$);
    expect(handles.length).toEqual(4);
    expect(receivingHandles.length).toEqual(0);

    // send handle to another wallet
    const token = new Map([[cip25AssetIds[0], 1n]]);
    const destAddresses = (await firstValueFrom(receivingWallet.addresses$))[0].address;
    const txBuilder = wallet.createTxBuilder();
    const { tx } = await txBuilder
      .addOutput(await txBuilder.buildOutput().address(destAddresses).coin(coins).assets(token).build())
      .build()
      .sign();
    await wallet.submitTx(tx);
    await txConfirmed(receivingWallet, tx);

    utxo = await firstValueFrom(wallet.balance.utxo.available$);
    receivingUtxo = await firstValueFrom(receivingWallet.balance.utxo.available$);
    expect(utxo.assets?.size).toEqual(5);
    expect(receivingUtxo.assets?.size).toEqual(1);
    expect(receivingUtxo.assets?.keys().next().value).toEqual(cip25AssetIds[0]);
    handles = await firstValueFrom(wallet.handles$);
    receivingHandles = await firstValueFrom(receivingWallet.handles$);
    expect(handles.length).toEqual(3);
    expect(receivingHandles.length).toEqual(1);

    // send ada using handle
    const txBuilder2 = wallet.createTxBuilder();
    const { tx: tx2 } = await txBuilder2
      .addOutput(await txBuilder2.buildOutput().handle(receivingHandles[0].handle).coin(coins).build())
      .build()
      .sign();
    await wallet.submitTx(tx2);
    await txConfirmed(receivingWallet, tx2);
    const receivingUtxoAfter = await firstValueFrom(receivingWallet.balance.utxo.available$);
    expect(receivingUtxoAfter.coins).toEqual(receivingUtxo.coins + coins);
  });

  describe('double mint handling', () => {
    it('filters out double mints in separate transactions', async () => {
      const tokens: Cardano.TokenMap = new Map([[cip25AssetIds[0], 1n]]);
      const txMetadatum: Cardano.Metadatum = metadatum.jsonToMetadatum(
        createHandleMetadata(policyId, [handleNames[0]])
      );
      await mint(wallet, keyAgent, tokens, txMetadatum);
      let handles = await firstValueFrom(wallet.handles$);
      expect(handles.length).toEqual(1);
      await mint(wallet, keyAgent, tokens, txMetadatum);
      await restartWallet();
      const utxo = await firstValueFrom(wallet.balance.utxo.available$);
      expect(utxo.assets?.values().next().value).toEqual(2n);
      handles = await firstValueFrom(wallet.handles$);
      expect(handles).toEqual([]);
    });

    it('filters out double mints from within the same transaction', async () => {
      const tokens = new Map([[cip25AssetIds[0], 2n]]);
      const txMetadatum: Cardano.Metadatum = metadatum.jsonToMetadatum(
        createHandleMetadata(policyId, [handleNames[0]])
      );
      await mint(wallet, keyAgent, tokens, txMetadatum);
      await restartWallet();
      const utxo = await firstValueFrom(wallet.balance.utxo.available$);
      expect(utxo.assets?.values().next().value).toEqual(2n);
      const handles = await firstValueFrom(wallet.handles$);
      expect(handles).toEqual([]);
    });

    it('shows handle after corrective burn', async () => {
      const tokens = new Map([[cip25AssetIds[0], 2n]]);
      const txMetadatum: Cardano.Metadatum = metadatum.jsonToMetadatum(
        createHandleMetadata(policyId, [handleNames[0]])
      );
      await mint(wallet, keyAgent, tokens, txMetadatum);
      let utxo = await firstValueFrom(wallet.balance.utxo.available$);
      expect(utxo.assets?.values().next().value).toEqual(2n);
      await burnTokens({
        policySigners: [policySigner],
        scripts: [policyScript],
        tokens: new Map([[cip25AssetIds[0], 1n]]),
        wallet
      });
      await restartWallet();
      utxo = await firstValueFrom(wallet.balance.utxo.available$);
      expect(utxo.assets?.values().next().value).toEqual(1n);
      const correctedHandles = await firstValueFrom(wallet.handles$);
      expect(correctedHandles.length).toEqual(1);
    });
  });
});
