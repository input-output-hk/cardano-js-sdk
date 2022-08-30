/* eslint-disable sonarjs/no-duplicate-string */
import { Cardano } from '@cardano-sdk/core';
import { KeyManagement, ObservableWallet } from '@cardano-sdk/wallet';
import { combineLatest, filter, firstValueFrom, map } from 'rxjs';
import { env } from '../environment';
import { getLogger, getWallet } from '../../../src/factories';

const logger = getLogger(env.LOGGER_MIN_SEVERITY);

describe('SingleAddressWallet.assets/nft', () => {
  const TOKEN_METADATA_1_INDEX = 0;
  const TOKEN_METADATA_2_INDEX = 1;
  const TOKEN_BRUN_INDEX = 2;

  let wallet: ObservableWallet;
  let policySigner: KeyManagement.TransactionSigner;
  let policyId: Cardano.PolicyId;
  let policyScript: Cardano.NativeScript;
  let assetIds: Cardano.AssetId[];
  let fingerprints: Cardano.AssetFingerprint[];
  const assetNames = ['4e46542d66696c6573', '4e46542d303031', '4e46542d303032'];

  let walletAddress: Cardano.Address;

  beforeAll(async () => {
    wallet = (await getWallet({ env, idx: 0, logger, name: 'Minting Wallet', polling: { interval: 50 } })).wallet;

    await firstValueFrom(wallet.syncStatus.isSettled$.pipe(filter((isSettled) => isSettled)));

    const params = await firstValueFrom(wallet.genesisParameters$);

    const keyAgent = await KeyManagement.InMemoryKeyAgent.fromBip39MnemonicWords(
      {
        getPassword: async () => Buffer.from(''),
        mnemonicWords: KeyManagement.util.generateMnemonicWords(),
        networkId: params.networkId
      },
      { inputResolver: { resolveInputAddress: async () => null } }
    );

    const derivedAddress = await keyAgent.deriveAddress({
      index: 0,
      type: KeyManagement.AddressType.External
    });

    const keyHash = Cardano.policyKeyHash(derivedAddress.address);

    policySigner = new KeyManagement.util.KeyAgentTransactionSigner(keyAgent, {
      index: 0,
      role: KeyManagement.KeyRole.External
    });

    policyScript = {
      __type: Cardano.ScriptType.Native,
      kind: Cardano.NativeScriptKind.RequireAllOf,
      scripts: [
        {
          __type: Cardano.ScriptType.Native,
          keyHash: Cardano.Ed25519KeyHash(keyHash),
          kind: Cardano.NativeScriptKind.RequireSignature
        }
      ]
    };

    policyId = Cardano.nativeScriptPolicyId(policyScript);
    assetIds = [
      Cardano.AssetId(`${policyId}${assetNames[TOKEN_METADATA_1_INDEX]}`),
      Cardano.AssetId(`${policyId}${assetNames[TOKEN_METADATA_2_INDEX]}`),
      Cardano.AssetId(`${policyId}${assetNames[TOKEN_BRUN_INDEX]}`)
    ];

    const tokens = new Map([
      [assetIds[TOKEN_METADATA_1_INDEX], 1n],
      [assetIds[TOKEN_METADATA_2_INDEX], 1n],
      [assetIds[TOKEN_BRUN_INDEX], 1n]
    ]);

    fingerprints = [
      Cardano.assetFingerprint(policyId, Cardano.AssetName(assetNames[TOKEN_METADATA_1_INDEX])),
      Cardano.assetFingerprint(policyId, Cardano.AssetName(assetNames[TOKEN_METADATA_2_INDEX])),
      Cardano.assetFingerprint(policyId, Cardano.AssetName(assetNames[TOKEN_BRUN_INDEX]))
    ];

    walletAddress = (await firstValueFrom(wallet.addresses$))[0].address;

    const txMetadatum = Cardano.jsonToMetadatum({
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
    await wallet.submitTx(signedTx);

    // Wait until wallet is aware of the minted tokens.
    await firstValueFrom(
      wallet.balance.utxo.total$.pipe(
        filter(({ assets }) => (assets ? assetIds.every((element) => assets.has(element)) : false))
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

    expect(nfts.find((nft) => nft.assetId === assetIds[TOKEN_METADATA_2_INDEX])).toEqual({
      assetId: assetIds[TOKEN_METADATA_2_INDEX],
      fingerprint: fingerprints[TOKEN_METADATA_2_INDEX],
      mintOrBurnCount: 1,
      name: assetNames[TOKEN_METADATA_2_INDEX],
      nftMetadata: {
        description: undefined,
        files: undefined,
        image: ['ipfs://some_hash1'],
        mediaType: undefined,
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
    expect(nfts.find((nft) => nft.assetId === assetIds[TOKEN_METADATA_1_INDEX])).toEqual({
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
            otherProperties: undefined,
            src: ['file://some_video_file']
          },
          {
            mediaType: 'audio/mpeg',
            name: 'some name',
            otherProperties: undefined,
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
    const txProps = {
      extraSigners: [policySigner],
      mint: new Map([[assetIds[TOKEN_BRUN_INDEX], -1n]]),
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
    await wallet.submitTx(signedTx);

    // Wait until wallet is aware of the burned token.
    await firstValueFrom(
      wallet.balance.utxo.total$.pipe(
        filter(({ assets }) => (assets ? !assets.has(assetIds[TOKEN_BRUN_INDEX]) : false))
      )
    );

    const nfts = await firstValueFrom(
      combineLatest([wallet.assets$, wallet.balance.utxo.total$]).pipe(
        filter(([assets, balance]) => assets.size === balance.assets?.size),
        map(([assets]) => [...assets.values()].filter((asset) => !!asset.nftMetadata))
      )
    );

    expect(nfts.find((nft) => nft.assetId === assetIds[TOKEN_BRUN_INDEX])).toBeUndefined();
  });
});
