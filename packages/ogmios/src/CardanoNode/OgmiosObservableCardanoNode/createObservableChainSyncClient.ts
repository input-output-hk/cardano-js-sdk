import { CardanoNodeErrors, ChainSyncEventType } from '@cardano-sdk/core';
import { Observable, from, switchMap } from 'rxjs';
import { block as blockToCore } from '../../ogmiosToCore/index.js';
import { findIntersect, requestNext as sendRequestNext } from '@cardano-ogmios/client/dist/ChainSync';
import { nanoid } from 'nanoid';
import { ogmiosToCorePointOrOrigin, ogmiosToCoreTip, ogmiosToCoreTipOrOrigin, pointOrOriginToOgmios } from './util.js';
import { safeJSON } from '@cardano-ogmios/client';
import { toSerializableObject } from '@cardano-sdk/util';
import type { ChainSyncEvent, PointOrOrigin, RequestNext } from '@cardano-sdk/core';
import type { InteractionContext, Schema } from '@cardano-ogmios/client';
import type { Logger } from 'ts-log';
import type { Subscriber } from 'rxjs';
import type { WithLogger } from '@cardano-sdk/util';

const RequestIdProp = 'requestId';

export interface ObservableChainSyncClientProps {
  intersectionPoint: PointOrOrigin;
}

export interface WithObservableInteractionContext {
  interactionContext$: Observable<InteractionContext>;
}

const mapBlock = (block: Schema.Block, logger: Logger) => {
  try {
    return blockToCore(block);
  } catch (error) {
    logger.error('Failed to map block:', JSON.stringify(toSerializableObject(block)));
    throw error;
  }
};

const notifySubscriberAndParseNewCursor = (
  response: Schema.Ogmios['RequestNextResponse'],
  subscriber: Subscriber<ChainSyncEvent>,
  requestNext: RequestNext,
  logger: Logger
): PointOrOrigin | undefined => {
  if ('RollBackward' in response.result) {
    const point = ogmiosToCorePointOrOrigin(response.result.RollBackward.point);
    subscriber.next({
      eventType: ChainSyncEventType.RollBackward,
      point,
      requestNext,
      tip: ogmiosToCoreTipOrOrigin(response.result.RollBackward.tip)
    });
    return point;
  } else if ('RollForward' in response.result) {
    if (response.result.RollForward.tip === 'origin') {
      subscriber.error(new Error('Bug: "tip" at RollForward is "origin"'));
      return;
    }
    const coreBlock = mapBlock(response.result.RollForward.block, logger);
    if (!coreBlock) {
      // Assuming it's an EBB
      requestNext();
      return;
    }
    subscriber.next({
      block: coreBlock,
      eventType: ChainSyncEventType.RollForward,
      requestNext,
      tip: ogmiosToCoreTip(response.result.RollForward.tip)
    });
    return {
      hash: coreBlock.header.hash,
      slot: coreBlock.header.slot
    };
  }
  subscriber.error(new CardanoNodeErrors.CardanoClientErrors.UnknownResultError(response.result));
};

export const createObservableChainSyncClient = (
  { intersectionPoint }: ObservableChainSyncClientProps,
  { interactionContext$, logger }: WithObservableInteractionContext & WithLogger
): Observable<ChainSyncEvent> => {
  let cursor = intersectionPoint;
  return interactionContext$.pipe(
    // set cursor for each connection
    switchMap((context) => from(findIntersect(context, [pointOrOriginToOgmios(cursor)]).then(() => context))),
    switchMap(
      (context) =>
        new Observable<ChainSyncEvent>((subscriber) => {
          let requestId: string;
          const requestNext = () => {
            requestId = nanoid(5);
            sendRequestNext(context.socket, {
              mirror: {
                [RequestIdProp]: requestId
              }
            });
          };
          const handler = (message: string) => {
            const response: Schema.Ogmios['RequestNextResponse'] = safeJSON.parse(message);
            if (response.methodname === 'RequestNext') {
              if (response.reflection?.[RequestIdProp] !== requestId) {
                return;
              }
              cursor = notifySubscriberAndParseNewCursor(response, subscriber, requestNext, logger) || cursor;
            }
          };
          context.socket.on('message', handler);
          requestNext();
          return () => {
            context.socket.off('message', handler);
          };
        })
    )
  );
};
