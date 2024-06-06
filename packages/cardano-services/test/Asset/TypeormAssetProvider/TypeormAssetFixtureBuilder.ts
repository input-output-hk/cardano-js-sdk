import { AssetEntity, NftMetadataEntity } from '@cardano-sdk/projection-typeorm';
import { Cardano } from '@cardano-sdk/core';
import { IsNull, Not } from 'typeorm';
import { TypeormProvider } from '../../../src/util/index.js';
import type { Asset } from '@cardano-sdk/core';
import type { Logger } from 'ts-log';
import type { TypeormProviderDependencies } from '../../../src/util/index.js';

export enum TypeormAssetWith {
  metadata = 'metadata'
}

export class TypeormAssetFixtureBuilder extends TypeormProvider {
  #logger: Logger;

  constructor({ connectionConfig$, entities, logger }: TypeormProviderDependencies) {
    super('TypeormAssetFixtureBuilder', { connectionConfig$, entities, logger });
    this.#logger = logger;
  }

  public async getAssets(desiredQty: number, options?: { with?: TypeormAssetWith[] }): Promise<Asset.AssetInfo[]> {
    this.#logger.debug(`About to fetch up to ${desiredQty} assets`);

    const assets = await this.#getAssetsQuery(desiredQty, !!options?.with?.includes(TypeormAssetWith.metadata));

    const resultQty = assets.length;

    if (assets.length === 0) {
      throw new Error('No assets found');
    } else if (resultQty < desiredQty) {
      this.#logger.warn(`${desiredQty} assets desired, only ${resultQty} results found`);
    }

    const assetsInfo: Asset.AssetInfo[] = assets.map((row) => {
      const assetId = row.id!;
      const policyId = Cardano.AssetId.getPolicyId(assetId);
      const assetName = Cardano.AssetId.getAssetName(assetId);
      const fingerprint = Cardano.AssetFingerprint.fromParts(policyId, Cardano.AssetName(assetName));
      const supply = row.supply!;
      return { assetId, fingerprint, name: assetName, policyId, quantity: supply, supply };
    });

    if (options?.with?.includes(TypeormAssetWith.metadata)) {
      await Promise.all(
        assetsInfo.map(async (assetInfo) => {
          const assetMetadata = await this.#getNftMetadataQuery(assetInfo.assetId);
          assetInfo.nftMetadata = assetMetadata
            ? ({
                image: assetMetadata.image,
                name: assetMetadata.name,
                ...(assetMetadata.description && { description: assetMetadata.description }),
                ...(assetMetadata.files && { files: assetMetadata.files }),
                ...(assetMetadata.mediaType && { mediaType: assetMetadata.mediaType }),
                ...(assetMetadata.otherProperties && {
                  otherProperties: assetMetadata.otherProperties
                })
              } as Asset.NftMetadata)
            : null;
        })
      );
    }

    return assetsInfo;
  }

  async #getAssetsQuery(limit: number, withNftMetadata: boolean): Promise<AssetEntity[]> {
    return this.withDataSource((dataSource) => {
      const assetRepository = dataSource.getRepository(AssetEntity);
      return assetRepository.find({ take: limit, where: { nftMetadata: withNftMetadata ? Not(IsNull()) : undefined } });
    });
  }

  async #getNftMetadataQuery(assetId: Cardano.AssetId): Promise<NftMetadataEntity | null> {
    return this.withDataSource((dataSource) => {
      const nftMetadataRepository = dataSource.getRepository(NftMetadataEntity);
      return nftMetadataRepository.findOneBy({ userTokenAsset: { id: assetId } });
    });
  }
}
