import { Asset } from '../../Cardano';
import { NftMetadata } from '../../Asset';

export interface NftMetadataProvider {
  (asset: Asset): Promise<NftMetadata | undefined>;
}
