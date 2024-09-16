import {
  Asset,
  AssetProvider,
  Cardano,
  CardanoNodeUtil,
  GetAssetArgs,
  GetAssetsArgs,
  ProviderError,
  ProviderFailure
} from '@cardano-sdk/core';
import { AssetEntity, NftMetadataEntity } from '@cardano-sdk/projection-typeorm';
import { DataSource, In, QueryRunner } from 'typeorm';
import { TokenMetadataService } from '../types';
import { TypeOrmNftMetadataService } from '../TypeOrmNftMetadataService';
import { TypeormProvider, TypeormProviderDependencies } from '../../util';

interface TypeormAssetProviderProps {
  paginationPageSizeLimit: number;
}

interface TypeormAssetProviderDependencies extends TypeormProviderDependencies {
  tokenMetadataService: TokenMetadataService;
}

export class TypeormAssetProvider extends TypeormProvider implements AssetProvider {
  #dependencies: TypeormAssetProviderDependencies;
  #nftMetadataService: TypeOrmNftMetadataService;
  #paginationPageSizeLimit: number;

  constructor({ paginationPageSizeLimit }: TypeormAssetProviderProps, dependencies: TypeormAssetProviderDependencies) {
    const { connectionConfig$, entities, logger } = dependencies;
    super('TypeormAssetProvider', { connectionConfig$, entities, logger });

    this.#dependencies = dependencies;
    this.#paginationPageSizeLimit = paginationPageSizeLimit;
    this.#nftMetadataService = new TypeOrmNftMetadataService({ connectionConfig$, entities, logger });
  }

  async getAsset({ assetId, extraData }: GetAssetArgs): Promise<Asset.AssetInfo> {
    return this.withQueryRunner(async (queryRunner) => {
      const assetInfo = await this.#getAssetInfo(assetId, queryRunner);

      if (extraData?.nftMetadata) assetInfo.nftMetadata = await this.#getNftMetadata(assetInfo, queryRunner);
      if (extraData?.tokenMetadata) {
        assetInfo.tokenMetadata = (await this.#fetchTokenMetadataList([assetId]))[0];
      }

      return assetInfo;
    });
  }

  async getAssets({ assetIds, extraData }: GetAssetsArgs): Promise<Asset.AssetInfo[]> {
    if (assetIds.length > this.#paginationPageSizeLimit) {
      throw new ProviderError(
        ProviderFailure.BadRequest,
        undefined,
        `AssetIds count of ${assetIds.length} can not be greater than ${this.#paginationPageSizeLimit}`
      );
    }

    const { nftMetadata, tokenMetadata } = extraData || {};

    const [assetInfoMap, metadataMap, tokenMap] = await this.withDataSource(async (dataSource) =>
      Promise.all([
        this.#getAssetsInfo(assetIds, dataSource),
        nftMetadata
          ? this.#getMultiNftMetadata(assetIds, dataSource)
          : Promise.resolve(new Map<Cardano.AssetId, Asset.NftMetadata>()),
        tokenMetadata
          ? this.#fetchTokenMetadataList(assetIds).then(
              (list) => new Map(list.map((metadata, id) => [assetIds[id], metadata]))
            )
          : Promise.resolve(new Map<Cardano.AssetId, Asset.TokenMetadata | null | undefined>())
      ])
    );

    return assetIds.map((assetId) => {
      const assetInfo = assetInfoMap.get(assetId);

      if (!assetInfo) throw new ProviderError(ProviderFailure.NotFound, undefined, `Asset not found '${assetId}'`);

      if (nftMetadata) assetInfo.nftMetadata = metadataMap.get(assetId) || null;
      if (tokenMetadata) assetInfo.tokenMetadata = tokenMap.get(assetId);

      return assetInfo;
    });
  }

  async #fetchTokenMetadataList(assetIds: Cardano.AssetId[]) {
    let tokenMetadataList: (Asset.TokenMetadata | null | undefined)[] = [];

