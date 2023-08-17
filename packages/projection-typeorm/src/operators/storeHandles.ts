import { AssetEntity, HandleEntity } from '../entity';
import { Cardano, ChainSyncEventType } from '@cardano-sdk/core';
import { Mappers } from '@cardano-sdk/projection';
import { QueryRunner } from 'typeorm';
import { WithMintedAssetSupplies } from './storeAssets';
import { typeormOperator } from './util';

type HandleWithTotalSupply = Mappers.HandleOwnership & { totalSupply: bigint };

type HandleEventParams = {
  handles: Array<HandleWithTotalSupply>;
  mint: Mappers.Mint[];
  queryRunner: QueryRunner;
  block: Cardano.Block;
};

const getOwner = async (
  queryRunner: QueryRunner,
  assetId: string
): Promise<{ cardanoAddress: Cardano.Address | null; hasDatum: boolean }> => {
  const rows = await queryRunner.manager
    .createQueryBuilder('tokens', 't')
    .innerJoinAndSelect('output', 'o', 'o.id = t.output_id')
    .select('address, o.datum')
    .distinct()
    .where('o.consumed_at_slot IS NULL')
    .andWhere('t.asset_id = :assetId', { assetId })
    .getRawMany();
  if (rows.length !== 1)
    return {
      cardanoAddress: null,
      hasDatum: false
    };
  return {
    cardanoAddress: rows[0].address,
    hasDatum: !!rows[0].datum
  };
};

const getSupply = async (queryRunner: QueryRunner, assetId: Cardano.AssetId) => {
  const asset = await queryRunner.manager
    .getRepository(AssetEntity)
    .findOne({ select: { supply: true }, where: { id: assetId } });
  if (!asset) return 0n;
  return asset.supply!;
};

const rollForward = async ({ handles, queryRunner }: HandleEventParams) => {
  const handleRepository = queryRunner.manager.getRepository(HandleEntity);

  for (const { assetId, handle, policyId, latestOwnerAddress, datum, totalSupply } of handles) {
    if (totalSupply === 1n) {
      // if !address then it's burning it, otherwise transferring
      const { cardanoAddress, hasDatum } = latestOwnerAddress
        ? { cardanoAddress: latestOwnerAddress, hasDatum: !!datum }
        : await getOwner(queryRunner, assetId);
      await handleRepository.upsert(
        {
          asset: assetId,
          cardanoAddress,
          handle,
          hasDatum,
          policyId
        },
        {
          conflictPaths: {
            handle: true
          }
        }
      );
    } else {
      // Handles must be non-fungible, so while we cannot stop the double mint or treat it as an error, we can invalidate the previous address.
      await handleRepository.update({ handle }, { cardanoAddress: null });
    }
  }
};

const rollBackward = async ({ handles, queryRunner }: HandleEventParams) => {
  const handleRepository = queryRunner.manager.getRepository(HandleEntity);
  for (const { assetId, handle, totalSupply } of handles) {
    const newOwnerAddressAndDatum =
      totalSupply === 1n ? await getOwner(queryRunner, assetId) : { cardanoAddress: null, hasDatum: false };
    await handleRepository.update({ handle }, newOwnerAddressAndDatum);
  }
};

const withTotalSupplies = (
  queryRunner: QueryRunner,
  handles: Mappers.HandleOwnership[],
  mintedAssetTotalSupplies: WithMintedAssetSupplies['mintedAssetTotalSupplies']
): Promise<HandleWithTotalSupply[]> =>
  Promise.all(
    handles.map(
      async (handle): Promise<HandleWithTotalSupply> => ({
        ...handle,
        totalSupply: mintedAssetTotalSupplies[handle.assetId] || (await getSupply(queryRunner, handle.assetId))
      })
    )
  );

export const storeHandles = typeormOperator<Mappers.WithHandles & Mappers.WithMint & WithMintedAssetSupplies>(
  async ({ mint, handles, queryRunner, eventType, block, mintedAssetTotalSupplies }) => {
    const handleEventParams: HandleEventParams = {
      block,
      handles: await withTotalSupplies(queryRunner, handles, mintedAssetTotalSupplies),
      mint,
      queryRunner
    };

    try {
      eventType === ChainSyncEventType.RollForward
        ? await rollForward(handleEventParams)
        : await rollBackward(handleEventParams);
    } catch (error) {
      throw new Error((error as Error).message);
    }
  }
);
