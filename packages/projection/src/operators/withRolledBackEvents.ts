import { ChainSyncEventType } from '@cardano-sdk/core';
import { CustomError } from 'ts-custom-error';
import { EMPTY, Observable, map, scan, toArray } from 'rxjs';
import { ProjectorOperator, RollBackwardEvent, RollForwardEvent } from '../types';
import { WithStabilityWindow } from './withStabilityWindow';
import { blockingWithLatestFrom } from '@cardano-sdk/util-rxjs';

export type WithRolledBackEvents<ExtraRollForwardProps = {}> = {
  /**
   * In reverse order of that they were applied
   */
  rolledBackEvents: RollForwardEvent<ExtraRollForwardProps>[];
};

type WithRolledBackEventsScan<TRollForwardEvent> = {
  eventCache?: TRollForwardEvent[];
  evt: TRollForwardEvent | (RollBackwardEvent & WithRolledBackEvents<TRollForwardEvent>);
};

export class InsufficientEventCacheError extends CustomError {}

const rollForward = <ExtraRollForwardProps extends WithStabilityWindow>(
  evt: RollForwardEvent<ExtraRollForwardProps>,
  eventCache: RollForwardEvent<ExtraRollForwardProps>[]
) => {
  // clear blocks that are past stability window
  const slotThreshold = evt.tip.slot - evt.stabilityWindowSlotsCount;
  while (eventCache.length > 0 && eventCache[0].block.header.slot < slotThreshold) eventCache.shift();
  // add current block to cache and return the event unchanged
  eventCache.push(evt);
  return { eventCache, evt };
};

const rollBackward = <ExtraRollForwardProps, ExtraRollBackwardProps>(
  evt: RollBackwardEvent<ExtraRollBackwardProps>,
  eventCache: RollForwardEvent<ExtraRollForwardProps>[]
) => {
  const rollbackTo = evt.tip;
  if (rollbackTo === 'origin') {
    return {
      eventCache: [],
      evt: {
        ...evt,
        rolledBackEvents: eventCache.reverse()
      }
    };
  }
  const rolledBackEvents = [] as RollForwardEvent<ExtraRollForwardProps>[];
  while (eventCache.length > 0 && eventCache[eventCache.length - 1].block.header.hash !== rollbackTo.hash)
    rolledBackEvents.push(eventCache.pop()!);
  if (
    rolledBackEvents.length > 0 &&
    rolledBackEvents.length < rolledBackEvents[0].block.header.blockNo - rollbackTo.blockNo
  ) {
    throw new InsufficientEventCacheError();
  }
  return { eventCache, evt: { ...evt, rolledBackEvents } };
};

/**
 * Adds `rolledBackEvents` to RollBackward events.
 * `rolledBackEvents` are in descending order (starting from tip going down to origin).
 *
 * @param evtCache$ observable that emits events up to first event emitted by source evt$ observable.
 * It is used to build cache of events to be used in case a rollback happens.
 * If syncing from origin, there's no need to pass it.
 * Otherwise, it should emit all events up to source start within stability window.
 */
export const withRolledBackEvents =
  <ExtraRollForwardPropsIn extends WithStabilityWindow, ExtraRollBackwardPropsIn>(
    evtCache$: Observable<RollForwardEvent<ExtraRollForwardPropsIn>> = EMPTY
  ): ProjectorOperator<
    ExtraRollForwardPropsIn,
    ExtraRollBackwardPropsIn,
    {},
    WithRolledBackEvents<RollForwardEvent<ExtraRollForwardPropsIn>>
  > =>
  (evt$) =>
    evt$.pipe(
      blockingWithLatestFrom(evtCache$.pipe(toArray())),
      scan(
        (
          { eventCache },
          [evt, initialEvtCache]
        ): WithRolledBackEventsScan<RollForwardEvent<ExtraRollForwardPropsIn>> => {
          eventCache ||= initialEvtCache;
          switch (evt.eventType) {
            case ChainSyncEventType.RollForward:
              return rollForward(evt, eventCache);
            case ChainSyncEventType.RollBackward:
              return rollBackward(evt, eventCache);
          }
        },
        {
          evt: {} as WithRolledBackEventsScan<RollForwardEvent<ExtraRollForwardPropsIn>>['evt']
        } as WithRolledBackEventsScan<RollForwardEvent<ExtraRollForwardPropsIn>>
      ),
      map(({ evt }) => evt)
    );
