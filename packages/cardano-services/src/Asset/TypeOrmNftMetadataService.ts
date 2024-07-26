import { Asset, Cardano } from '@cardano-sdk/core';
import { AssetPolicyIdAndName, NftMetadataService } from './types';
import { NftMetadataEntity } from '@cardano-sdk/projection-typeorm';
import { QueryRunner } from 'typeorm';
import { TypeormProviderDependencies, TypeormService } from '../util';

export class TypeOrmNftMetadataService extends TypeormService implements NftMetadataService {
  constructor({ connectionConfig$, logger, entities }: TypeormProviderDependencies) {
    super('TypeOrmNftMetadataService', { connectionConfig$, entities, logger });
  }

  async getNftMetadata(assetInfo: AssetPolicyIdAndName): Promise<Asset.NftMetadata | null> {
    return this.withDataSource(async (dataSource) => {
      const queryRunner = dataSource.createQueryRunner();
      return this.getNftMetadataWith(assetInfo, queryRunner);
    });
  }

  async getNftMetadataWith(assetInfo: AssetPolicyIdAndName, queryRunner: QueryRunner) {
    const assetId = Cardano.AssetId.fromParts(assetInfo.policyId, assetInfo.name);
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
  }
}
