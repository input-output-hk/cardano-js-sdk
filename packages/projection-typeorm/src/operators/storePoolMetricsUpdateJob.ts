import { Cardano, ChainSyncEventType } from '@cardano-sdk/core';
import { STAKE_POOL_METRICS_UPDATE } from '../pgBoss';
import { WithPgBoss } from './withTypeormTransaction';
import { typeormOperator } from './util';

export const createStorePoolMetricsUpdateJob = (jobFrequency = 1000, jobOutdatedFrequency?: number) => {
  // Remember the blockNo of last sent job in order to no resend another job in case of rollback
  let lastSentBlock: Cardano.BlockNo | undefined;
  // Metrics updated before this slot is considered outdated
  let outdatedSlot: Cardano.Slot;
  let reachedTheTip = false;

  return typeormOperator<WithPgBoss>(async ({ eventType, pgBoss, block: { header }, tip }) => {
    let insertFirstJob = false;

    if (eventType === ChainSyncEventType.RollBackward) return;
    if (!reachedTheTip) insertFirstJob = reachedTheTip = tip.slot === header.slot;

    const { blockNo, slot } = header;

    const sendForAll = async () => {
      // run the update for all pools
      lastSentBlock = blockNo;
      outdatedSlot = slot;
      await pgBoss.send(STAKE_POOL_METRICS_UPDATE, { slot }, { slot });
    };

    const sendForOutdated = async () => {
      // run the update for only pools with outdated metrics
      lastSentBlock = blockNo;
      await pgBoss.send(STAKE_POOL_METRICS_UPDATE, { outdatedSlot, slot }, { slot });
    };

    if (insertFirstJob) {
      await sendForAll();
    } else if (blockNo !== lastSentBlock && reachedTheTip) {
      if (blockNo % jobFrequency === 0) {
        await sendForAll();
      } else if (jobOutdatedFrequency && outdatedSlot && blockNo % jobOutdatedFrequency === 0) {
        await sendForOutdated();
      }
    }
  });
};
