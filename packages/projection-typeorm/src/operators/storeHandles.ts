import { ChainSyncEventType } from '@cardano-sdk/core';
import { HandleEntity } from '../entity';
import { Mappers } from '@cardano-sdk/projection';
import { typeormOperator } from './util';

export const storeHandles = typeormOperator<Mappers.WithHandles & Mappers.WithMint>(
  async ({ mint: _mint, handles: _handles, queryRunner, eventType }) => {
    try {
      if (_handles.length === 0) return;

      const handleRepository = queryRunner.manager.getRepository(HandleEntity);
      const existingHandles = await handleRepository.find();
      const existingHandlesArr = new Set(existingHandles.map(({ handle }) => handle));

      if (eventType === ChainSyncEventType.RollForward) {
        for (const { assetId } of _mint) {
          if (assetId) {
            await Promise.all(
              _handles.map(({ handle, address, assetId: _assetId }) =>
                existingHandlesArr.has(handle)
                  ? handleRepository.update({ handle }, { address: null })
                  : handleRepository.insert({
                      address,
                      asset: _assetId,
                      handle
                    })
              )
            );
          }
        }
      } else {
        await Promise.all(_handles.map(({ handle }) => handleRepository.delete({ handle })));
      }
    } catch (error) {
      throw new Error((error as Error).message);
    }
  }
);
