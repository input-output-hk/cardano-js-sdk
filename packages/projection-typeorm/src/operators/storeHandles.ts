import { ChainSyncEventType } from '@cardano-sdk/core';
import { HandleEntity } from '../entity';
import { In } from 'typeorm';
import { Mappers } from '@cardano-sdk/projection';
import { typeormOperator } from './util';

export const storeHandles = typeormOperator<Mappers.WithHandles & Mappers.WithMint>(
  async ({ mint, handles, queryRunner, eventType }) => {
    try {
      if (handles.length === 0) return;

      const handleRepository = queryRunner.manager.getRepository(HandleEntity);
      const existingHandles = await handleRepository.find({
        select: { handle: true },
        where: { handle: In(handles.map((handle) => handle.handle)) }
      });
      const existingHandlesSet = new Set(existingHandles.map(({ handle }) => handle));

      if (eventType === ChainSyncEventType.RollForward) {
        for (const { assetId } of mint) {
          if (assetId) {
            await Promise.all(
              handles.map(({ handle, address, assetId: _assetId }) =>
                existingHandlesSet.has(handle)
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
        await Promise.all(handles.map(({ handle }) => handleRepository.delete({ handle })));
      }
    } catch (error) {
      throw new Error((error as Error).message);
    }
  }
);
