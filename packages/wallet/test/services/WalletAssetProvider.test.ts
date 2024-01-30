import { Asset, AssetProvider, Cardano, Serialization, metadatum } from '@cardano-sdk/core';
import { AssetId, generateRandomHexString } from '@cardano-sdk/util-dev';
import { HexBlob } from '@cardano-sdk/util';
import { createWalletAssetProvider } from '../../src';
import { dummyLogger as logger } from 'ts-log';
import { of } from 'rxjs';

const createMockAssetProvider = jest.fn().mockImplementation(
  (assets: Map<Cardano.AssetId, Asset.AssetInfo>): AssetProvider => ({
    getAsset: jest.fn(async (args) => {
      const asset = assets.get(args.assetId);
      if (!asset) throw new Error(`Asset ${args.assetId} not found`);
      return asset;
    }),
    getAssets: jest.fn(async (args) =>
      args.assetIds.map((assetId) => {
        const asset = assets.get(assetId);
        if (!asset) throw new Error(`Asset ${assetId} not found`);
        return asset;
      })
    ),
    healthCheck: jest.fn(async () => ({ ok: true }))
  })
);

const createMockTx = (
  outputs: Cardano.TxOut[],
  mint?: Cardano.TokenMap,
  auxiliaryData?: Cardano.AuxiliaryData
): Cardano.Tx =>
  ({
    auxiliaryData,
    body: { mint, outputs },
    id: generateRandomHexString(64)
  } as Cardano.Tx);

const cip68AssetId = {
  referenceNFT: Cardano.AssetId.fromParts(
    Cardano.AssetId.getPolicyId(AssetId.TSLA),
    Asset.AssetNameLabel.encode(Cardano.AssetId.getAssetName(AssetId.TSLA), Asset.AssetNameLabelNum.ReferenceNFT)
  ),
  userNFT: Cardano.AssetId.fromParts(
    Cardano.AssetId.getPolicyId(AssetId.TSLA),
    Asset.AssetNameLabel.encode(Cardano.AssetId.getAssetName(AssetId.TSLA), Asset.AssetNameLabelNum.UserNFT)
  )
};

