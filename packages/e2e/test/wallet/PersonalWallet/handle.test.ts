/* eslint-disable sonarjs/no-duplicate-string */
import { Cardano, metadatum } from '@cardano-sdk/core';
import { Metadatum, TokenMap } from '@cardano-sdk/core/dist/cjs/Cardano';
import { PersonalWallet } from '@cardano-sdk/wallet';
import { TransactionSigner, util } from '@cardano-sdk/key-management';
import { burnTokens, getEnv, getWallet, txConfirmed, walletReady, walletVariables } from '../../../src';
import { createLogger } from '@cardano-sdk/util-dev';
import { firstValueFrom } from 'rxjs';
import { readFile } from 'fs/promises';
import path from 'path';

const env = getEnv(walletVariables);
const logger = createLogger();

const toHex = (value: string) =>
  value
    .split('')
    .map((s) => s.charCodeAt(0).toString(16))
    .join('');

type HandleMetadata = {
  [policyId: string]: {
    [handleName: string]: {
      augmentations: [];
      core: {
        handleEncoding: string;
        og: number;
        prefix: string;
        termsofuse: string;
        version: number;
      };
      description: string;
      image: string;
      name: string;
      website: string;
    };
  };
};

const createHandleMetadata = (handlePolicyId: string, handleNames: string[]): HandleMetadata => {
  const result: HandleMetadata[0] = {};
  for (const key of handleNames) {
    result[key] = {
      augmentations: [],
      core: {
        handleEncoding: 'utf-8',
        og: 0,
        prefix: '$',
        termsofuse: 'https://cardanofoundation.org/en/terms-and-conditions/',
        version: 0
      },
      description: 'The Handle Standard',
      image: 'ipfs://some-hash',
      name: `$${key}`,
      website: 'https://cardano.org/'
    };
  }
  return { [handlePolicyId]: result };
};

