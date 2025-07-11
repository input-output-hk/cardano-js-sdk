import { Asset, AssetProvider, Cardano, GetAssetArgs, GetAssetsArgs } from '@cardano-sdk/core';
import { BlockfrostClient } from '../blockfrost/BlockfrostClient';
import { BlockfrostProvider } from '../blockfrost/BlockfrostProvider';
import { Logger } from 'ts-log';
import { isNotNil } from '@cardano-sdk/util';
import omit from 'lodash/omit.js';
import type { Responses } from '@blockfrost/blockfrost-js';

export class BlockfrostAssetProvider extends BlockfrostProvider implements AssetProvider {
  constructor(client: BlockfrostClient, logger: Logger) {
    super(client, logger);
  }

  private mapNftMetadata(asset: Responses['asset']): Asset.NftMetadata | null {
    const image = this.metadatumToString(
      (asset.onchain_metadata?.image as string | string[] | undefined) || asset.metadata?.logo
    );
    const name = (asset.onchain_metadata?.name as string | undefined) || asset.metadata?.name;
    if (!image || !name) return null;
    try {
      return {
        description: this.metadatumToString(
          (asset.onchain_metadata?.description as string | string[] | undefined) || asset.metadata?.description
        ),
        files: Array.isArray(asset.onchain_metadata?.files)
          ? asset
              .onchain_metadata!.files.map((file): Asset.NftMetadataFile | null => {
                const mediaType = file.mediaType as string | undefined;
                const fileName = file.name as string | undefined;
                const src = this.metadatumToString(file.src as string | string[] | undefined);
                if (!src || !mediaType) return null;
                try {
                  return {
                    mediaType: Asset.MediaType(mediaType),
                    name: fileName,
                    otherProperties: this.mapFileMetadataOtherProperties(file),
                    src: Asset.Uri(src)
                  };
                } catch (error) {
                  this.logger.warn('Failed to parse onchain_metadata file', file, error);
                  return null;
                }
              })
              .filter(isNotNil)
          : undefined,
        image: Asset.Uri(image),
        mediaType: asset.onchain_metadata?.mediaType
          ? Asset.ImageMediaType(asset.onchain_metadata.mediaType as string)
          : undefined,
        name,
        otherProperties: this.mapNftMetadataOtherProperties(asset.onchain_metadata),
        version: this.mapNftMetadataVersion(asset.onchain_metadata)
      };
    } catch (error) {
      this.logger.warn('Failed to parse nft metadata', asset, error);
      return null;
    }
  }

  private asString = (metadatum: unknown) => (typeof metadatum === 'string' ? metadatum : undefined);

  private metadatumToString(metadatum: Cardano.Metadatum | undefined | null): string | undefined {
    let stringMetadatum: string | undefined;
    if (Array.isArray(metadatum)) {
      const result = metadatum.map((metadata) => this.asString(metadata)).filter(isNotNil);
      stringMetadatum = result.join('');
    } else {
      stringMetadatum = this.asString(metadatum);
    }

    return stringMetadatum;
  }

  private objToMetadatum(obj: unknown): Cardano.Metadatum {
    if (typeof obj === 'string') return obj;
    if (typeof obj === 'number') return BigInt(obj);
    if (typeof obj === 'object') {
      if (obj === null) return '';
      if (Array.isArray(obj)) {
        return obj.map((item) => this.objToMetadatum(item));
      }
      return new Map(Object.entries(obj).map(([key, value]) => [key, this.objToMetadatum(value)]));
    }
    return '';
  }

  private mapNftMetadataVersion(metadata: Responses['asset']['onchain_metadata']) {
    return typeof metadata?.version === 'string' ? metadata.version : '1.0';
  }

  private mapFileMetadataOtherProperties(
    metadata: Responses['asset']['onchain_metadata']
  ): Map<string, Cardano.Metadatum> | undefined {
    return this.mapOtherProperties(metadata, ['name', 'mediaType', 'src']);
  }

  private mapNftMetadataOtherProperties(
    metadata: Responses['asset']['onchain_metadata']
  ): Map<string, Cardano.Metadatum> | undefined {
    return this.mapOtherProperties(metadata, ['name', 'image', 'description', 'mediaType', 'files', 'version']);
  }

  private mapOtherProperties(
    metadata: Responses['asset']['onchain_metadata'],
    mainProperties: string[]
  ): Map<string, Cardano.Metadatum> | undefined {
    if (!metadata) {
      return;
    }
    const otherProperties = Object.entries(omit(metadata, mainProperties));
    if (otherProperties.length === 0) return;
    // eslint-disable-next-line consistent-return
    return new Map(otherProperties.map(([key, value]) => [key, this.objToMetadatum(value)]));
  }

  private mapTokenMetadata(assetId: Cardano.AssetId, asset: Responses['asset']): Asset.TokenMetadata {
    return {
      assetId,
      decimals:
        (typeof asset.onchain_metadata?.decimals === 'number'
          ? asset.onchain_metadata.decimals
          : asset.metadata?.decimals) || undefined,
      desc: this.metadatumToString(
        (asset.onchain_metadata?.description as string | string[] | undefined) || asset.metadata?.description
      ),
      icon: this.metadatumToString(
        (asset.onchain_metadata?.image as string | string[] | undefined) || asset.metadata?.logo
      ),
      name: (asset.onchain_metadata?.name as string | undefined) || asset.metadata?.name,
      ticker: (asset.onchain_metadata?.ticker as string | undefined) || asset.metadata?.ticker || undefined,
      url: (asset.onchain_metadata?.url as string | undefined) || asset.metadata?.url || undefined,
      version: '1.0'
    };
  }

  async getAsset({ assetId, extraData }: GetAssetArgs): Promise<Asset.AssetInfo> {
    try {
      const response = await this.request<Responses['asset']>(`assets/${assetId.toString()}`);
      const name = Cardano.AssetId.getAssetName(assetId);
      const policyId = Cardano.PolicyId(response.policy_id);
      const quantity = BigInt(response.quantity);
      return {
        assetId,
        fingerprint: Cardano.AssetFingerprint(response.fingerprint),
        name,
        nftMetadata: extraData?.nftMetadata ? this.mapNftMetadata(response) : null,
        policyId,
        quantity,
        supply: quantity,
        tokenMetadata: extraData?.tokenMetadata ? this.mapTokenMetadata(assetId, response) : null
      };
    } catch (error) {
      this.logger.error('getAsset failed', assetId, extraData);
      throw this.toProviderError(error);
    }
  }

  getAssets({ assetIds, extraData }: GetAssetsArgs): Promise<Asset.AssetInfo[]> {
    return Promise.all(assetIds.map((assetId) => this.getAsset({ assetId, extraData })));
  }
}