const assetInfo = {
  PXL: {
    assetId: AssetId.PXL,
    name: Cardano.AssetId.getAssetName(AssetId.PXL),
    nftMetadata: { name: 'nft' },
    policyId: Cardano.AssetId.getPolicyId(AssetId.PXL),
    supply: 1n,
    tokenMetadata: null
  } as Asset.AssetInfo,
  TSLA: {
    assetId: AssetId.TSLA,
    name: Cardano.AssetId.getAssetName(AssetId.TSLA),
    nftMetadata: null,
    policyId: Cardano.AssetId.getPolicyId(AssetId.TSLA),
    tokenMetadata: null
  } as Asset.AssetInfo,
  Unit: {
    assetId: AssetId.Unit,
    name: Cardano.AssetId.getAssetName(AssetId.Unit),
    nftMetadata: null,
    policyId: Cardano.AssetId.getPolicyId(AssetId.Unit),
    tokenMetadata: null
  } as Asset.AssetInfo,
  UnresolvedA: {
    assetId: AssetId.A,
    fingerprint: Cardano.AssetFingerprint.fromParts(
      Cardano.AssetId.getPolicyId(AssetId.A),
      Cardano.AssetId.getAssetName(AssetId.A)
    ),
    name: Cardano.AssetId.getAssetName(AssetId.A),
    policyId: Cardano.AssetId.getPolicyId(AssetId.A),
    quantity: 0n,
    supply: 0n
  } as Asset.AssetInfo,
  UnresolvedPXL: {
    assetId: AssetId.PXL,
    fingerprint: Cardano.AssetFingerprint.fromParts(
      Cardano.AssetId.getPolicyId(AssetId.PXL),
      Cardano.AssetId.getAssetName(AssetId.PXL)
    ),
    name: Cardano.AssetId.getAssetName(AssetId.PXL),
    policyId: Cardano.AssetId.getPolicyId(AssetId.PXL),
    quantity: 0n,
    supply: 0n
  } as Asset.AssetInfo,
  cip68ReferenceNft: {
    assetId: cip68AssetId.referenceNFT,
    name: Cardano.AssetId.getAssetName(cip68AssetId.referenceNFT),
    nftMetadata: null,
    policyId: Cardano.AssetId.getPolicyId(cip68AssetId.referenceNFT),
    tokenMetadata: null
  } as Asset.AssetInfo,
  cip68UserNft: [
    {
      assetId: cip68AssetId.userNFT,
      fingerprint: Cardano.AssetFingerprint.fromParts(
        Cardano.AssetId.getPolicyId(cip68AssetId.userNFT),
        Cardano.AssetId.getAssetName(cip68AssetId.userNFT)
      ),
      name: Cardano.AssetId.getAssetName(cip68AssetId.userNFT),
      nftMetadata: {
        image: 'ipfs://zb2rhaGkrm2gQC366SZbbTQmjDd3fjd44ftHH4L4TtABypSKa_old',
        mediaType: 'image/jpeg',
        name: '$snek69_old',
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        otherProperties: new Map<any, any>([
          ['og', 1n],
          ['og_number', 1n],
          ['rarity', 'common'],
          ['length', 7n],
          ['characters', 'letters,numbers'],
          ['numeric_modifiers', ''],
          ['version', 2n],
          ['version', '1.0']
        ]),
        version: '1'
      },
      policyId: Cardano.AssetId.getPolicyId(cip68AssetId.userNFT),
      quantity: 1n,
      supply: 1n
    } as Asset.AssetInfo,
    {
      assetId: cip68AssetId.userNFT,
      fingerprint: Cardano.AssetFingerprint.fromParts(
        Cardano.AssetId.getPolicyId(cip68AssetId.userNFT),
        Cardano.AssetId.getAssetName(cip68AssetId.userNFT)
      ),
      name: Cardano.AssetId.getAssetName(cip68AssetId.userNFT),
      nftMetadata: {
        image: 'ipfs://zb2rhaGkrm2gQC366SZbbTQmjDd3fjd44ftHH4L4TtABypSKa',
        mediaType: 'image/jpeg',
        name: '$snek69',
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        otherProperties: new Map<any, any>([
          ['og', 0n],
          ['og_number', 0n],
          ['rarity', 'common'],
          ['length', 6n],
          ['characters', 'letters,numbers'],
          ['numeric_modifiers', ''],
          ['version', 1n]
        ]),
        version: '1'
      },
      policyId: Cardano.AssetId.getPolicyId(cip68AssetId.userNFT),
      quantity: 1n,
      supply: 1n
    } as Asset.AssetInfo
  ]
};

const metadata = metadatum.jsonToMetadatum({
  [Cardano.AssetId.getPolicyId(AssetId.PXL)]: {
    [Cardano.AssetId.getAssetName(AssetId.PXL)]: {
      description: ['PXL'],
      // eslint-disable-next-line sonarjs/no-duplicate-string
      image: ['ipfs://PXL'],
      mediaType: 'image/png',
      name: 'PXL',
      version: '1.0'
    }
  }
});

const auxiliaryData = {
  blob: new Map([[721n, metadata]])
};

const nftMetadataDatum = HexBlob(
  'd8799faa446e616d654724736e656b363945696d6167655838697066733a2f2f7a6232726861476b726d32675143333636535a626254516d6a446433666a64343466744848344c34547441427970534b61496d65646961547970654a696d6167652f6a706567426f6700496f675f6e756d626572004672617269747946636f6d6d6f6e466c656e677468064a636861726163746572734f6c6574746572732c6e756d62657273516e756d657269635f6d6f64696669657273404776657273696f6e0101a84e7374616e646172645f696d6167655838697066733a2f2f7a6232726861476b726d32675143333636535a626254516d6a446433666a64343466744848344c34547441427970534b6146706f7274616c404864657369676e65724047736f6369616c73404676656e646f72404764656661756c7400536c6173745f7570646174655f616464726573735839003382fe4bf2249a8fb53df0b64aba1c78c95f117a7d57c59d9869b341389caccf78b5f141efbd97de910777674368d8ffedbb3fdc797028384c76616c6964617465645f6279581c4da965a049dfd15ed1ee19fba6e2974a0b79fc416dd1796a1f97f5e1ff'
);

const datum = Serialization.Datum.newInlineData(
  Serialization.PlutusData.fromCbor(nftMetadataDatum)
).toCore() as Cardano.PlutusData;

