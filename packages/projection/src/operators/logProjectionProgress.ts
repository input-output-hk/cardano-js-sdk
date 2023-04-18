import { Cardano, ChainSyncEventType, TipOrOrigin } from '@cardano-sdk/core';
import { Logger } from 'ts-log';
import { Observable, defer, finalize, tap } from 'rxjs';
import { UnifiedExtChainSyncEvent } from '../types';
import { contextLogger } from '@cardano-sdk/util';
import { pointDescription } from '../util';

const isAtTheTipOrHigher = (header: Cardano.PartialBlockHeader, tip: TipOrOrigin) => {
  if (tip === 'origin') return false;
  return header.blockNo >= tip.blockNo;
};

export const logProjectionProgress =
  <T extends UnifiedExtChainSyncEvent<{}>>(baseLogger: Logger) =>
  (evt$: Observable<T>) =>
    defer(() => {
      const logger = contextLogger(baseLogger, 'Projector');
      let numEvt = 0;
      const logFrequency = 1000;
      const startedAt = Date.now();
      let lastLogAt = startedAt;
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
          } else if (numEvt % logFrequency === 0 && tip !== 'origin') {
            const syncPercentage = ((header.blockNo * 100) / tip.blockNo).toFixed(2);
            const now = Date.now();
            const currentSpeed = Math.round(logFrequency / ((now - lastLogAt) / 1000));
            lastLogAt = now;
            const overallSpeedPerMs = numEvt / (now - startedAt);
            const overallSpeed = Math.round(overallSpeedPerMs * 1000);
            const eta = new Date(now + (tip.blockNo - header.blockNo) / overallSpeedPerMs);
            logger.info(
              `Initializing ${syncPercentage}% at block #${
                header.blockNo
              }. Speed: ${currentSpeed}bps (avg ${overallSpeed}bps). ETA: ${eta.toISOString()}`
            );
          }
        }),
        finalize(() => logger.info('Stopped'))
      );
    });
