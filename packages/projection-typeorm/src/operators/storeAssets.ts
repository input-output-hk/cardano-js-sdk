import { AssetEntity } from '../entity/Asset.entity';
import { ChainSyncEventType } from '@cardano-sdk/core';
import { Mappers } from '@cardano-sdk/projection';
import { typeormOperator } from './util';

export const storeAssets = typeormOperator<Mappers.WithMint>(
  async ({ mint, block: { header }, eventType, queryRunner }) => {
    const repository = queryRunner.manager.getRepository(AssetEntity);
    if (eventType === ChainSyncEventType.RollForward) {
      for (const { assetId, quantity } of mint) {
        const storedAsset = await repository.findOne({ select: { supply: true }, where: { id: assetId } });
        await (storedAsset
          ? repository.increment({ id: assetId }, 'supply', quantity.toString())
          : repository.insert({
              firstMintBlock: { slot: header.slot },
              id: assetId,
              supply: quantity
            }));
      }
    } else {
      for (const { assetId, quantity } of mint) {
        await repository.increment({ id: assetId }, 'supply', (-quantity).toString());
      }
    }
  }
);
