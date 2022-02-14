import { AssetInfo, NftMetadata } from '../../Asset';

export interface NftMetadataProvider {
  (asset: AssetInfo): Promise<NftMetadata | undefined>;
}
