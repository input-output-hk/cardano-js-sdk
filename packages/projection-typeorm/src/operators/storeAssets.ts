import { AssetEntity } from '../entity/Asset.entity';
import { Cardano, ChainSyncEventType } from '@cardano-sdk/core';
import { Mappers } from '@cardano-sdk/projection';
import { typeormOperator } from './util';

type MintedAssetSupplies = Partial<Record<Cardano.AssetId, bigint>>;
export type WithMintedAssetSupplies = {
  mintedAssetTotalSupplies: MintedAssetSupplies;
};

export const storeAssets = typeormOperator<Mappers.WithMint, WithMintedAssetSupplies>(
  // TODO: refactor
  // eslint-disable-next-line sonarjs/cognitive-complexity
  async ({ mint, block: { header }, eventType, queryRunner }) => {
    const repository = queryRunner.manager.getRepository(AssetEntity);
    const mintedAssetTotalSupplies: MintedAssetSupplies = {};
    if (eventType === ChainSyncEventType.RollForward) {
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
    } else {
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
    }
    return { mintedAssetTotalSupplies };
  }
);
