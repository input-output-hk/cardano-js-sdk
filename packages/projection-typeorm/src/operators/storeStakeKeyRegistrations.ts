import { ChainSyncEventType, Mappers } from '@cardano-sdk/projection';
import { StakeKeyRegistrationEntity } from '../entity';
import { certificatePointerToId, typeormOperator } from './util';

export const willStoreStakeKeyRegistrations = ({ stakeKeyRegistrations }: Mappers.WithStakeKeyRegistrations) =>
  stakeKeyRegistrations.length > 0;

export const storeStakeKeyRegistrations = typeormOperator<Mappers.WithStakeKeyRegistrations>(
  async ({ eventType, queryRunner, block, stakeKeyRegistrations }) => {
    // Deleted by db with ON DELETE CASCADE
    if (eventType !== ChainSyncEventType.RollForward || stakeKeyRegistrations.length === 0) return;
    const stakeKeyRegistrationsRepo = queryRunner.manager.getRepository(StakeKeyRegistrationEntity);
    await stakeKeyRegistrationsRepo.insert(
      stakeKeyRegistrations.map(
        (reg): StakeKeyRegistrationEntity => ({
          block: {
            slot: block.header.slot
          },
          id: certificatePointerToId(reg.pointer),
          stakeKeyHash: reg.stakeKeyHash
        })
      )
    );
  }
);
