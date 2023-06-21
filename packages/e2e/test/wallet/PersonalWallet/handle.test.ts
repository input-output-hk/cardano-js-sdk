/* eslint-disable sonarjs/no-duplicate-string */
import { Cardano, metadatum, nativeScriptPolicyId } from '@cardano-sdk/core';
import { FinalizeTxProps, PersonalWallet } from '@cardano-sdk/wallet';
import { InitializeTxProps } from '@cardano-sdk/tx-construction';
import { KeyRole, TransactionSigner, util } from '@cardano-sdk/key-management';
import { Metadatum, TokenMap } from '@cardano-sdk/core/dist/cjs/Cardano';
import {
  burnTokens,
  createStandaloneKeyAgent,
  getEnv,
  getWallet,
  submitAndConfirm,
  txConfirmed,
  walletReady,
  walletVariables
} from '../../../src';
import { createLogger } from '@cardano-sdk/util-dev';
import { firstValueFrom } from 'rxjs';

const env = getEnv(walletVariables);
const logger = createLogger();

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
      name: '$handle1',
      website: 'https://cardano.org/'
    };
  }
  return { [handlePolicyId]: result };
};

describe('Ada handle', () => {
  let wallet: PersonalWallet;
  let receivingWallet: PersonalWallet;
  let policySigner: TransactionSigner;
  let policyId: Cardano.PolicyId;
  let policyScript: Cardano.NativeScript;
  let assetIds: Cardano.AssetId[];

  const assetNames = ['68616e646c6531', '68616e646c6532'];
  let walletAddress: Cardano.PaymentAddress;
  const coins = 2_000_000n; // number of coins to use in each transaction

  const initPolicyId = async () => {
    wallet = (await getWallet({ env, idx: 0, logger, name: 'Handle Init Wallet', polling: { interval: 50 } })).wallet;
    await walletReady(wallet, coins);
    const derivationPath = {
      index: 2,
      role: KeyRole.External
    };
    const keyAgent = await createStandaloneKeyAgent(
      env.KEY_MANAGEMENT_PARAMS.mnemonic.split(' '),
      await firstValueFrom(wallet.genesisParameters$),
      await wallet.keyAgent.getBip32Ed25519()
    );
    const pubKey = await keyAgent.derivePublicKey(derivationPath);
    const keyHash = await keyAgent.bip32Ed25519.getPubKeyHash(pubKey);
    policySigner = new util.KeyAgentTransactionSigner(keyAgent, derivationPath);
    policyScript = {
      __type: Cardano.ScriptType.Native,
      kind: Cardano.NativeScriptKind.RequireAllOf,
      scripts: [
        {
          __type: Cardano.ScriptType.Native,
          keyHash,
          kind: Cardano.NativeScriptKind.RequireSignature
        }
      ]
    };
    policyId = nativeScriptPolicyId(policyScript);
    wallet.shutdown();
  };

  const mint = async (tokens: Cardano.TokenMap, txMetadatum: Cardano.Metadatum) => {
    const auxiliaryData = {
      blob: new Map([[721n, txMetadatum]])
    };

    const txProps: InitializeTxProps = {
      auxiliaryData,
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
      witness: { extraSigners: [policySigner], scripts: [policyScript] }
    };

    const unsignedTx = await wallet.initializeTx(txProps);

    const finalizeProps: FinalizeTxProps = {
      auxiliaryData,
      tx: unsignedTx,
      witness: { extraSigners: [policySigner], scripts: [policyScript] }
    };

    const signedTx = await wallet.finalizeTx(finalizeProps);
    await submitAndConfirm(wallet, signedTx);
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
    assetIds = [Cardano.AssetId(`${policyId}${assetNames[0]}`), Cardano.AssetId(`${policyId}${assetNames[1]}`)];
    walletAddress = (await firstValueFrom(wallet.addresses$))[0].address;
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

  it("PersonalWallet discovers it's own handles", async () => {
    const tokens = new Map([
      [assetIds[0], 1n],
      [assetIds[1], 1n]
    ]);
    const txMetadatum = metadatum.jsonToMetadatum(createHandleMetadata(policyId, ['handle1', 'handle2']));
    await mint(tokens, txMetadatum);
    let utxo = await firstValueFrom(wallet.balance.utxo.available$);
    let receivingUtxo = await firstValueFrom(receivingWallet.balance.utxo.available$);
    expect(utxo.assets?.size).toEqual(2);
    expect(receivingUtxo.assets).toBeUndefined();
    let handles = await firstValueFrom(wallet.handles$);
    let receivingHandles = await firstValueFrom(receivingWallet.handles$);
    expect(handles.length).toEqual(2);
    expect(receivingHandles.length).toEqual(0);

    const token = new Map([[assetIds[0], 1n]]);
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
    expect(utxo.assets?.size).toEqual(1);
    expect(receivingUtxo.assets?.size).toEqual(1);
    expect(receivingUtxo.assets?.keys().next().value).toEqual(assetIds[0]);
    handles = await firstValueFrom(wallet.handles$);
    receivingHandles = await firstValueFrom(receivingWallet.handles$);
    expect(handles.length).toEqual(1);
    expect(receivingHandles.length).toEqual(1);
  });

  describe('double mint handling', () => {
    it('filters out double mints in separate transactions', async () => {
      const tokens: TokenMap = new Map([[assetIds[0], 1n]]);
      const txMetadatum: Metadatum = metadatum.jsonToMetadatum(createHandleMetadata(policyId, ['handle1']));
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
      const txMetadatum: Metadatum = metadatum.jsonToMetadatum(createHandleMetadata(policyId, ['handle1']));
      await mint(tokens, txMetadatum);
      await restartWallet();
      const utxo = await firstValueFrom(wallet.balance.utxo.available$);
      expect(utxo.assets?.values().next().value).toEqual(2n);
      const handles = await firstValueFrom(wallet.handles$);
      expect(handles).toEqual([]);
    });

    it('shows handle after corrective burn', async () => {
      const tokens = new Map([[assetIds[0], 2n]]);
      const txMetadatum: Metadatum = metadatum.jsonToMetadatum(createHandleMetadata(policyId, ['handle1']));
      await mint(tokens, txMetadatum);
      let utxo = await firstValueFrom(wallet.balance.utxo.available$);
      expect(utxo.assets?.values().next().value).toEqual(2n);
      await burnTokens({
        policySigners: [policySigner],
        scripts: [policyScript],
        tokens: new Map([[assetIds[0], 1n]]),
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
