import { AssetFingerprint, AssetId } from '../Cardano/types';
import { AssetInfo } from '../Asset';
import { AssetProvider } from '../Provider';
import { Logger } from 'ts-log';
import { Milliseconds } from './time';
import { promiseTimeout } from './promiseTimeout';

type TryGetAssetInfosProps = {
  assetIds: AssetId[];
  assetProvider: AssetProvider;
  timeout: Milliseconds;
  logger: Logger;
};

export const tryGetAssetInfos = async ({ assetIds, assetProvider, logger, timeout }: TryGetAssetInfosProps) => {
  try {
    return await promiseTimeout(
      assetProvider.getAssets({
        assetIds,
        extraData: { nftMetadata: true, tokenMetadata: true }
      }),
      timeout
    );
  } catch (error) {
    logger.error('Error: Failed to retrieve assets', error);

    return assetIds.map<AssetInfo>((assetId) => {
      const policyId = AssetId.getPolicyId(assetId);
      const name = AssetId.getAssetName(assetId);

      return {
        assetId,
        fingerprint: AssetFingerprint.fromParts(policyId, name),
        name,
        policyId,
        quantity: 0n,
        supply: 0n
      };
    });
  }
};
