import { ChainSyncEventType } from '@cardano-sdk/core';
import { HandleMetadataEntity } from '../entity/index.js';
import { typeormOperator } from './util.js';
import type { Mappers } from '@cardano-sdk/projection';
import type { WithStoredProducedUtxo } from './storeUtxo.js';

export const willStoreHandleMetadata = ({ handleMetadata }: Mappers.WithHandleMetadata) => handleMetadata.length > 0;

export const storeHandleMetadata = typeormOperator<Mappers.WithHandleMetadata & WithStoredProducedUtxo>(
  async ({
    eventType,
    queryRunner,
    handleMetadata,
    storedProducedUtxo,
    block: {
      header: { slot }
    }
  }) => {
    if (eventType === ChainSyncEventType.RollForward && handleMetadata.length > 0) {
      const handleRepository = queryRunner.manager.getRepository(HandleMetadataEntity);
      await handleRepository.insert(
        handleMetadata.map(
          ({ handle, backgroundImage, og, profilePicImage, txOut }): HandleMetadataEntity => ({
            backgroundImage,
            block: { slot },
            handle,
            og,
            output: txOut ? storedProducedUtxo.get(txOut) : undefined,
            profilePicImage
          })
        )
      );
    }
    // Deleted via BlockEntity relation cascade on RollBackward
  }
);
