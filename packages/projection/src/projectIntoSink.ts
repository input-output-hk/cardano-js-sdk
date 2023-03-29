/* eslint-disable jsdoc/valid-types */
/* eslint-disable @typescript-eslint/no-explicit-any */
import { Cardano, ChainSyncEventType, PointOrOrigin, TipOrOrigin } from '@cardano-sdk/core';
import { Logger } from 'ts-log';
import { NoExtraProperties, contextLogger } from '@cardano-sdk/util';
import { Observable, finalize, tap } from 'rxjs';
import { ProjectionSource } from './bootstrap';
import { ProjectionsEvent } from './projections';
import { Sink } from './sinks';
import { UnifiedProjectorEvent } from './types';
import { applyProjections } from './applyProjections';

export interface ProjectIntoSinkProps<S extends {}, P extends Partial<S>> {
  projections: NoExtraProperties<S, P>;
  sink: Sink<S>;
  source$: ProjectionSource;
  logger: Logger;
}
const pointDescription = (point: PointOrOrigin) =>
  point === 'origin' ? 'origin' : `slot ${point.slot}, block ${point.hash}`;

const isAtTheTipOrHigher = (header: Cardano.PartialBlockHeader, tip: TipOrOrigin) => {
  if (tip === 'origin') return false;
  return header.blockNo >= tip.blockNo;
};

const logEvent =
  <T extends UnifiedProjectorEvent<{}>>(logger: Logger) =>
  (evt$: Observable<T>) => {
    let numEvt = 0;
    const logFrequency = 1000;
    const startedAt = Date.now();
    let lastLogAt = startedAt;
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
      })
    );
  };

export const projectIntoSink = <S extends {}, P extends Partial<S>>({
  source$,
  logger: baseLogger,
  projections,
  sink
}: ProjectIntoSinkProps<S, P>): Observable<ProjectionsEvent<P>> => {
  const logger = contextLogger(baseLogger, 'Projector');
  return source$.pipe(
    applyProjections(projections),
    sink(projections),
    logEvent(logger),
    tap((evt) => evt.requestNext()),
    finalize(() => logger.info('Stopped'))
  );
};
