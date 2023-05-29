import { Cardano, ChainSyncEventType } from '@cardano-sdk/core';
import { STAKE_POOL_METRICS_UPDATE, StakePoolMetricsUpdateJob } from '../pgBoss';
import { WithPgBoss } from './withTypeormTransaction';
import { typeormOperator } from './util';

export const createStorePoolMetricsUpdateJob = (jobFrequency = 1000) => {
  // Remember the blockNo of last sent job in order to no resend another job in case of rollback
  let lastSentBlock: Cardano.BlockNo | undefined;
  let reachedTheTip = false;

  return typeormOperator<WithPgBoss>(async ({ eventType, pgBoss, block: { header }, tip }) => {
    let insertFirstJob = false;

    if (eventType === ChainSyncEventType.RollBackward) return;
    if (!reachedTheTip) insertFirstJob = reachedTheTip = tip.slot === header.slot;

    const { blockNo, slot } = header;

    if (insertFirstJob || (blockNo % jobFrequency === 0 && blockNo !== lastSentBlock && reachedTheTip)) {
      const task: StakePoolMetricsUpdateJob = { slot };

      lastSentBlock = blockNo;
      await pgBoss.send(STAKE_POOL_METRICS_UPDATE, task, { slot });
    }
  });
};
