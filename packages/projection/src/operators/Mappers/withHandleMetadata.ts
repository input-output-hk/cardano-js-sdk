import { Asset, Cardano, Handle } from '@cardano-sdk/core';
import { CIP67Assets, WithCIP67 } from './withCIP67';
import { FilterByPolicyIds } from './types';
import { Logger } from 'ts-log';
import { ProducedUtxo } from './withUtxo';
import { ProjectedNftMetadata, WithNftMetadata } from './withNftMetadata';
import { ProjectionOperator } from '../../types';
import { assetNameToUTF8Handle } from './util';
import { isNotNil } from '@cardano-sdk/util';
import { map } from 'rxjs';

/** Only present for cip68/personalized handles */
interface PersonalizedProperties {
  profilePicImage?: Asset.Uri;
  backgroundImage?: Asset.Uri;
  txOut?: ProducedUtxo;
}

export interface HandleMetadata extends PersonalizedProperties {
  handle: Handle;
  og?: boolean;
}

export interface WithHandleMetadata {
  handleMetadata: HandleMetadata[];
}

const isOgHandle = (metadata: Asset.NftMetadata | undefined) => {
  if (!metadata) return false;
  const core = metadata.otherProperties?.get('core');
  // cip25 metadata has 'og' under 'core' map
  if (core instanceof Map) {
    return !!core.get('og');
  }
  // cip68 metadata has 'og' on root level
  return !!metadata.otherProperties?.get('og');
};

const toUri = (data: Cardano.PlutusData | undefined | string, logger: Logger) => {
  if (typeof data === 'string' && data.length > 0) {
    try {
      return Asset.Uri(data);
    } catch {
      logger.warn('Invalid uri', data);
    }
  }
};

const getPersonalizedProperties = (
  extra: Cardano.PlutusData | undefined,
  logger: Logger
): PersonalizedProperties | undefined => {
  if (!extra) return;
  if (!Cardano.util.isPlutusMap(extra)) {
    logger.warn('Cannot parse handle personalized properties: expected PlutusMap, got', extra);
    return;
  }
  const asRecord = Cardano.util.tryConvertPlutusMapToUtf8Record(extra, logger);
  return {
    backgroundImage: toUri(asRecord.bg_image, logger),
    profilePicImage: toUri(asRecord.pfp_image, logger)
  };
};

const getHandleMetadata = (
  allNftMetadata: ProjectedNftMetadata[],
  policyIds: Cardano.PolicyId[],
  cip67Assets: CIP67Assets,
  logger: Logger
): HandleMetadata[] =>
  allNftMetadata
    ?.filter(({ userTokenAssetId }) => policyIds.some((policyId) => userTokenAssetId.startsWith(policyId)))
    .map(({ nftMetadata, userTokenAssetId, referenceTokenAssetId, extra }): HandleMetadata | undefined => {
      const cip67Asset = referenceTokenAssetId && cip67Assets.byAssetId[referenceTokenAssetId];
      const handle = cip67Asset
        ? assetNameToUTF8Handle(cip67Asset!.decoded.content, logger)
        : assetNameToUTF8Handle(Cardano.AssetId.getAssetName(userTokenAssetId), logger);
      if (!handle) return;
      return {
        handle,
        og: isOgHandle(nftMetadata),
        ...getPersonalizedProperties(extra, logger),
        txOut: cip67Asset?.utxo
      };
    })
    .filter(isNotNil);

export const withHandleMetadata =
  <PropsIn extends WithNftMetadata & WithCIP67>(
    { policyIds }: FilterByPolicyIds,
    logger: Logger
  ): ProjectionOperator<PropsIn, WithHandleMetadata> =>
  (evt$) =>
    evt$.pipe(
      map((evt) => ({
        ...evt,
        handleMetadata: getHandleMetadata(evt.nftMetadata, policyIds, evt.cip67, logger)
      }))
    );
