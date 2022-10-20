/* eslint-disable sonarjs/no-duplicate-string */
import { Cardano, metadatum, nativeScriptPolicyId } from '@cardano-sdk/core';
import { InMemoryKeyAgent, KeyRole, TransactionSigner, util } from '@cardano-sdk/key-management';
import { SingleAddressWallet } from '@cardano-sdk/wallet';
import { combineLatest, filter, firstValueFrom, map } from 'rxjs';
import { env } from '../environment';
import { getLogger, getWallet } from '../../../src/factories';
import { submitAndConfirm, walletReady } from '../util';

const logger = getLogger(env.LOGGER_MIN_SEVERITY);

describe('SingleAddressWallet.assets/nft', () => {
  const TOKEN_METADATA_1_INDEX = 0;
  const TOKEN_METADATA_2_INDEX = 1;
  const TOKEN_BURN_INDEX = 2;

  let wallet: SingleAddressWallet;
  let policySigner: TransactionSigner;
  let policyId: Cardano.PolicyId;
  let policyScript: Cardano.NativeScript;
  let assetIds: Cardano.AssetId[];
  let fingerprints: Cardano.AssetFingerprint[];
  const assetNames = ['4e46542d66696c6573', '4e46542d303031', '4e46542d303032'];

  let walletAddress: Cardano.Address;

  beforeAll(async () => {
    wallet = (await getWallet({ env, idx: 0, logger, name: 'Minting Wallet', polling: { interval: 50 } })).wallet;

    await walletReady(wallet);

    const params = await firstValueFrom(wallet.genesisParameters$);

    const keyAgent = await InMemoryKeyAgent.fromBip39MnemonicWords(
      {
        getPassword: async () => Buffer.from(''),
        mnemonicWords: util.generateMnemonicWords(),
        networkId: params.networkId
      },
      { inputResolver: { resolveInputAddress: async () => null } }
    );

    const pubKey = await keyAgent.derivePublicKey({
      index: 0,
      role: KeyRole.External
    });

    const keyHash = Cardano.Ed25519KeyHash.fromKey(pubKey);

    policySigner = new util.KeyAgentTransactionSigner(keyAgent, {
      index: 0,
      role: KeyRole.External
    });

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

    assetIds = [
      Cardano.AssetId(`${policyId}${assetNames[TOKEN_METADATA_1_INDEX]}`),
      Cardano.AssetId(`${policyId}${assetNames[TOKEN_METADATA_2_INDEX]}`),
      Cardano.AssetId(`${policyId}${assetNames[TOKEN_BURN_INDEX]}`)
    ];

    const tokens = new Map([
      [assetIds[TOKEN_METADATA_1_INDEX], 1n],
      [assetIds[TOKEN_METADATA_2_INDEX], 1n],
      [assetIds[TOKEN_BURN_INDEX], 1n]
    ]);

    fingerprints = [
      Cardano.AssetFingerprint.fromParts(policyId, Cardano.AssetName(assetNames[TOKEN_METADATA_1_INDEX])),
      Cardano.AssetFingerprint.fromParts(policyId, Cardano.AssetName(assetNames[TOKEN_METADATA_2_INDEX])),
      Cardano.AssetFingerprint.fromParts(policyId, Cardano.AssetName(assetNames[TOKEN_BURN_INDEX]))
    ];

    walletAddress = (await firstValueFrom(wallet.addresses$))[0].address;

    const txMetadatum = metadatum.jsonToMetadatum({
      [policyId.toString()]: {
        'NFT-001': {
          image: ['ipfs://some_hash1'],
          name: 'One',
          version: '1.0'
        },
        'NFT-002': {
          image: ['ipfs://some_hash2'],
          name: 'Two',
          version: '1.0'
        },
        'NFT-files': {
          description: ['NFT with different types of files'],
          files: [
            {
              mediaType: 'video/mp4',
              name: 'some name',
              src: ['file://some_video_file']
            },
            {
              mediaType: 'audio/mpeg',
              name: 'some name',
              src: ['file://some_audio_file', 'file://another_audio_file']
            }
          ],
          id: '1',
          image: ['ipfs://somehash'],
          mediaType: 'image/png',
          name: 'NFT with files',
          version: '1.0'
        }
      }
    });

    const auxiliaryData = {
      body: {
        blob: new Map([[721n, txMetadatum]])
      }
    };

    const txProps = {
      auxiliaryData,
      extraSigners: [policySigner],
      mint: tokens,
      outputs: new Set([
        {
          address: walletAddress,
          value: {
            assets: tokens,
            coins: 50_000_000n
          }
        }
      ]),
      scripts: [policyScript]
    };

    const unsignedTx = await wallet.initializeTx(txProps);

    const finalizeProps = {
      auxiliaryData,
      extraSigners: [policySigner],
      scripts: [policyScript],
      tx: unsignedTx
    };

    const signedTx = await wallet.finalizeTx(finalizeProps);
    await submitAndConfirm(wallet, signedTx);

    // Wait until wallet is aware of the minted tokens.
    await firstValueFrom(
      combineLatest([wallet.assets$, wallet.balance.utxo.total$]).pipe(
        filter(
          ([assets, balance]) =>
            assets &&
            assets.size === balance.assets?.size &&
            assetIds.every((element) => {
              const asset = assets.get(element);
              // asset info with metadata has loaded
              if (asset?.tokenMetadata === undefined || asset?.nftMetadata === undefined) return false;
              return true;
            })
        )
      )
    );
  });

  afterAll(() => {
    wallet.shutdown();
  });

  it('supports multiple CIP-25 NFT metadata in one tx', async () => {
    const nfts = await firstValueFrom(
      combineLatest([wallet.assets$, wallet.balance.utxo.total$]).pipe(
        filter(([assets, balance]) => assets.size === balance.assets?.size),
        map(([assets]) => [...assets.values()].filter((asset) => !!asset.nftMetadata))
      )
    );

    expect(nfts.find((nft) => nft.assetId === assetIds[TOKEN_METADATA_2_INDEX])).toMatchObject({
      assetId: assetIds[TOKEN_METADATA_2_INDEX],
      fingerprint: fingerprints[TOKEN_METADATA_2_INDEX],
      mintOrBurnCount: 1,
      name: assetNames[TOKEN_METADATA_2_INDEX],
      nftMetadata: {
        image: ['ipfs://some_hash1'],
        name: 'One',
        otherProperties: new Map([['version', '1.0']]),
        version: '1.0'
      },
      policyId: policyId.toString(),
      quantity: 1n,
      tokenMetadata: null
    });
    expect(nfts.find((nft) => nft.assetId === assetIds[TOKEN_METADATA_1_INDEX])).toBeDefined();
  });

  it('parses CIP-25 NFT metadata with files', async () => {
    const nfts = await firstValueFrom(
      combineLatest([wallet.assets$, wallet.balance.utxo.total$]).pipe(
        filter(([assets, balance]) => assets.size === balance.assets?.size),
        map(([assets]) => [...assets.values()].filter((asset) => !!asset.nftMetadata))
      )
    );
    expect(nfts.find((nft) => nft.assetId === assetIds[TOKEN_METADATA_1_INDEX])).toMatchObject({
      assetId: assetIds[TOKEN_METADATA_1_INDEX],
      fingerprint: fingerprints[TOKEN_METADATA_1_INDEX],
      mintOrBurnCount: 1,
      name: assetNames[TOKEN_METADATA_1_INDEX],
      nftMetadata: {
        description: ['NFT with different types of files'],
        files: [
          {
            mediaType: 'video/mp4',
            name: 'some name',
            src: ['file://some_video_file']
          },
          {
            mediaType: 'audio/mpeg',
            name: 'some name',
            src: ['file://some_audio_file', 'file://another_audio_file']
          }
        ],
        image: ['ipfs://somehash'],
        mediaType: 'image/png',
        name: 'NFT with files',
        otherProperties: new Map([
          ['id', '1'],
          ['version', '1.0']
        ]),
        version: '1.0'
      },
      policyId: policyId.toString(),
      quantity: 1n,
      tokenMetadata: null
    });
  });

  it('supports burning tokens', async () => {
    // spend entire balance of test asset
    const availableBalance = await firstValueFrom(wallet.balance.utxo.available$);
    const assetBalance = availableBalance.assets!.get(assetIds[TOKEN_BURN_INDEX])!;
    expect(assetBalance).toBeGreaterThan(0n);
    const txProps = {
      extraSigners: [policySigner],
      mint: new Map([[assetIds[TOKEN_BURN_INDEX], -assetBalance]]),
      outputs: new Set([
        {
          address: walletAddress,
          value: {
            coins: 50_000_000n
          }
        }
      ]),
      scripts: [policyScript]
    };

    const unsignedTx = await wallet.initializeTx(txProps);

    const finalizeProps = {
      extraSigners: [policySigner],
      scripts: [policyScript],
      tx: unsignedTx
    };

    const signedTx = await wallet.finalizeTx(finalizeProps);
    await submitAndConfirm(wallet, signedTx);

    // Wait until wallet is aware of the burned token.
    await firstValueFrom(
      wallet.balance.utxo.total$.pipe(
        filter(({ assets }) => (assets ? !assets.has(assetIds[TOKEN_BURN_INDEX]) : false))
      )
    );

    const nfts = await firstValueFrom(
      combineLatest([wallet.assets$, wallet.balance.utxo.total$]).pipe(
        filter(([assets, balance]) => assets.size === balance.assets?.size),
        map(([assets]) => [...assets.values()].filter((asset) => !!asset.nftMetadata))
      )
    );

    expect(nfts.find((nft) => nft.assetId === assetIds[TOKEN_BURN_INDEX])).toBeUndefined();
  });
});
