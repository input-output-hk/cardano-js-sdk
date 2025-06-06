import { Cardano } from '@cardano-sdk/core';
import { ChainSyncEventType } from '@cardano-sdk/projection';
import { STAKE_POOL_REWARDS, defaultJobOptions } from '../pgBoss';
import { WithPgBoss } from './withTypeormTransaction';
import { typeormOperator } from './util';

export const willStoreStakePoolRewardsJob = ({
  crossEpochBoundary,
  epochNo
}: {
  crossEpochBoundary: boolean;
  epochNo: Cardano.EpochNo;
}) => crossEpochBoundary && epochNo !== 1;

export const storeStakePoolRewardsJob = typeormOperator<WithPgBoss>(
  async ({ block: { header }, crossEpochBoundary, epochNo, eventType, pgBoss }) => {
    const { slot } = header;

    if (eventType === ChainSyncEventType.RollForward && crossEpochBoundary) {
      if (epochNo === 1) return;

      epochNo = Cardano.EpochNo(epochNo - 2);

      await pgBoss.send(
        STAKE_POOL_REWARDS,
        { epochNo },
        { ...defaultJobOptions, expireInHours: 6, retryDelay: 30, singletonKey: epochNo.toString(), slot }
      );
    }
  }
);
