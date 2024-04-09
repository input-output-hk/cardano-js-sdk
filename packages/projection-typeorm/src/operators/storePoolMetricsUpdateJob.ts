import { Cardano, ChainSyncEventType } from '@cardano-sdk/core';
import { STAKE_POOL_METRICS_UPDATE } from '../pgBoss';
import { WithPgBoss } from './withTypeormTransaction';
import { typeormOperator } from './util';

export const createStorePoolMetricsUpdateJob = (jobFrequency = 1000, jobOutdatedFrequency?: number) => {
  // Remember the blockNo of last sent job in order to no resend another job in case of rollback
  let lastAllSentBlock: Cardano.BlockNo | undefined;
  let lastOutdatedSentBlock: Cardano.BlockNo | undefined;
  // Metrics updated before this slot is considered outdated
  let outdatedSlot: Cardano.Slot;
  let reachedTheTip = false;

  // eslint-disable-next-line complexity
  return typeormOperator<WithPgBoss>(async ({ eventType, pgBoss, block: { header }, tip }) => {
    let insertFirstJob = false;

    if (eventType === ChainSyncEventType.RollBackward) return;
    if (!reachedTheTip) insertFirstJob = reachedTheTip = tip.slot === header.slot;

    const { blockNo, slot } = header;

    const sendForAll = async () => {
      // run the update for all pools
      lastAllSentBlock = blockNo;

      if (lastOutdatedSentBlock === undefined) lastOutdatedSentBlock = blockNo;

      outdatedSlot = slot;
      await pgBoss.send(STAKE_POOL_METRICS_UPDATE, { slot }, { slot });
    };

    const sendForOutdated = async () => {
      // run the update for only pools with outdated metrics
      lastOutdatedSentBlock = blockNo;
      await pgBoss.send(STAKE_POOL_METRICS_UPDATE, { outdatedSlot, slot }, { slot });
    };

    if (insertFirstJob) {
      await sendForAll();
    } else if ((blockNo !== lastAllSentBlock || blockNo !== lastOutdatedSentBlock) && reachedTheTip) {
      if (lastAllSentBlock && blockNo - lastAllSentBlock >= jobFrequency) {
        await sendForAll();
      } else if (
        jobOutdatedFrequency &&
        lastOutdatedSentBlock &&
        outdatedSlot &&
        blockNo - lastOutdatedSentBlock >= jobOutdatedFrequency
      ) {
        await sendForOutdated();
      }
    }
  });
};
