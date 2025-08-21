import { AssetFingerprint, AssetId } from '../Cardano/types/Asset';
import { promiseTimeout } from './promiseTimeout';
import type * as Cardano from '../Cardano';
import type { AssetInfo } from '../Asset';
import type { AssetProvider } from '../Provider';
import type { Logger } from 'ts-log';
import type { Milliseconds } from './time';

type TryGetAssetInfosProps = {
  assetIds: Cardano.AssetId[];
  assetProvider: Pick<AssetProvider, 'getAssets'>;
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
