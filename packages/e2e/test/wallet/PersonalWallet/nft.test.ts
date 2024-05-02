/* eslint-disable sonarjs/no-duplicate-string */
import { Asset, Cardano, metadatum } from '@cardano-sdk/core';
import { Assets, BaseWallet } from '@cardano-sdk/wallet';
import {
  burnTokens,
  firstValueFromTimed,
  getEnv,
  getWallet,
  submitAndConfirm,
  walletReady,
  walletVariables
} from '../../../src';
import { combineLatest, filter, firstValueFrom, map } from 'rxjs';
import { createLogger } from '@cardano-sdk/util-dev';

const env = getEnv(walletVariables);
const logger = createLogger();

// Returns [assets in wallet balance, assetInfos with nftMetadata for the assets in the balance]
const walletBalanceAssetsAndNfts = (wallet: BaseWallet) =>
  combineLatest([wallet.balance.utxo.total$, wallet.assetInfo$]).pipe(
    filter(([balance]) => !!balance.assets),
    map(([balance, assetInfos]): [Cardano.TokenMap, Assets] => [balance.assets!, assetInfos]),
    // Wait until we have assetInfo for all balance assets
    filter(([balanceAssets, assetsInfos]) =>
      [...balanceAssets.keys()].every((balanceAssetId) => !!assetsInfos.get(balanceAssetId))
    ),
    // Keep only assetInfos with nftMetadata
    map(([balanceAssets, assets]): [Cardano.TokenMap, Asset.AssetInfo[]] => [
      balanceAssets,
      [...assets.values()].filter((asset) => !!asset.nftMetadata)
    ])
  );

