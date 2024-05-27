import {
  Asset,
  AssetProvider,
  Cardano,
  GetAssetArgs,
  GetAssetsArgs,
  ProviderError,
  ProviderFailure
} from '@cardano-sdk/core';
import { AssetEntity } from '@cardano-sdk/projection-typeorm';
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
    const assetInfo = await this.#getAssetInfo(assetId);

    if (extraData?.nftMetadata) assetInfo.nftMetadata = await this.#getNftMetadata(assetInfo);
    if (extraData?.tokenMetadata) {
      assetInfo.tokenMetadata = (await this.#fetchTokenMetadataList([assetId]))[0];
    }

    return assetInfo;
  }

  async getAssets({ assetIds, extraData }: GetAssetsArgs): Promise<Asset.AssetInfo[]> {
    if (assetIds.length > this.#paginationPageSizeLimit) {
      throw new ProviderError(
        ProviderFailure.BadRequest,
        undefined,
        `AssetIds count of ${assetIds.length} can not be greater than ${this.#paginationPageSizeLimit}`
      );
    }

    const assetInfoList = await Promise.all(assetIds.map((assetId) => this.#getAssetInfo(assetId)));

    if (extraData?.nftMetadata) {
      await Promise.all(
        assetInfoList.map(async (assetInfo) => {
          assetInfo.nftMetadata = await this.#getNftMetadata(assetInfo);
        })
      );
    }

    if (extraData?.tokenMetadata) {
      const tokenMetadataList = await this.#fetchTokenMetadataList(assetIds);

      for (const [index, assetInfo] of assetInfoList.entries()) {
        assetInfo.tokenMetadata = tokenMetadataList[index];
      }
    }

    return assetInfoList;
  }

  async #fetchTokenMetadataList(assetIds: Cardano.AssetId[]) {
    let tokenMetadataList: (Asset.TokenMetadata | null | undefined)[] = [];

    try {
      tokenMetadataList = await this.#dependencies.tokenMetadataService.getTokenMetadata(assetIds);
    } catch (error) {
      if (error instanceof ProviderError && error.reason === ProviderFailure.Unhealthy) {
        this.logger.error(`Failed to fetch token metadata for assets ${assetIds} due to: ${error.message}`);
        tokenMetadataList = Array.from({ length: assetIds.length });
      } else {
        throw error;
      }
    }

    return tokenMetadataList;
  }

  async #getNftMetadata(asset: Asset.AssetInfo): Promise<Asset.NftMetadata | null | undefined> {
    try {
      return this.#nftMetadataService.getNftMetadata({
        name: asset.name,
        policyId: asset.policyId
      });
    } catch (error) {
      this.logger.error('Failed to get nft metadata', asset.assetId, error);
    }
  }

  async #getAssetInfo(assetId: Cardano.AssetId): Promise<Asset.AssetInfo> {
    const assetName = Cardano.AssetId.getAssetName(assetId);
    const policyId = Cardano.AssetId.getPolicyId(assetId);
    const fingerprint = Cardano.AssetFingerprint.fromParts(policyId, Cardano.AssetName(assetName));

    return this.withDataSource(async (dataSource) => {
      const queryRunner = dataSource.createQueryRunner();
      let supply: bigint;
      try {
        const assetRepository = queryRunner.manager.getRepository(AssetEntity);
        const asset = await assetRepository.findOneBy({ id: assetId });
        if (!asset) throw new ProviderError(ProviderFailure.NotFound, undefined, `Asset not found '${assetId}'`);
        supply = asset.supply!;
      } finally {
        await queryRunner.release();
      }

      return {
        assetId,
        fingerprint,
        name: assetName,
        policyId,
        quantity: supply,
        supply
      };
    });
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
