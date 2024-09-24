import { AssetEntity } from '../entity';
import { Cardano } from '@cardano-sdk/core';
import { ChainSyncEventType, Mappers } from '@cardano-sdk/projection';
import { QueryRunner } from 'typeorm';
import { typeormOperator } from './util';

type MintedAssetSupplies = Partial<Record<Cardano.AssetId, bigint>>;
type StoreAssetEventParams = {
  mint: Mappers.Mint[];
  queryRunner: QueryRunner;
  header: Cardano.PartialBlockHeader;
};

export type WithMintedAssetSupplies = {
  mintedAssetTotalSupplies: MintedAssetSupplies;
};

const rollForward = async ({ mint, queryRunner, header }: StoreAssetEventParams): Promise<MintedAssetSupplies> => {
  const mintedAssetTotalSupplies: MintedAssetSupplies = {};
  const repository = queryRunner.manager.getRepository(AssetEntity);
  for (const { assetId, quantity } of mint) {
    const storedAsset = await repository.findOne({ select: { supply: true }, where: { id: assetId } });
    if (storedAsset) {
      const newSupply = storedAsset.supply! + quantity;
      await repository.update({ id: assetId }, { supply: newSupply });
      mintedAssetTotalSupplies[assetId] = newSupply;
    } else {
      await repository.insert({
        firstMintBlock: { slot: header.slot },
        id: assetId,
        supply: quantity
      });
      mintedAssetTotalSupplies[assetId] = quantity;
    }
  }
  return mintedAssetTotalSupplies;
};

const rollBackward = async ({ mint, queryRunner }: StoreAssetEventParams): Promise<MintedAssetSupplies> => {
  const mintedAssetTotalSupplies: MintedAssetSupplies = {};
  for (const { assetId, quantity } of mint) {
    const isPositiveQuantity = quantity > 0n;
    const absQuantity = isPositiveQuantity ? quantity : -1n * quantity;
    const queryResponse = await queryRunner.manager
      .createQueryBuilder(AssetEntity, 'asset')
      .update()
      .set({ supply: () => `supply ${isPositiveQuantity ? '-' : '+'} ${absQuantity}` })
      .where({ id: assetId })
      .returning(['supply'])
      .execute();
    mintedAssetTotalSupplies[assetId] = queryResponse.affected === 0 ? 0n : BigInt(queryResponse.raw[0].supply);
  }
  return mintedAssetTotalSupplies;
};

export const willStoreAssets = ({ mint }: Mappers.WithMint) => mint.length > 0;

export const storeAssets = typeormOperator<Mappers.WithMint, WithMintedAssetSupplies>(
  async ({ mint, block: { header }, eventType, queryRunner }) => {
    const storeAssetEventParams: StoreAssetEventParams = { header, mint, queryRunner };
    const mintedAssetTotalSupplies: MintedAssetSupplies =
      eventType === ChainSyncEventType.RollForward
        ? await rollForward(storeAssetEventParams)
        : await rollBackward(storeAssetEventParams);
    return { mintedAssetTotalSupplies };
  }
);
