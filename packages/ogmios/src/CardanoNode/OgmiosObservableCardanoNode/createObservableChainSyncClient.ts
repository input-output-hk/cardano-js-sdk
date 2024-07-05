import {
  ChainSyncEvent,
  ChainSyncEventType,
  GeneralCardanoNodeError,
  GeneralCardanoNodeErrorCode,
  PointOrOrigin,
  RequestNext
} from '@cardano-sdk/core';
import { ChainSynchronization, InteractionContext, Schema, safeJSON } from '@cardano-ogmios/client';
import { Logger } from 'ts-log';
import { Observable, Subscriber, from, switchMap } from 'rxjs';
import { WithLogger, toSerializableObject } from '@cardano-sdk/util';
import { block as blockToCore } from '../../ogmiosToCore';
import { nanoid } from 'nanoid';
import { ogmiosToCorePointOrOrigin, ogmiosToCoreTip, ogmiosToCoreTipOrOrigin, pointOrOriginToOgmios } from './util';

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
  response: Schema.Ogmios['NextBlockResponse'],
  subscriber: Subscriber<ChainSyncEvent>,
  requestNext: RequestNext,
  logger: Logger
): PointOrOrigin | undefined => {
  if (response.result.direction === 'backward') {
    const point = ogmiosToCorePointOrOrigin(response.result.point);
    subscriber.next({
      eventType: ChainSyncEventType.RollBackward,
      point,
      requestNext,
      tip: ogmiosToCoreTipOrOrigin(response.result.tip)
    });
    return point;
  } else if (response.result.direction === 'forward') {
    const coreBlock = mapBlock(response.result.block, logger);
    if (!coreBlock) {
      // Assuming it's an EBB
      requestNext();
      return;
    }
    subscriber.next({
      block: coreBlock,
      eventType: ChainSyncEventType.RollForward,
      requestNext,
      tip: ogmiosToCoreTip(response.result.tip)
    });
    return {
      hash: coreBlock.header.hash,
      slot: coreBlock.header.slot
    };
  }
  subscriber.error(
    new GeneralCardanoNodeError(
      GeneralCardanoNodeErrorCode.Unknown,
      response.result,
      'Unrecognized chain sync event direction'
    )
  );
};

const isResponseId = (id: unknown): id is { [RequestIdProp]: string } =>
  typeof id === 'object' && !!id && RequestIdProp in id;

export const createObservableChainSyncClient = (
  { intersectionPoint }: ObservableChainSyncClientProps,
  { interactionContext$, logger }: WithObservableInteractionContext & WithLogger
): Observable<ChainSyncEvent> => {
  let cursor = intersectionPoint;
  return interactionContext$.pipe(
    // set cursor for each connection
    switchMap((context) =>
      from(ChainSynchronization.findIntersection(context, [pointOrOriginToOgmios(cursor)]).then(() => context))
    ),
    switchMap(
      (context) =>
        new Observable<ChainSyncEvent>((subscriber) => {
          let requestId: string;
          const requestNext = () => {
            requestId = nanoid(5);
            ChainSynchronization.nextBlock(context.socket, {
              id: {
                [RequestIdProp]: requestId
              }
            });
          };
          const handler = (message: string) => {
            const response: Schema.Ogmios['NextBlockResponse'] = safeJSON.parse(message);
            if (response.method === 'nextBlock') {
              if (!isResponseId(response.id) || requestId !== response.id[RequestIdProp]) {
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