describe('Ada handle', () => {
  let wallet: PersonalWallet;
  let receivingWallet: PersonalWallet;
  let policyId: Cardano.PolicyId;
  let assetIds: Cardano.AssetId[];
  let scripts: Cardano.NativeScript[];
  let issuerSigner: TransactionSigner;

  const assetNames = ['handle1', 'handle2'];
  let walletAddress: Cardano.PaymentAddress;
  const coins = 2_000_000n; // number of coins to use in each transaction

  const initPolicyId = async () => {
    wallet = (await getWallet({ env, idx: 0, logger, name: 'Handle Init Wallet', polling: { interval: 50 } })).wallet;
    const txBuilder = wallet.createTxBuilder();
    const policy = await txBuilder.buildPolicy();
    policyId = await policy.getPolicyId();
    const sdkIpc = path.join(__dirname, '..', '..', '..', 'local-network', 'sdk-ipc');
    const handleProviderPolicyId = (await readFile(path.join(sdkIpc, 'handle_policy_ids')))
      .toString('utf8')
      .replace(/\s/g, '');
    expect(policyId).toEqual(handleProviderPolicyId);
    wallet.shutdown();
  };

  const mint = async (
    tokensOutput: Cardano.TokenMap,
    txMetadatum: Cardano.Metadatum,
    tokensMint: Cardano.TokenMap = tokensOutput
  ) => {
    const txBuilder = wallet.createTxBuilder();
    const policy = await txBuilder.buildPolicy();

    const auxiliaryData = new Map([[721n, txMetadatum]]);

    const { tx } = await txBuilder
      .addMint(tokensMint)
      .addNativeScripts([await policy.getPolicyScript()])
      .metadata(auxiliaryData)
      .addOutput(await txBuilder.buildOutput().address(walletAddress).coin(coins).assets(tokensOutput).build())
      .build()
      .sign();
    await wallet.submitTx(tx);
    await txConfirmed(wallet, tx);
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
    const txBuilder = wallet.createTxBuilder();
    const policy = await txBuilder.buildPolicy();
    scripts = [await policy.getPolicyScript()];
    issuerSigner = new util.KeyAgentTransactionSigner(await wallet.keyAgent, policy.getDerivationPath());
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
    assetIds = [
      Cardano.AssetId(`${policyId}${toHex(assetNames[0])}`),
      Cardano.AssetId(`${policyId}${toHex(assetNames[1])}`)
    ];
    walletAddress = (await firstValueFrom(wallet.addresses$))[0].address;
  });

  afterEach(async () => {
    await burnTokens({ scripts, wallet });
    await burnTokens({ policySigners: [issuerSigner], scripts, wallet: receivingWallet });
  });

  afterAll(async () => {
    wallet.shutdown();
    receivingWallet.shutdown();
  });

  // eslint-disable-next-line max-statements
  it("PersonalWallet discovers it's own handles", async () => {
    const tokens = new Map([
      [assetIds[0], 1n],
      [assetIds[1], 1n]
    ]);
    const txMetadatum = metadatum.jsonToMetadatum(createHandleMetadata(policyId, assetNames));
    await mint(tokens, txMetadatum);
    let utxo = await firstValueFrom(wallet.balance.utxo.available$);
    let receivingUtxo = await firstValueFrom(receivingWallet.balance.utxo.available$);
    expect(utxo.assets?.size).toEqual(2);
    expect(receivingUtxo.assets).toBeUndefined();
    let handles = await firstValueFrom(wallet.handles$);
    let receivingHandles = await firstValueFrom(receivingWallet.handles$);
    expect(handles.length).toEqual(2);
    expect(receivingHandles.length).toEqual(0);

    // send handle to another wallet
    const token = new Map([[assetIds[0], 1n]]);
    const destAddresses = (await firstValueFrom(receivingWallet.addresses$))[0].address;
    const txBuilder = wallet.createTxBuilder();
    const { tx } = await txBuilder
      .addOutput(await txBuilder.buildOutput().address(destAddresses).coin(coins).assets(token).build())
      .build()
      .sign();
    await wallet.submitTx(tx);
    await txConfirmed(wallet, tx);

    utxo = await firstValueFrom(wallet.balance.utxo.available$);
    receivingUtxo = await firstValueFrom(receivingWallet.balance.utxo.available$);
    expect(utxo.assets?.size).toEqual(1);
    expect(receivingUtxo.assets?.size).toEqual(1);
    expect(receivingUtxo.assets?.keys().next().value).toEqual(assetIds[0]);
    handles = await firstValueFrom(wallet.handles$);
    receivingHandles = await firstValueFrom(receivingWallet.handles$);
    expect(handles.length).toEqual(1);
    expect(receivingHandles.length).toEqual(1);

    // send ada using handle
    const txBuilder2 = wallet.createTxBuilder();
    const { tx: tx2 } = await txBuilder2
      .addOutput(await txBuilder2.buildOutput().handle(receivingHandles[0].handle).coin(coins).build())
      .build()
      .sign();
    await wallet.submitTx(tx2);
    await txConfirmed(wallet, tx2);
    const receivingUtxoAfter = await firstValueFrom(receivingWallet.balance.utxo.available$);
    expect(receivingUtxoAfter.coins).toEqual(receivingUtxo.coins + coins);
  });

  describe('double mint handling', () => {
    it('filters out double mints in separate transactions', async () => {
      const tokens: TokenMap = new Map([[assetIds[0], 1n]]);
      const txMetadatum: Metadatum = metadatum.jsonToMetadatum(createHandleMetadata(policyId, [assetNames[0]]));
      await mint(tokens, txMetadatum);
      let handles = await firstValueFrom(wallet.handles$);
      expect(handles.length).toEqual(1);
      await mint(tokens, txMetadatum);
      await restartWallet();
      const utxo = await firstValueFrom(wallet.balance.utxo.available$);
      expect(utxo.assets?.values().next().value).toEqual(2n);
      handles = await firstValueFrom(wallet.handles$);
      expect(handles).toEqual([]);
    });

    it('filters out double mints from within the same transaction', async () => {
      const tokens = new Map([[assetIds[0], 2n]]);
      const txMetadatum: Metadatum = metadatum.jsonToMetadatum(createHandleMetadata(policyId, [assetNames[0]]));
      await mint(tokens, txMetadatum);
      await restartWallet();
      const utxo = await firstValueFrom(wallet.balance.utxo.available$);
      expect(utxo.assets?.values().next().value).toEqual(2n);
      const handles = await firstValueFrom(wallet.handles$);
      expect(handles).toEqual([]);
    });

    it('shows handle after corrective burn', async () => {
      const tokens = new Map([[assetIds[0], 2n]]);
      const txMetadatum: Metadatum = metadatum.jsonToMetadatum(createHandleMetadata(policyId, [assetNames[0]]));
      await mint(tokens, txMetadatum);
      let utxo = await firstValueFrom(wallet.balance.utxo.available$);
      expect(utxo.assets?.values().next().value).toEqual(2n);
      const remainingToken = new Map([[assetIds[0], 1n]]);
      const burnedToken = new Map([[assetIds[0], -1n]]);
      await mint(remainingToken, txMetadatum, burnedToken);
      await restartWallet();
      utxo = await firstValueFrom(wallet.balance.utxo.available$);
      expect(utxo.assets?.values().next().value).toEqual(1n);
      const correctedHandles = await firstValueFrom(wallet.handles$);
      expect(correctedHandles.length).toEqual(1);
    });
  });
});
