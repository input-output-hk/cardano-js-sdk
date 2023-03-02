/* eslint-disable sonarjs/no-duplicate-string */
import { Cardano, metadatum, nativeScriptPolicyId } from '@cardano-sdk/core';
import { FinalizeTxProps, InitializeTxProps, SingleAddressWallet } from '@cardano-sdk/wallet';
import { KeyRole, TransactionSigner, util } from '@cardano-sdk/key-management';
import { combineLatest, filter, firstValueFrom, map } from 'rxjs';
import { createLogger } from '@cardano-sdk/util-dev';
import { createStandaloneKeyAgent, submitAndConfirm, walletReady } from '../../util';
import { getEnv, getWallet, walletVariables } from '../../../src';

const env = getEnv(walletVariables);
const logger = createLogger();

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
  let walletAddress: Cardano.PaymentAddress;

  beforeAll(async () => {
    wallet = (await getWallet({ env, idx: 0, logger, name: 'Minting Wallet', polling: { interval: 50 } })).wallet;

    await walletReady(wallet);

    const genesis = await firstValueFrom(wallet.genesisParameters$);

    const keyAgent = await createStandaloneKeyAgent(
      util.generateMnemonicWords(),
      genesis,
      await wallet.keyAgent.getBip32Ed25519()
    );

    const pubKey = await keyAgent.derivePublicKey({
      index: 0,
      role: KeyRole.External
    });

    const keyHash = await keyAgent.bip32Ed25519.getPubKeyHash(pubKey);

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
      [policyId]: {
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

    const txProps: InitializeTxProps = {
      auxiliaryData,
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
      scripts: [policyScript],
      witness: { extraSigners: [policySigner] }
    };

    const unsignedTx = await wallet.initializeTx(txProps);

    const finalizeProps: FinalizeTxProps = {
      auxiliaryData,
      scripts: [policyScript],
      tx: unsignedTx,
      witness: { extraSigners: [policySigner] }
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
      policyId,
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
      policyId,
      quantity: 1n,
      tokenMetadata: null
    });
  });

  it('supports burning tokens', async () => {
    // spend entire balance of test asset
    const availableBalance = await firstValueFrom(wallet.balance.utxo.available$);
    const assetBalance = availableBalance.assets!.get(assetIds[TOKEN_BURN_INDEX])!;
    expect(assetBalance).toBeGreaterThan(0n);
    const txProps: InitializeTxProps = {
      mint: new Map([[assetIds[TOKEN_BURN_INDEX], -assetBalance]]),
      outputs: new Set([
        {
          address: walletAddress,
          value: {
            coins: 50_000_000n
          }
        }
      ]),
      scripts: [policyScript],
      witness: { extraSigners: [policySigner] }
    };

    const unsignedTx = await wallet.initializeTx(txProps);

    const finalizeProps: FinalizeTxProps = {
      scripts: [policyScript],
      tx: unsignedTx,
      witness: { extraSigners: [policySigner] }
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

  describe('CIP-0025 v1 and v2', () => {
    // eslint-disable-next-line unicorn/consistent-function-scoping
    const CIP0025Test = (testName: string, assetName: string, version: 1 | 2, encoding?: 'hex' | 'utf8') =>
      it(testName, async () => {
        const assetNameHex = Buffer.from(assetName).toString('hex');
        const assetId = Cardano.AssetId(`${policyId}${assetNameHex}`);
        const fingerprint = Cardano.AssetFingerprint.fromParts(policyId, Cardano.AssetName(assetNameHex));
        const tokens = new Map([[assetId, 1n]]);

        const txDataMetadatum = new Map([
          [
            version === 1 ? policyId : Buffer.from(policyId, 'hex'),
            new Map([
              [
                version === 1 ? (encoding === 'hex' ? assetNameHex : assetName) : Buffer.from(assetName),
                metadatum.jsonToMetadatum({
                  image: ['ipfs://some_hash1'],
                  name: assetName,
                  version: '1.0'
                })
              ]
            ])
          ]
        ]);

        const auxiliaryData = { body: { blob: new Map([[721n, txDataMetadatum]]) } };

        const txProps: InitializeTxProps = {
          auxiliaryData,
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
          scripts: [policyScript],
          witness: { extraSigners: [policySigner] }
        };

        const unsignedTx = await wallet.initializeTx(txProps);

        const finalizeProps: FinalizeTxProps = {
          auxiliaryData,
          scripts: [policyScript],
          tx: unsignedTx,
          witness: { extraSigners: [policySigner] }
        };

        const signedTx = await wallet.finalizeTx(finalizeProps);

        await submitAndConfirm(wallet, signedTx);

        // try remove the asset.nftMetadata filter
        const nfts = await firstValueFrom(
          combineLatest([wallet.assets$, wallet.balance.utxo.total$]).pipe(
            filter(([assets, balance]) => assets.size === balance.assets?.size),
            map(([assets]) => [...assets.values()].filter((asset) => !!asset.nftMetadata))
          )
        );

        expect(nfts.find((nft) => nft.assetId === assetId)).toMatchObject({
          assetId,
          fingerprint,
          mintOrBurnCount: 1,
          name: assetNameHex,
          nftMetadata: {
            image: ['ipfs://some_hash1'],
            name: assetName,
            otherProperties: new Map([['version', '1.0']]),
            version: '1.0'
          },
          policyId,
          quantity: 1n,
          tokenMetadata: null
        });
      });

    CIP0025Test('supports CIP-25 v1, assetName hex encoded', 'CIP-0025-v1-hex', 1, 'hex');
    CIP0025Test('supports CIP-25 v1, assetName utf8 encoded', 'CIP-0025-v1-utf8', 1, 'utf8');
    CIP0025Test('supports CIP-25 v2', 'CIP-0025-v2', 2);
  });
});
