import { Cardano } from '@cardano-sdk/core';
import { NftMetadataEntity } from '@cardano-sdk/projection-typeorm';
import { TypeormService } from '../util/index.js';
import type { Asset } from '@cardano-sdk/core';
import type { AssetPolicyIdAndName, NftMetadataService } from './types.js';
import type { TypeormProviderDependencies } from '../util/index.js';

export class TypeOrmNftMetadataService extends TypeormService implements NftMetadataService {
  constructor({ connectionConfig$, logger, entities }: TypeormProviderDependencies) {
    super('TypeOrmNftMetadataService', { connectionConfig$, entities, logger });
  }

  async getNftMetadata(assetInfo: AssetPolicyIdAndName): Promise<Asset.NftMetadata | null> {
    const assetId = Cardano.AssetId.fromParts(assetInfo.policyId, assetInfo.name);
    return this.withDataSource(async (dataSource) => {
      const queryRunner = dataSource.createQueryRunner();
      let asset: NftMetadataEntity | null;

      try {
        const nftMetadataRepository = queryRunner.manager.getRepository(NftMetadataEntity);
        asset = await nftMetadataRepository.findOneBy({
          userTokenAsset: { id: assetId }
        });
      } catch (error) {
        this.logger.error(error);
        asset = null;
      } finally {
        await queryRunner.release();
      }

      if (!asset) {
        return null;
      }

      return {
        image: asset.image!,
        name: asset.name!,
        ...(asset.description && { description: asset.description }),
        ...(asset.files && { files: asset.files }),
        ...(asset.mediaType && { mediaType: asset.mediaType as Asset.ImageMediaType }),
        ...(asset.otherProperties && { otherProperties: asset.otherProperties }),
        version: asset.otherProperties?.get('version') as string
      };
    });
  }
}
