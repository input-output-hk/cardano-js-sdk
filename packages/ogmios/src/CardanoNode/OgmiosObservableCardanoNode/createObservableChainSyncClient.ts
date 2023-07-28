import { CardanoNodeErrors, ChainSyncEvent, ChainSyncEventType, PointOrOrigin, RequestNext } from '@cardano-sdk/core';
import { InteractionContext, Schema, safeJSON } from '@cardano-ogmios/client';
import { Observable, Subscriber, from, switchMap } from 'rxjs';
import { block as blockToCore } from '../../ogmiosToCore';
import { findIntersect, requestNext as sendRequestNext } from '@cardano-ogmios/client/dist/ChainSync';
import { nanoid } from 'nanoid';
import { ogmiosToCorePointOrOrigin, ogmiosToCoreTip, ogmiosToCoreTipOrOrigin, pointOrOriginToOgmios } from './util';

export interface ObservableChainSyncClientProps {
  intersectionPoint: PointOrOrigin;
}

export interface WithObservableInteractionContext {
  interactionContext$: Observable<InteractionContext>;
}

const notifySubscriberAndParseNewCursor = (
  response: Schema.Ogmios['RequestNextResponse'],
  subscriber: Subscriber<ChainSyncEvent>,
  requestNext: RequestNext
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
    const coreBlock = blockToCore(response.result.RollForward.block);
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

type Response = Schema.Ogmios['RequestNextResponse'];
type Request = { requestId: string; response?: Response };

const bufferLength = 10;

export const createObservableChainSyncClient = (
  { intersectionPoint }: ObservableChainSyncClientProps,
  { interactionContext$ }: WithObservableInteractionContext
): Observable<ChainSyncEvent> => {
  let cursor = intersectionPoint;
  return interactionContext$.pipe(
    // set cursor for each connection
    switchMap((context) => from(findIntersect(context, [pointOrOriginToOgmios(cursor)]).then(() => context))),
    switchMap(
      (context) =>
        new Observable<ChainSyncEvent>((subscriber) => {
          const requestsBuffer: Request[] = [];
          let subscriberReady = true;
          let unsubscribed = false;

          const requestNext = () => {
            if (unsubscribed) return;

            while (requestsBuffer.length <= bufferLength) {
              const mirror = { requestId: nanoid(5) };

              requestsBuffer.push(mirror);
              sendRequestNext(context.socket, { mirror });
            }
          };

          const notify = () => {
            if (unsubscribed || !subscriberReady || requestsBuffer.length === 0 || !requestsBuffer[0].response) return;

            subscriberReady = false;
            const { response } = requestsBuffer.shift()!;
            cursor =
              notifySubscriberAndParseNewCursor(response!, subscriber, () => {
                subscriberReady = true;
                notify();
                requestNext();
              }) || cursor;
          };

          const handler = (message: string) => {
            const response: Response = safeJSON.parse(message);
            const id = requestsBuffer.findIndex(({ requestId }) => requestId === response.reflection?.requestId);

            if (response.methodname !== 'RequestNext' || id === -1) return;

            requestsBuffer[id].response = response;
            notify();
          };
          context.socket.on('message', handler);
          requestNext();
          return () => {
            unsubscribed = true;
            context.socket.off('message', handler);
          };
        })
    )
  );
};
