import { ChainSyncEventType } from '@cardano-sdk/core';
import { contextLogger } from '@cardano-sdk/util';
import { defer, finalize, tap } from 'rxjs';
import { pointDescription } from '../util.js';
import type { Cardano, TipOrOrigin } from '@cardano-sdk/core';
import type { Logger } from 'ts-log';
import type { Observable } from 'rxjs';
import type { UnifiedExtChainSyncEvent } from '../types.js';

const isAtTheTipOrHigher = (header: Cardano.PartialBlockHeader, tip: TipOrOrigin) => {
  if (tip === 'origin') return false;
  return header.blockNo >= tip.blockNo;
};

const intervals = [1000, 10_000, 100_000] as const;
type Intervals = (typeof intervals)[number];

const intervalsDesc = new Map<Intervals, string>([
  [1000, '1K'],
  [10_000, '10K'],
  [100_000, '100K']
]);

const logSyncLine = (params: {
  blocksTime: Map<number, number>;
  header: Cardano.PartialBlockHeader;
  logger: Logger;
  numEvt: number;
  startedAt: number;
  tip: Cardano.Tip;
}) => {
  const { blocksTime, header, logger, numEvt, startedAt, tip } = params;
  const syncPercentage = ((header.blockNo * 100) / tip.blockNo).toFixed(2);
  const now = Date.now();

  blocksTime.set(numEvt, now);

  const format = (desc: string, amount: number, since: number) => {
    const speed = amount / (now - since);
    return `${desc}: eta ${new Date(now + (tip.blockNo - header.blockNo) / speed)
      .toISOString()
      .replace(/\..*$/, '')} at ${Math.round(speed * 1000)} b/s`;
  };

  const speeds = [format('All', numEvt, startedAt)];

  for (const interval of intervals) {
    const prevTime = blocksTime.get(numEvt - interval);
    if (prevTime) speeds.push(format(intervalsDesc.get(interval)!, interval, prevTime));
  }

  logger.info(`Initializing ${syncPercentage}% at block #${header.blockNo} ${speeds.join(' - ')}`);

  const pruneOldTimes = (upTo: number) => {
    for (const block of blocksTime.keys())
      if (block <= upTo) blocksTime.delete(block);
      else return;
  };

  pruneOldTimes(numEvt - 100_000);
};

export const logProjectionProgress =
  <T extends Omit<UnifiedExtChainSyncEvent<{}>, 'requestNext'>>(baseLogger: Logger) =>
  (evt$: Observable<T>) =>
    defer(() => {
      const logger = contextLogger(baseLogger, 'Projector');
      let numEvt = 0;
      const blocksTime = new Map<number, number>();
      const logFrequency = 1000;
      const startedAt = Date.now();
      logger.info('Started');
      return evt$.pipe(
        tap(({ block: { header }, eventType, tip }) => {
          numEvt++;
          if (isAtTheTipOrHigher(header, tip)) {
            logger.info(
              `Processed event ${
                eventType === ChainSyncEventType.RollForward ? 'RollForward' : 'RollBackward'
              } ${pointDescription(header)}`
            );
          } else if (numEvt % logFrequency === 0 && tip !== 'origin')
            logSyncLine({ blocksTime, header, logger, numEvt, startedAt, tip });
        }),
        finalize(() => logger.info(`Stopped after ${Math.round((Date.now() - startedAt) / 1000)} s`))
      );
    });
