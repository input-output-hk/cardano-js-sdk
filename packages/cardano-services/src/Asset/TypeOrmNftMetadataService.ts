import { Asset, Cardano } from '@cardano-sdk/core';
import { AssetPolicyIdAndName, NftMetadataService } from './types';
import { NftMetadataEntity } from '@cardano-sdk/projection-typeorm';
import { TypeormService, TypeormServiceDependencies } from '../util';

export class TypeOrmNftMetadataService extends TypeormService implements NftMetadataService {
  constructor({ connectionConfig$, logger, entities }: TypeormServiceDependencies) {
    super('TypeOrmNftMetadataService', { connectionConfig$, entities, logger });
  }

  async getNftMetadata(assetInfo: AssetPolicyIdAndName): Promise<Asset.NftMetadata | null> {
    const assetId = Cardano.AssetId.fromParts(assetInfo.policyId, assetInfo.name);
    const assetNameString = Buffer.from(assetInfo.name, 'hex').toString('utf8');
    return this.withDataSource(async (dataSource) => {
      const queryRunner = dataSource.createQueryRunner();
      const nftMetadataRepository = queryRunner.manager.getRepository(NftMetadataEntity);

      const asset = await nftMetadataRepository.findOneBy({
        name: assetNameString,
        userTokenAsset: { id: assetId }
      });

      if (!asset) {
        return null;
      }

      return {
        description: asset.description,
        files: asset.files,
        image: asset.image,
        mediaType: asset.mediaType,
        name: asset.name,
        otherProperties: asset.otherProperties
      } as unknown as Asset.NftMetadata;
    });
  }
}