describe('PersonalWallet.assets/nft', () => {
  const TOKEN_METADATA_1_INDEX = 0;
  const TOKEN_METADATA_2_INDEX = 1;
  const TOKEN_BURN_INDEX = 2;

  let wallet: BaseWallet;
  let policyId: Cardano.PolicyId;
  let policyScript: Cardano.NativeScript;
  let assetIds: Cardano.AssetId[];
  let fingerprints: Cardano.AssetFingerprint[];
  const assetNames = ['4e46542d66696c6573', '4e46542d303031', '4e46542d303032'];
  let walletAddress: Cardano.PaymentAddress;
  const coins = 10_000_000n; // number of coins to use in each transaction

  beforeAll(async () => {
    wallet = (await getWallet({ env, logger, name: 'Minting Wallet', polling: { interval: 50 } })).wallet;
    await walletReady(wallet, coins);

    const txBuilder = wallet.createTxBuilder();
    const policy = txBuilder.buildPolicy();
    policyScript = await policy.getPolicyScript();
    policyId = await policy.getPolicyId();
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
              src: 'ipfs://Qmb78QQ4RXxKQrteRn4X3WaMXXfmi2BU2dLjfWxuJoF2N5'
            },
            {
              mediaType: 'audio/mpeg',
              name: 'some name',
              src: ['ipfs://Qmb78QQ4RXxKQrteRn4X3WaMXXfmi2', 'BU2dLjfWxuJoF2Ny']
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
    const auxiliaryData = new Map([[721n, txMetadatum]]);

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

    const { tx: signedTx } = await txBuilder
      .addMint(tokens)
      .metadata(auxiliaryData)
      .addNativeScripts([policyScript])
      .addOutput(await txBuilder.buildOutput().address(walletAddress).coin(coins).assets(tokens).build())
      .build()
      .sign();
    await submitAndConfirm(wallet, signedTx);

    // Wait until wallet is aware of the minted tokens.
    await firstValueFromTimed(walletBalanceAssetsAndNfts(wallet), 'Wallet does not have the minted tokens');
  });

  afterAll(async () => {
    await burnTokens({ scripts: [policyScript], wallet });
    wallet.shutdown();
  });

  it('supports multiple CIP-25 NFT metadata in one tx', async () => {
    const [walletAssetBalance, nfts] = await firstValueFromTimed(walletBalanceAssetsAndNfts(wallet));

    // Check balance here because asset info will not be re-fetched when balance changes due to minting and burning
    expect(walletAssetBalance?.get(assetIds[TOKEN_METADATA_2_INDEX])).toBe(1n);

    expect(nfts.find((nft) => nft.assetId === assetIds[TOKEN_METADATA_2_INDEX])).toMatchObject({
      assetId: assetIds[TOKEN_METADATA_2_INDEX],
      fingerprint: fingerprints[TOKEN_METADATA_2_INDEX],
      name: assetNames[TOKEN_METADATA_2_INDEX],
      nftMetadata: {
        image: 'ipfs://some_hash1',
        name: 'One',
        otherProperties: new Map([['version', '1.0']]),
        version: '1.0'
      },
      policyId,
      // in case of repeated tests on the same network, total asset supply is not updated due to
      // the limitation that asset info is not refreshed on wallet balance changes
      quantity: expect.anything(),
      supply: expect.anything(),
      tokenMetadata: null
    });
    expect(nfts.find((nft) => nft.assetId === assetIds[TOKEN_METADATA_1_INDEX])).toBeDefined();
  });

  it('parses CIP-25 NFT metadata with files', async () => {
    const [walletAssetBalance, nfts] = await firstValueFromTimed(walletBalanceAssetsAndNfts(wallet));

    // Check balance here because asset info will not be re-fetched when balance changes due to minting and burning
    expect(walletAssetBalance?.get(assetIds[TOKEN_METADATA_1_INDEX])).toBe(1n);

    expect(nfts.find((nft) => nft.assetId === assetIds[TOKEN_METADATA_1_INDEX])).toMatchObject({
      assetId: assetIds[TOKEN_METADATA_1_INDEX],
      fingerprint: fingerprints[TOKEN_METADATA_1_INDEX],
      name: assetNames[TOKEN_METADATA_1_INDEX],
      nftMetadata: {
        description: 'NFT with different types of files',
        files: [
          {
            mediaType: 'video/mp4',
            name: 'some name',
            src: 'ipfs://Qmb78QQ4RXxKQrteRn4X3WaMXXfmi2BU2dLjfWxuJoF2N5'
          },
          {
            mediaType: 'audio/mpeg',
            name: 'some name',
            src: 'ipfs://Qmb78QQ4RXxKQrteRn4X3WaMXXfmi2BU2dLjfWxuJoF2Ny'
          }
        ],
        image: 'ipfs://somehash',
        mediaType: 'image/png',
        name: 'NFT with files',
        otherProperties: new Map([
          ['id', '1'],
          ['version', '1.0']
        ]),
        version: '1.0'
      } as Asset.NftMetadata,
      policyId,
      supply: expect.anything(),
      tokenMetadata: null
    });
  });

  it('supports burning tokens', async () => {
    // Make sure the wallet has sufficient funds to run this test
    await walletReady(wallet, coins);

    // spend entire balance of test asset
    const availableBalance = await firstValueFromTimed(wallet.balance.utxo.available$);
    const assetBalance = availableBalance.assets!.get(assetIds[TOKEN_BURN_INDEX])!;
    expect(assetBalance).toBeGreaterThan(0n);
    const txBuilder = wallet.createTxBuilder();
    const { tx: signedTx } = await txBuilder
      .addMint(new Map([[assetIds[TOKEN_BURN_INDEX], -assetBalance]]))
      .addNativeScripts([policyScript])
      .addOutput(await txBuilder.buildOutput().address(walletAddress).coin(coins).build())
      .build()
      .sign();

    await submitAndConfirm(wallet, signedTx);

    // Wait until wallet is aware of the burned token.
    await firstValueFromTimed(
      wallet.balance.utxo.total$.pipe(
        filter(({ assets }) => (assets ? !assets.has(assetIds[TOKEN_BURN_INDEX]) : false))
      ),
      'Wallet balance should not have the burned asset anymore'
    );
  });

  describe('CIP-0025 v1 and v2', () => {
    // eslint-disable-next-line unicorn/consistent-function-scoping
    const CIP0025Test = (testName: string, assetName: string, version: 1 | 2, encoding?: 'hex' | 'utf8') =>
      it(testName, async () => {
        // Make sure the wallet has sufficient funds to run this test
        await walletReady(wallet, coins);

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

        const auxiliaryData = new Map([[721n, txDataMetadatum]]);
        const txBuilder = wallet.createTxBuilder();
        const { tx: signedTx } = await txBuilder
          .addMint(tokens)
          .metadata(auxiliaryData)
          .addNativeScripts([policyScript])
          .addOutput(await txBuilder.buildOutput().address(walletAddress).coin(coins).assets(tokens).build())
          .build()
          .sign();

        await submitAndConfirm(wallet, signedTx);

        // try remove the asset.nftMetadata filter
        const [, nfts] = await firstValueFromTimed(walletBalanceAssetsAndNfts(wallet));

        expect(nfts.find((nft) => nft.assetId === assetId)).toMatchObject({
          assetId,
          fingerprint,
          name: assetNameHex,
          nftMetadata: {
            image: 'ipfs://some_hash1',
            name: assetName,
            otherProperties: new Map([['version', '1.0']]),
            version: '1.0'
          },
          policyId,
          quantity: expect.anything(),
          supply: expect.anything(),
          tokenMetadata: null
        });
      });

    CIP0025Test('supports CIP-25 v1, assetName hex encoded', 'CIP-0025-v1-hex', 1, 'hex');
    CIP0025Test('supports CIP-25 v1, assetName utf8 encoded', 'CIP-0025-v1-utf8', 1, 'utf8');
    CIP0025Test('supports CIP-25 v2', 'CIP-0025-v2', 2);
  });
});
