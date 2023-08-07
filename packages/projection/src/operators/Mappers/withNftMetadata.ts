import { Asset, Cardano } from '@cardano-sdk/core';
import { Logger } from 'ts-log';
import { ProjectionOperator } from '../../types';
import { WithCIP67 } from './withCIP67';
import { WithLogger, isNotNil } from '@cardano-sdk/util';
import { WithMint } from './withMint';
import { WithUtxo } from './withUtxo';
import { map } from 'rxjs';
import uniqBy from 'lodash/uniqBy';

export interface ProjectedNftMetadata {
  userTokenAssetId: Cardano.AssetId;
  referenceTokenAssetId?: Cardano.AssetId;
  nftMetadata: Asset.NftMetadata;
}

export interface WithNftMetadata {
  nftMetadata: ProjectedNftMetadata[];
}

const getNftMetadataFromCip67 = ({ cip67 }: WithCIP67, logger: Logger) =>
  (cip67.byLabel[Asset.AssetNameLabelNum.ReferenceNFT] || []).map(
    ({ decoded, assetId, policyId, utxo: [_, { datum }] }): ProjectedNftMetadata | null => {
      const nftMetadata = Asset.NftMetadata.fromPlutusData(datum, logger);
      if (!nftMetadata) return null;
      const userTokenAssetName = Asset.AssetNameLabel.encode(decoded.content, Asset.AssetNameLabelNum.UserNFT);
      const userTokenAssetId = Cardano.AssetId.fromParts(policyId, userTokenAssetName);
      return { nftMetadata, referenceTokenAssetId: assetId, userTokenAssetId };
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
  ({ logger }: WithLogger): ProjectionOperator<WithMint & WithUtxo & WithCIP67, WithNftMetadata> =>
  (evt$) =>
    evt$.pipe(
      map((evt) => {
        const nftMetadata = uniqBy(
          [...getNftMetadataFromCip67(evt, logger), ...getNftMetadataFromCip25(evt, logger)].filter(isNotNil),
          ({ userTokenAssetId }) => userTokenAssetId
        );
        return { ...evt, nftMetadata };
      })
    );
