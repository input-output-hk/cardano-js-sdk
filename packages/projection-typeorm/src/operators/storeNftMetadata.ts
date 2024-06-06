import { Asset, Cardano, ChainSyncEventType } from '@cardano-sdk/core';
import { AssetEntity, NftMetadataEntity, NftMetadataType } from '../entity/index.js';
import { typeormOperator } from './util.js';
import type { Mappers, ProjectionEvent } from '@cardano-sdk/projection';
import type { Repository } from 'typeorm';

const userTokenAssetIfExists = async (
  assetRepository: Repository<AssetEntity>,
  userTokenAssetId: Cardano.AssetId
): Promise<AssetEntity | undefined> => {
  if (await assetRepository.exist({ where: { id: userTokenAssetId } })) {
    return { id: userTokenAssetId };
  }
};

const toNftMetadataEntity =
  (slot: Cardano.Slot, assetRepository: Repository<AssetEntity>) =>
  async ({
    userTokenAssetId,
    referenceTokenAssetId,
    nftMetadata: metadata
  }: Mappers.ProjectedNftMetadata): Promise<NftMetadataEntity> => ({
    ...metadata,
    createdAt: { slot },
    parentAsset: {
      // CIP-68 metadata is 'owned' by reference token
      id: referenceTokenAssetId || userTokenAssetId
    },
    type: referenceTokenAssetId ? NftMetadataType.CIP68 : NftMetadataType.CIP25,
    // CIP-68 user token asset might not exist yet
    userTokenAsset: referenceTokenAssetId
      ? await userTokenAssetIfExists(assetRepository, userTokenAssetId)
      : { id: userTokenAssetId }
  });

type StoreNftMetadataEvent = ProjectionEvent<Mappers.WithCIP67 & Mappers.WithMint & Mappers.WithNftMetadata>;

interface HandlerDependencies {
  nftMetadataRepository: Repository<NftMetadataEntity>;
  assetRepository: Repository<AssetEntity>;
}

const handleRollForwardEvent = async (
  {
    nftMetadata,
    cip67,
    block: {
      header: { slot }
    },
    mint
  }: StoreNftMetadataEvent,
  { nftMetadataRepository, assetRepository }: HandlerDependencies
) => {
  const nftMetadataEntities = await Promise.all(nftMetadata.map(toNftMetadataEntity(slot, assetRepository)));
  const storedNftMetadata = await nftMetadataRepository.insert(nftMetadataEntities);
  // Perf: see if it's possible to build a single query that updates all assets
  for (const [i, { userTokenAsset }] of nftMetadataEntities.entries()) {
    if (userTokenAsset?.id) {
      await assetRepository.update(userTokenAsset!.id!, {
        nftMetadata: storedNftMetadata.identifiers[i]
      });
    }
  }

  // Associate NftMetadata with newly minted corresponding user token
  for (const { policyId, decoded, assetId } of cip67.byLabel[Asset.AssetNameLabelNum.UserNFT] || []) {
    const referenceAssetName = Asset.AssetNameLabel.encode(decoded.content, Asset.AssetNameLabelNum.ReferenceNFT);
    const referenceNftAssetId = Cardano.AssetId.fromParts(policyId, referenceAssetName);
    if (
      mint.some((minted) => minted.assetId === assetId) &&
      // If it was minted at this block, then it's already associated when inserting NftMetadata
      !mint.some((minted) => minted.assetId === referenceNftAssetId)
    ) {
      const nftMetadatasToAssociate = await nftMetadataRepository.find({
        select: { id: true },
        where: { parentAsset: { id: referenceNftAssetId } }
      });
      if (nftMetadatasToAssociate.length > 0) {
        const nftMetadataIds = nftMetadatasToAssociate.map(({ id }) => id!);
        await Promise.all([
          nftMetadataRepository.update(nftMetadataIds, { userTokenAsset: { id: assetId } }),
          assetRepository.update({ id: assetId }, { nftMetadata: { id: Math.max(...nftMetadataIds) } })
        ]);
      }
    }
  }
};

const handleRollBackwardEvent = async (
  { nftMetadata }: StoreNftMetadataEvent,
  { nftMetadataRepository, assetRepository }: HandlerDependencies
) => {
  for (const { userTokenAssetId } of nftMetadata) {
    // Switch back to metadata that was active before the rolled back block
    const remainingMetadata = await nftMetadataRepository.find({
      order: { id: 'DESC' },
      select: { id: true },
      take: 1,
      where: { userTokenAsset: { id: userTokenAssetId } }
    });
    await assetRepository.update(userTokenAssetId, {
      nftMetadata: remainingMetadata.length > 0 ? { id: remainingMetadata[0].id } : null
    });
  }
};

export const willStoreNftMetadata = ({ nftMetadata, cip67 }: Mappers.WithCIP67 & Mappers.WithNftMetadata) =>
  nftMetadata.length > 0 || Object.keys(cip67.byLabel).length > 0;

export const storeNftMetadata = typeormOperator<Mappers.WithCIP67 & Mappers.WithMint & Mappers.WithNftMetadata>(
  async (evt) => {
    const nftMetadataRepository = evt.queryRunner.manager.getRepository(NftMetadataEntity);
    const assetRepository = evt.queryRunner.manager.getRepository(AssetEntity);

    await (evt.eventType === ChainSyncEventType.RollForward
      ? handleRollForwardEvent(evt, { assetRepository, nftMetadataRepository })
      : handleRollBackwardEvent(evt, { assetRepository, nftMetadataRepository }));
  }
);