    try {
      tokenMetadataList = await this.#dependencies.tokenMetadataService.getTokenMetadata(assetIds);
    } catch (error) {
      if (CardanoNodeUtil.isProviderError(error) && error.reason === ProviderFailure.Unhealthy) {
        this.logger.error(`Failed to fetch token metadata for assets ${assetIds} due to: ${error.message}`);
        tokenMetadataList = Array.from({ length: assetIds.length });
      } else {
        throw error;
      }
    }

    return tokenMetadataList;
  }

  async #getNftMetadata(
    asset: Asset.AssetInfo,
    queryRunner: QueryRunner
  ): Promise<Asset.NftMetadata | null | undefined> {
    try {
      return this.#nftMetadataService.getNftMetadataWith(
        {
          name: asset.name,
          policyId: asset.policyId
        },
        queryRunner
      );
    } catch (error) {
      this.logger.error('Failed to get nft metadata', asset.assetId, error);
    }
  }

  async #getAssetInfo(assetId: Cardano.AssetId, queryRunner: QueryRunner): Promise<Asset.AssetInfo> {
    const assetName = Cardano.AssetId.getAssetName(assetId);
    const policyId = Cardano.AssetId.getPolicyId(assetId);
    const fingerprint = Cardano.AssetFingerprint.fromParts(policyId, Cardano.AssetName(assetName));

    const assetRepository = queryRunner.manager.getRepository(AssetEntity);
    const asset = await assetRepository.findOneBy({ id: assetId });
    if (!asset) throw new ProviderError(ProviderFailure.NotFound, undefined, `Asset not found '${assetId}'`);
    const supply = asset.supply!;

    return {
      assetId,
      fingerprint,
      name: assetName,
      policyId,
      quantity: supply,
      supply
    };
  }

  async #getAssetsInfo(
    assetIds: Cardano.AssetId[],
    dataSource: DataSource
  ): Promise<Map<Cardano.AssetId, Asset.AssetInfo>> {
    const assetRepository = dataSource.getRepository(AssetEntity);
    const assets = await assetRepository.find({ where: { id: In(assetIds) } });

    return new Map(
      assets.map((asset) => {
        const { id, supply } = asset as Required<AssetEntity>;
        const name = Cardano.AssetId.getAssetName(id);
        const policyId = Cardano.AssetId.getPolicyId(id);
        const fingerprint = Cardano.AssetFingerprint.fromParts(policyId, Cardano.AssetName(name));

        return [
          id,
          {
            assetId: id,
            fingerprint,
            name,
            policyId,
            quantity: supply,
            supply
          }
        ];
      })
    );
  }

  async #getMultiNftMetadata(
    assetIds: Cardano.AssetId[],
    dataSource: DataSource
  ): Promise<Map<Cardano.AssetId, Asset.NftMetadata>> {
    const nftMetadataRepository = dataSource.getRepository(NftMetadataEntity);
    const assets = (await nftMetadataRepository.find({
      where: { userTokenAssetId: In(assetIds) }
    })) as Required<NftMetadataEntity>[];

    return new Map(
      assets.map((asset) => [
        asset.userTokenAssetId!,
        {
          image: asset.image!,
          name: asset.name!,
          ...(asset.description && { description: asset.description }),
          ...(asset.files && { files: asset.files }),
          ...(asset.mediaType && { mediaType: asset.mediaType as Asset.ImageMediaType }),
          ...(asset.otherProperties && { otherProperties: asset.otherProperties }),
          version: asset.otherProperties?.get('version') as string
        }
      ])
    );
  }

  async initializeImpl() {
    await super.initializeImpl();
    await this.#nftMetadataService.initialize();
  }

  async startImpl() {
    await super.startImpl();
    await this.#nftMetadataService.start();
  }

  async shutdownImpl() {
    await super.shutdownImpl();
    await this.#nftMetadataService.shutdown();
  }
}