const sortAssetInfoArray = (infos: Asset.AssetInfo[]): Asset.AssetInfo[] =>
  infos.sort((a, b) => (a.assetId < b.assetId ? 1 : -1));

describe('createWalletAssetProvider', () => {
  describe('getAsset', () => {
    it('fetches the asset from the backend provider if it is not present in the assetInfo$ cached value', async () => {
      // Arrange
      const assetProvider = createMockAssetProvider(new Map([[AssetId.PXL, assetInfo.PXL]]));
      const assetInfo$ = of(new Map());
      const tx = createMockTx([]);

      const walletAssetProvider = createWalletAssetProvider({ assetInfo$, assetProvider, logger, tx });

      // Act
      const info = await walletAssetProvider.getAsset({ assetId: AssetId.PXL });

      // Assert
      expect(info).toEqual(assetInfo.PXL);
      expect(assetProvider.getAsset).toHaveBeenCalledWith({
        assetId: AssetId.PXL,
        extraData: { nftMetadata: true, tokenMetadata: true }
      });
    });

    it('doesnt fetches the asset from the backend provider if it is present in the assetInfo$ cached value', async () => {
      // Arrange
      const assetProvider = createMockAssetProvider(new Map());
      const assetInfo$ = of(new Map([[AssetId.PXL, assetInfo.PXL]]));
      const tx = createMockTx([]);

      const walletAssetProvider = createWalletAssetProvider({ assetInfo$, assetProvider, logger, tx });

      // Act
      const info = await walletAssetProvider.getAsset({ assetId: AssetId.PXL });

      // Assert
      expect(info).toEqual(assetInfo.PXL);
      expect(assetProvider.getAsset).not.toHaveBeenCalled();
    });

    it('returns the asset info if it cant be found but is being minted in the transaction (CIP-25)', async () => {
      // Arrange
      const assetProvider = createMockAssetProvider(new Map());
      const assetInfo$ = of(new Map());
      const tx = createMockTx([], new Map([[AssetId.PXL, 1n]]), auxiliaryData);

      const walletAssetProvider = createWalletAssetProvider({ assetInfo$, assetProvider, logger, tx });

      const pxlAssetInfo = {
        assetId: AssetId.PXL,
        fingerprint: Cardano.AssetFingerprint.fromParts(
          Cardano.AssetId.getPolicyId(AssetId.PXL),
          Cardano.AssetId.getAssetName(AssetId.PXL)
        ),
        name: Cardano.AssetId.getAssetName(AssetId.PXL),
        nftMetadata: {
          description: 'PXL',
          image: 'ipfs://PXL',
          mediaType: 'image/png',
          name: 'PXL',
          otherProperties: new Map([['version', '1.0']]),
          version: '1.0'
        },
        policyId: Cardano.AssetId.getPolicyId(AssetId.PXL),
        quantity: 1n,
        supply: 1n
      };

      // Act
      const info = await walletAssetProvider.getAsset({ assetId: AssetId.PXL });

      // Assert
      expect(info).toEqual(pxlAssetInfo);
      expect(assetProvider.getAsset).toHaveBeenCalledWith({
        assetId: AssetId.PXL,
        extraData: { nftMetadata: true, tokenMetadata: true }
      });
    });

    it('returns the asset info if it cant be found but is being minted in the transaction (CIP-68)', async () => {
      // Arrange
      const assetProvider = createMockAssetProvider(new Map());
      const assetInfo$ = of(new Map());
      const outputs = [
        { datum, value: { assets: new Map([[cip68AssetId.referenceNFT, 1n]]), coins: 1_000_000n } } as Cardano.TxOut
      ];
      const tx = createMockTx(outputs, new Map([[cip68AssetId.userNFT, 1n]]));

      const walletAssetProvider = createWalletAssetProvider({ assetInfo$, assetProvider, logger, tx });

      const userNFTAssetInfo = {
        assetId: cip68AssetId.userNFT,
        fingerprint: Cardano.AssetFingerprint.fromParts(
          Cardano.AssetId.getPolicyId(cip68AssetId.userNFT),
          Cardano.AssetId.getAssetName(cip68AssetId.userNFT)
        ),
        name: Cardano.AssetId.getAssetName(cip68AssetId.userNFT),
        nftMetadata: assetInfo.cip68UserNft[1].nftMetadata,
        policyId: Cardano.AssetId.getPolicyId(cip68AssetId.userNFT),
        quantity: 1n,
        supply: 1n
      };

      // Act
      const info = await walletAssetProvider.getAsset({ assetId: cip68AssetId.userNFT });

      // Assert
      expect(info).toEqual(userNFTAssetInfo);
      expect(assetProvider.getAsset).toHaveBeenCalledWith({
        assetId: cip68AssetId.userNFT,
        extraData: { nftMetadata: true, tokenMetadata: true }
      });
    });

    it('updates CIP-68 metadata even if no asset was minted', async () => {
      // Arrange
      const assetProvider = createMockAssetProvider(new Map([[cip68AssetId.userNFT, assetInfo.cip68UserNft[0]]]));
      const assetInfo$ = of(new Map());
      const outputs = [
        { datum, value: { assets: new Map([[cip68AssetId.referenceNFT, 1n]]), coins: 1_000_000n } } as Cardano.TxOut
      ];
      const tx = createMockTx(outputs, new Map());

      const walletAssetProvider = createWalletAssetProvider({ assetInfo$, assetProvider, logger, tx });

      const userNFTAssetInfo = {
        assetId: cip68AssetId.userNFT,
        fingerprint: Cardano.AssetFingerprint.fromParts(
          Cardano.AssetId.getPolicyId(cip68AssetId.userNFT),
          Cardano.AssetId.getAssetName(cip68AssetId.userNFT)
        ),
        name: Cardano.AssetId.getAssetName(cip68AssetId.userNFT),
        nftMetadata: assetInfo.cip68UserNft[1].nftMetadata,
        policyId: Cardano.AssetId.getPolicyId(cip68AssetId.userNFT),
        quantity: 1n,
        supply: 1n
      };

      // Act
      const info = await walletAssetProvider.getAsset({ assetId: cip68AssetId.userNFT });

      // Assert
      expect(info).toEqual(userNFTAssetInfo);
      expect(assetProvider.getAsset).toHaveBeenCalledWith({
        assetId: cip68AssetId.userNFT,
        extraData: { nftMetadata: true, tokenMetadata: true }
      });
    });

    it('returns an asset info with basic information if the token can not be resolved', async () => {
      // Arrange
      const assetProvider = createMockAssetProvider(new Map());
      const assetInfo$ = of(new Map());
      const tx = createMockTx([]);

      const walletAssetProvider = createWalletAssetProvider({ assetInfo$, assetProvider, logger, tx });

      // Act
      const info = await walletAssetProvider.getAsset({ assetId: AssetId.PXL });

      // Assert
      expect(info).toEqual(assetInfo.UnresolvedPXL);
      expect(assetProvider.getAsset).toHaveBeenCalledWith({
        assetId: AssetId.PXL,
        extraData: { nftMetadata: true, tokenMetadata: true }
      });
    });

    it('will fetch metadata only from backend and cache if TX is omitted', async () => {
      // Arrange
      const assetProvider = createMockAssetProvider(new Map([[cip68AssetId.userNFT, assetInfo.cip68UserNft[0]]]));
      const assetInfo$ = of(new Map());

      const walletAssetProvider = createWalletAssetProvider({ assetInfo$, assetProvider, logger });

      // Act
      const info = await walletAssetProvider.getAsset({ assetId: cip68AssetId.userNFT });

      // Assert
      expect(info).toEqual(assetInfo.cip68UserNft[0]);
      expect(assetProvider.getAsset).toHaveBeenCalledWith({
        assetId: cip68AssetId.userNFT,
        extraData: { nftMetadata: true, tokenMetadata: true }
      });
    });

    it('coalesce the asset info from the transaction (mint) with the one on chain', async () => {
      // Arrange
      const assetProvider = createMockAssetProvider(new Map([[AssetId.PXL, assetInfo.PXL]]));
      const assetInfo$ = of(new Map());
      const tx = createMockTx([], new Map([[AssetId.PXL, 1n]]), auxiliaryData);

      const walletAssetProvider = createWalletAssetProvider({ assetInfo$, assetProvider, logger, tx });

      const pxlAssetInfo = assetInfo.PXL;

      // Metadata should be overridden by the one present in the transaction as it would be the most up to date if the transaction succeeds.
      pxlAssetInfo.nftMetadata = {
        description: 'PXL',
        image: Asset.Uri('ipfs://PXL'),
        mediaType: Asset.ImageMediaType('image/png'),
        name: 'PXL',
        otherProperties: new Map([['version', '1.0']]),
        version: '1.0'
      };

      // The supply should be updated with the minted amount.
      pxlAssetInfo.supply += 1n;

      // Act
      const info = await walletAssetProvider.getAsset({ assetId: AssetId.PXL });

      // Assert
      expect(info).toEqual(pxlAssetInfo);
      expect(assetProvider.getAsset).toHaveBeenCalledWith({
        assetId: AssetId.PXL,
        extraData: { nftMetadata: true, tokenMetadata: true }
      });
    });
  });

  describe('getAssets', () => {
    it('fetches the assets from the backend provider if it is not present in the assetInfo$ cached value', async () => {
      // Arrange
      const assetProvider = createMockAssetProvider(
        new Map([
          [AssetId.PXL, assetInfo.PXL],
          [AssetId.TSLA, assetInfo.TSLA]
        ])
      );
      const assetInfo$ = of(new Map());
      const tx = createMockTx([]);

      const walletAssetProvider = createWalletAssetProvider({ assetInfo$, assetProvider, logger, tx });

      // Act
      const infos = await walletAssetProvider.getAssets({ assetIds: [AssetId.PXL, AssetId.TSLA] });

      // Assert
      expect(infos).toEqual([assetInfo.PXL, assetInfo.TSLA]);
      expect(assetProvider.getAsset).toHaveBeenCalledWith({
        assetId: AssetId.PXL,
        extraData: { nftMetadata: true, tokenMetadata: true }
      });
      expect(assetProvider.getAsset).toHaveBeenCalledWith({
        assetId: AssetId.TSLA,
        extraData: { nftMetadata: true, tokenMetadata: true }
      });
    });

    it('doesnt fetches the assets from the backend provider if it is present in the assetInfo$ cached value', async () => {
      // Arrange
      const assetProvider = createMockAssetProvider(new Map());
      const assetInfo$ = of(
        new Map([
          [AssetId.PXL, assetInfo.PXL],
          [AssetId.TSLA, assetInfo.TSLA]
        ])
      );
      const tx = createMockTx([]);

      const walletAssetProvider = createWalletAssetProvider({ assetInfo$, assetProvider, logger, tx });

      // Act
      const infos = await walletAssetProvider.getAssets({ assetIds: [AssetId.PXL, AssetId.TSLA] });

      // Assert
      expect(infos).toEqual([assetInfo.PXL, assetInfo.TSLA]);
      expect(assetProvider.getAsset).not.toHaveBeenCalled();
    });

    it('returns the asset infos if they cant be found but they are being minted in the transaction (CIP-25)', async () => {
      // Arrange
      const assetProvider = createMockAssetProvider(new Map());
      const assetInfo$ = of(new Map());
      const tx = createMockTx([], new Map([[AssetId.PXL, 1n]]), auxiliaryData);

      const walletAssetProvider = createWalletAssetProvider({ assetInfo$, assetProvider, logger, tx });

      const pxlAssetInfo = {
        assetId: AssetId.PXL,
        fingerprint: Cardano.AssetFingerprint.fromParts(
          Cardano.AssetId.getPolicyId(AssetId.PXL),
          Cardano.AssetId.getAssetName(AssetId.PXL)
        ),
        name: Cardano.AssetId.getAssetName(AssetId.PXL),
        nftMetadata: {
          description: 'PXL',
          image: 'ipfs://PXL',
          mediaType: 'image/png',
          name: 'PXL',
          otherProperties: new Map([['version', '1.0']]),
          version: '1.0'
        },
        policyId: Cardano.AssetId.getPolicyId(AssetId.PXL),
        quantity: 1n,
        supply: 1n
      };

      // Act
      const infos = await walletAssetProvider.getAssets({ assetIds: [AssetId.PXL] });

      // Assert
      expect(infos).toEqual([pxlAssetInfo]);
      expect(assetProvider.getAsset).toHaveBeenCalledWith({
        assetId: AssetId.PXL,
        extraData: { nftMetadata: true, tokenMetadata: true }
      });
    });

    it('returns the asset infos if they cant be found but they are being minted in the transaction (CIP-68)', async () => {
      // Arrange
      const assetProvider = createMockAssetProvider(new Map());
      const assetInfo$ = of(new Map());
      const outputs = [
        { datum, value: { assets: new Map([[cip68AssetId.referenceNFT, 1n]]), coins: 1_000_000n } } as Cardano.TxOut
      ];
      const tx = createMockTx(outputs, new Map([[cip68AssetId.userNFT, 1n]]));

      const walletAssetProvider = createWalletAssetProvider({ assetInfo$, assetProvider, logger, tx });

      const userNFTAssetInfo = {
        assetId: cip68AssetId.userNFT,
        fingerprint: Cardano.AssetFingerprint.fromParts(
          Cardano.AssetId.getPolicyId(cip68AssetId.userNFT),
          Cardano.AssetId.getAssetName(cip68AssetId.userNFT)
        ),
        name: Cardano.AssetId.getAssetName(cip68AssetId.userNFT),
        nftMetadata: assetInfo.cip68UserNft[1].nftMetadata,
        policyId: Cardano.AssetId.getPolicyId(cip68AssetId.userNFT),
        quantity: 1n,
        supply: 1n
      };

      // Act
      const infos = await walletAssetProvider.getAssets({ assetIds: [cip68AssetId.userNFT] });

      // Assert
      expect(infos).toEqual([userNFTAssetInfo]);
      expect(assetProvider.getAsset).toHaveBeenCalledWith({
        assetId: cip68AssetId.userNFT,
        extraData: { nftMetadata: true, tokenMetadata: true }
      });
    });

    it('returns asset infos with basic information if the tokens can not be resolved', async () => {
      // Arrange
      const assetProvider = createMockAssetProvider(new Map());
      const assetInfo$ = of(new Map());
      const tx = createMockTx([]);

      const walletAssetProvider = createWalletAssetProvider({ assetInfo$, assetProvider, logger, tx });

      // Act
      const infos = await walletAssetProvider.getAssets({ assetIds: [AssetId.PXL] });

      // Assert
      expect(infos).toEqual([assetInfo.UnresolvedPXL]);
      expect(assetProvider.getAsset).toHaveBeenCalledWith({
        assetId: AssetId.PXL,
        extraData: { nftMetadata: true, tokenMetadata: true }
      });
    });

    it('updates CIP-68 metadata even if no asset was minted', async () => {
      // Arrange
      const assetProvider = createMockAssetProvider(new Map([[cip68AssetId.userNFT, assetInfo.cip68UserNft[0]]]));
      const assetInfo$ = of(new Map());
      const outputs = [
        { datum, value: { assets: new Map([[cip68AssetId.referenceNFT, 1n]]), coins: 1_000_000n } } as Cardano.TxOut
      ];
      const tx = createMockTx(outputs, new Map());

      const walletAssetProvider = createWalletAssetProvider({ assetInfo$, assetProvider, logger, tx });

      const userNFTAssetInfo = {
        assetId: cip68AssetId.userNFT,
        fingerprint: Cardano.AssetFingerprint.fromParts(
          Cardano.AssetId.getPolicyId(cip68AssetId.userNFT),
          Cardano.AssetId.getAssetName(cip68AssetId.userNFT)
        ),
        name: Cardano.AssetId.getAssetName(cip68AssetId.userNFT),
        nftMetadata: assetInfo.cip68UserNft[1].nftMetadata,
        policyId: Cardano.AssetId.getPolicyId(cip68AssetId.userNFT),
        quantity: 1n,
        supply: 1n
      };

      // Act
      const info = await walletAssetProvider.getAssets({ assetIds: [cip68AssetId.userNFT] });

      // Assert
      expect(info).toEqual([userNFTAssetInfo]);
      expect(assetProvider.getAsset).toHaveBeenCalledWith({
        assetId: cip68AssetId.userNFT,
        extraData: { nftMetadata: true, tokenMetadata: true }
      });
    });

    it('will fetch metadata only from backend and cache if TX is omitted', async () => {
      // Arrange
      const assetProvider = createMockAssetProvider(new Map([[cip68AssetId.userNFT, assetInfo.cip68UserNft[0]]]));
      const assetInfo$ = of(new Map());

      const walletAssetProvider = createWalletAssetProvider({ assetInfo$, assetProvider, logger });

      // Act
      const info = await walletAssetProvider.getAssets({ assetIds: [cip68AssetId.userNFT] });

      // Assert
      expect(info).toEqual([assetInfo.cip68UserNft[0]]);
      expect(assetProvider.getAsset).toHaveBeenCalledWith({
        assetId: cip68AssetId.userNFT,
        extraData: { nftMetadata: true, tokenMetadata: true }
      });
    });

    it('coalesce the asset infos from the transaction (mint) with the ones on chain', async () => {
      // Arrange
      const assetProvider = createMockAssetProvider(new Map([[AssetId.PXL, assetInfo.PXL]]));
      const assetInfo$ = of(new Map());
      const tx = createMockTx([], new Map([[AssetId.PXL, 1n]]), auxiliaryData);

      const walletAssetProvider = createWalletAssetProvider({ assetInfo$, assetProvider, logger, tx });

      const pxlAssetInfo = assetInfo.PXL;

      // Metadata should be overridden by the one present in the transaction as it would be the most up to date if the transaction succeeds.
      pxlAssetInfo.nftMetadata = {
        description: 'PXL',
        image: Asset.Uri('ipfs://PXL'),
        mediaType: Asset.ImageMediaType('image/png'),
        name: 'PXL',
        otherProperties: new Map([['version', '1.0']]),
        version: '1.0'
      };

      // The supply should be updated with the minted amount.
      pxlAssetInfo.supply += 1n;

      // Act
      const infos = await walletAssetProvider.getAssets({ assetIds: [AssetId.PXL] });

      // Assert
      expect(infos).toEqual([pxlAssetInfo]);
      expect(assetProvider.getAsset).toHaveBeenCalledWith({
        assetId: AssetId.PXL,
        extraData: { nftMetadata: true, tokenMetadata: true }
      });
    });

    it('can resolve assets from different sources at the same time (cache, tx and backend)', async () => {
      // Arrange
      const assetProvider = createMockAssetProvider(
        new Map([
          [AssetId.PXL, assetInfo.PXL],
          [AssetId.Unit, assetInfo.Unit]
        ])
      );
      const assetInfo$ = of(new Map([[AssetId.TSLA, assetInfo.TSLA]]));
      const outputs = [
        { datum, value: { assets: new Map([[cip68AssetId.referenceNFT, 1n]]), coins: 1_000_000n } } as Cardano.TxOut
      ];
      const tx = createMockTx(
        outputs,
        new Map([
          [AssetId.PXL, 1n],
          [cip68AssetId.userNFT, 1n]
        ]),
        auxiliaryData
      );

      const walletAssetProvider = createWalletAssetProvider({ assetInfo$, assetProvider, logger, tx });

      const pxlAssetInfo = assetInfo.PXL;

      // Metadata should be overridden by the one present in the transaction as it would be the most up to date if the transaction succeeds.
      pxlAssetInfo.nftMetadata = {
        description: 'PXL',
        image: Asset.Uri('ipfs://PXL'),
        mediaType: Asset.ImageMediaType('image/png'),
        name: 'PXL',
        otherProperties: new Map([['version', '1.0']]),
        version: '1.0'
      };

      // The supply should be updated with the minted amount.
      pxlAssetInfo.supply += 1n;

      // Act
      const infos = await walletAssetProvider.getAssets({
        assetIds: [AssetId.PXL, AssetId.Unit, AssetId.TSLA, AssetId.A, cip68AssetId.userNFT]
      });

      // Assert
      expect(sortAssetInfoArray(infos)).toEqual(
        sortAssetInfoArray([
          pxlAssetInfo,
          assetInfo.Unit,
          assetInfo.TSLA,
          assetInfo.UnresolvedA,
          assetInfo.cip68UserNft[1]
        ])
      );

      expect(assetProvider.getAsset).toHaveBeenCalledWith({
        assetId: AssetId.PXL,
        extraData: { nftMetadata: true, tokenMetadata: true }
      });
      expect(assetProvider.getAsset).toHaveBeenCalledWith({
        assetId: AssetId.Unit,
        extraData: { nftMetadata: true, tokenMetadata: true }
      });
      expect(assetProvider.getAsset).toHaveBeenCalledWith({
        assetId: AssetId.A,
        extraData: { nftMetadata: true, tokenMetadata: true }
      });
      expect(assetProvider.getAsset).toHaveBeenCalledWith({
        assetId: cip68AssetId.userNFT,
        extraData: { nftMetadata: true, tokenMetadata: true }
      });
    });
  });
});
