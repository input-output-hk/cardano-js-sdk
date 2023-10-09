import { Asset, Cardano } from '@cardano-sdk/core';
import { AssetPolicyIdAndName, NftMetadataService } from './types';
import { NftMetadataEntity } from '@cardano-sdk/projection-typeorm';
import { TypeormProviderDependencies, TypeormService } from '../util';

export class TypeOrmNftMetadataService extends TypeormService implements NftMetadataService {
  constructor({ connectionConfig$, logger, entities }: TypeormProviderDependencies) {
    super('TypeOrmNftMetadataService', { connectionConfig$, entities, logger });
  }

  async getNftMetadata(assetInfo: AssetPolicyIdAndName): Promise<Asset.NftMetadata | null> {
    const assetId = Cardano.AssetId.fromParts(assetInfo.policyId, assetInfo.name);
    const stringAssetName = Buffer.from(assetInfo.name, 'hex').toString('utf8');
    return this.withDataSource(async (dataSource) => {
      const queryRunner = dataSource.createQueryRunner();
      const nftMetadataRepository = queryRunner.manager.getRepository(NftMetadataEntity);

      const asset = await nftMetadataRepository.findOneBy({
        name: stringAssetName,
        userTokenAsset: { id: assetId }
      });

      if (!asset) {
        return null;
      }

      return {
        image: asset.image,
        name: asset.name,
        ...(asset.description && { description: asset.description }),
        ...(asset.files && { files: asset.files }),
        ...(asset.mediaType && { mediaType: asset.mediaType }),
        ...(asset.otherProperties && { otherProperties: asset.otherProperties })
      } as unknown as Asset.NftMetadata;
    });
  }
}
