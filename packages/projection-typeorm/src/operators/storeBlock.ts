import { BlockEntity } from '../entity';
import { ChainSyncEventType } from '@cardano-sdk/projection';
import { typeormOperator } from './util';

export const storeBlock = typeormOperator(async (evt) => {
  const repository = evt.queryRunner.manager.getRepository(BlockEntity);
  if (evt.eventType === ChainSyncEventType.RollForward) {
    const blockEntity = repository.create({
      hash: evt.block.header.hash,
      height: evt.block.header.blockNo,
      slot: evt.block.header.slot
    });
    await repository.insert(blockEntity);
  } else {
    await repository.delete({
      slot: evt.block.header.slot
    });
  }
});
