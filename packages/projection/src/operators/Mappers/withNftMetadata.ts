import { Asset, Cardano } from '@cardano-sdk/core';
import { isNotNil } from '@cardano-sdk/util';
import { map } from 'rxjs';
import uniqBy from 'lodash/uniqBy.js';
import type { Logger } from 'ts-log';
import type { ProjectionOperator } from '../../types.js';
import type { WithCIP67 } from './withCIP67.js';
import type { WithLogger } from '@cardano-sdk/util';
import type { WithMint } from './withMint.js';
import type { WithUtxo } from './withUtxo.js';

export interface ProjectedNftMetadata {
  userTokenAssetId: Cardano.AssetId;
  nftMetadata: Asset.NftMetadata;
  /** Only present on cip68 metadata */
  referenceTokenAssetId?: Cardano.AssetId;
  /** Only present on cip68 metadata */
  extra?: Cardano.PlutusData;
}

export interface WithNftMetadata {
  nftMetadata: ProjectedNftMetadata[];
}

const getNftMetadataFromCip67 = ({ cip67 }: WithCIP67, logger: Logger) =>
  (cip67.byLabel[Asset.AssetNameLabelNum.ReferenceNFT] || []).map(
    ({ decoded, assetId, policyId, utxo }): ProjectedNftMetadata | null => {
      const datum = utxo?.[1].datum;
      if (!datum || !Cardano.util.isConstrPlutusData(datum)) {
        return null;
      }
      const nftMetadata = Asset.NftMetadata.fromPlutusData(datum, logger);
      if (!nftMetadata) return null;
      const userTokenAssetName = Asset.AssetNameLabel.encode(decoded.content, Asset.AssetNameLabelNum.UserNFT);
      const userTokenAssetId = Cardano.AssetId.fromParts(policyId, userTokenAssetName);
      return { extra: datum.fields.items[2], nftMetadata, referenceTokenAssetId: assetId, userTokenAssetId };
    }
  );

const getNftMetadataFromCip25 = ({ mint }: WithMint, logger: Logger) =>
  mint.map(({ assetId, txMetadata, policyId, assetName, quantity }): ProjectedNftMetadata | null => {
    if (quantity < 1n) return null;
    const nftMetadata = Asset.NftMetadata.fromMetadatum({ name: assetName, policyId }, txMetadata, logger);

    if (!nftMetadata) return null;
    return { nftMetadata, userTokenAssetId: assetId };
  });

export const withNftMetadata =
  <PropsIn extends WithMint & WithUtxo & WithCIP67>({
    logger
  }: WithLogger): ProjectionOperator<PropsIn, WithNftMetadata> =>
  (evt$) =>
    evt$.pipe(
      map((evt) => {
        const nftMetadata = uniqBy(
          [...getNftMetadataFromCip25(evt, logger), ...getNftMetadataFromCip67(evt, logger)].reverse().filter(isNotNil),
          ({ userTokenAssetId }) => userTokenAssetId
        );
        return { ...evt, nftMetadata };
      })
    );
