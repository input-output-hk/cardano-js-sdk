import { ChainSyncEventType } from '@cardano-sdk/core';
import { HandleEntity } from '../entity';
import { In } from 'typeorm';
import { Mappers } from '@cardano-sdk/projection';
import { typeormOperator } from './util';

export const storeHandles = typeormOperator<Mappers.WithHandles & Mappers.WithMint>(
  async ({ mint: _mint, handles: _handles, queryRunner, eventType }) => {
    const handleRepository = queryRunner.manager.getRepository(HandleEntity);
    if (eventType === ChainSyncEventType.RollForward) {
      for (const { assetId, quantity } of _mint) {
        if (assetId) {
          const existingHandles = await handleRepository.find({
            select: { address: true, handle: true },
            where: { handle: In(_handles.map(({ handle }) => handle)) }
          });

          if (quantity > 1) {
            await Promise.all(
              existingHandles.map(({ handle }) => handleRepository.update({ handle }, { address: null }))
            );
          }
        }
      }
    } else {
      await Promise.all(_handles.map(({ handle }) => handleRepository.delete({ handle })));
    }

    // TODO: upsert the HandleEntity
    // check mint property: if this asset id is minted, then we need to query asset table
    // to check the supply quantity and set the handle address to null if >1
    // if asset is burned, we also need to check if maybe there's only 1 token of the handle remaining, then set it in handles table
    // Also, revert those operations when evt.type === ChainSyncEventType.RollBackwards
  }
);
