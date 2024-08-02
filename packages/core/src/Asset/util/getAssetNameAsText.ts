import { AssetId } from '../../Cardano/types/Asset';
import { AssetNameLabel } from '../cip67';

export const getAssetNameAsText = (id: AssetId) => {
  const assetName = AssetId.getAssetName(id);
  const assetNameContent = AssetNameLabel.decode(assetName)?.content;
  return Buffer.from(assetNameContent || assetName, 'hex').toString('utf8');
};
