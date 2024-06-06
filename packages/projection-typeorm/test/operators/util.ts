import { BigIntMath } from '@cardano-sdk/util';
import { Cardano, ChainSyncEventType } from '@cardano-sdk/core';
import { Observable, lastValueFrom, map, takeWhile } from 'rxjs';
import { TypeormStabilityWindowBuffer, createObservableConnection, createTypeormTipTracker } from '../../src/index.js';
import { connectionConfig$ } from '../util.js';
import { generateRandomHexString, logger } from '@cardano-sdk/util-dev';
import type {
  BaseProjectionEvent,
  BootstrapExtraProps,
  ProjectionEvent,
  RollBackwardEvent,
  WithBlock,
  WithNetworkInfo
} from '@cardano-sdk/projection';
import type { Point } from '@cardano-sdk/core';
import type { RetryBackoffConfig } from 'backoff-rxjs';
import type { TypeormTipTracker } from '../../src/index.js';
import type { chainSyncData } from '@cardano-sdk/util-dev';

export interface ProjectorContext {
  buffer: TypeormStabilityWindowBuffer;
  tipTracker: TypeormTipTracker;
}

const retryBackoffConfig: RetryBackoffConfig = {
  initialInterval: 10,
  maxInterval: 100
};

export const createProjectorContext = (entities: Function[]): ProjectorContext => {
  const connection$ = createObservableConnection({
    connectionConfig$,
    entities,
    logger
  });
  return {
    buffer: new TypeormStabilityWindowBuffer({
      connection$,
      logger,
      reconnectionConfig: retryBackoffConfig
    }),
    tipTracker: createTypeormTipTracker({ connection$, reconnectionConfig: retryBackoffConfig })
  };
};

export const createProjectorTilFirst =
  <T>(project: () => Observable<T>) =>
  async (filter: (evt: T) => boolean) =>
    lastValueFrom(project().pipe(takeWhile((evt) => !filter(evt), true)));

/**
 * Never completes, because withTypeormTransaction is completing when the source completes:
 * it is initializing query runner asynchronously, and doesn't have enough time to emit the value(s).
 */
export const createStubProjectionSource = (events: BaseProjectionEvent[]): Observable<ProjectionEvent<{}>> =>
  new Observable((observer) => {
    const remainingEvents = [...events];
    const next = () => {
      const evt = remainingEvents.shift();
      if (evt) {
        observer.next({
          ...evt,
          requestNext: next
        } as ProjectionEvent<{}>);
      } else {
        logger.debug('No more stub events remaining');
      }
    };
    next();
  });

export const createStubBlockHeader = (blockNo: Cardano.BlockNo): Cardano.PartialBlockHeader => ({
  blockNo,
  hash: Cardano.BlockId(generateRandomHexString(64)),
  slot: Cardano.Slot(blockNo * 20)
});
export interface CreateStubRollForwardEventProps {
  blockBody: Cardano.OnChainTx[];
  blockHeader: Cardano.PartialBlockHeader;
}

export const createStubRollForwardEvent = (
  { blockBody, blockHeader }: CreateStubRollForwardEventProps,
  { eraSummaries, genesisParameters }: WithNetworkInfo
): BaseProjectionEvent => ({
  block: {
    body: blockBody,
    header: blockHeader,
    totalOutput: BigIntMath.sum(
      blockBody.flatMap(({ body: { outputs } }) => outputs.flatMap(({ value: { coins } }) => coins))
    ),
    txCount: blockBody.length
  },
  crossEpochBoundary: false,
  epochNo: Cardano.EpochNo((blockHeader.blockNo % 100) + 1),
  eraSummaries,
  eventType: ChainSyncEventType.RollForward,
  genesisParameters,
  tip: blockHeader
});

/**
 * @param evt event to rollback
 * @param rollbackPoint tip is set to a random block at height 1 if not specified
 */
export const createRollBackwardEventFor = (
  evt: BaseProjectionEvent,
  rollbackPoint: Point = createStubBlockHeader(Cardano.BlockNo(1))
): Omit<RollBackwardEvent<BootstrapExtraProps & WithBlock>, 'requestNext'> => ({
  ...evt,
  eventType: ChainSyncEventType.RollBackward,
  point: rollbackPoint
});

export const createRollForwardEventBasedOn = (
  evt: BaseProjectionEvent,
  patchBlock: (block: Cardano.Block) => Cardano.Block
): BaseProjectionEvent => {
  const updateBlockHeader: Cardano.PartialBlockHeader = {
    blockNo: Cardano.BlockNo(evt.block.header.blockNo + 1),
    hash: Cardano.BlockId(generateRandomHexString(64)),
    slot: Cardano.Slot(evt.block.header.slot + 20)
  };
  return {
    block: {
      ...patchBlock(evt.block),
      header: updateBlockHeader
    },
    crossEpochBoundary: false,
    epochNo: evt.epochNo,
    eraSummaries: evt.eraSummaries,
    eventType: ChainSyncEventType.RollForward,
    genesisParameters: evt.genesisParameters,
    tip: updateBlockHeader
  };
};

export const createStubTx = (body: Partial<Cardano.TxBody>, metadata?: Cardano.TxMetadata): Cardano.OnChainTx => ({
  auxiliaryData: { blob: metadata },
  body: {
    fee: 123n,
    inputs: [],
    outputs: [],
    ...body
  },
  id: Cardano.TransactionId(generateRandomHexString(64)),
  inputSource: Cardano.InputSource.inputs,
  witness: { signatures: new Map() }
});

export const filterAssets = (
  events: ReturnType<typeof chainSyncData>,
  assetIds: Cardano.AssetId[]
): ReturnType<typeof chainSyncData> => ({
  ...events,
  cardanoNode: {
    ...events.cardanoNode,
    findIntersect: (points) =>
      events.cardanoNode.findIntersect(points).pipe(
        map((observableChainSync) => ({
          ...observableChainSync,
          chainSync$: observableChainSync.chainSync$.pipe(
            // filter out Tokens that don't exist in the database with this dataset
            map((e) => ({
              ...e,
              ...(e.eventType === ChainSyncEventType.RollForward
                ? {
                    block: {
                      ...e.block,
                      body: e.block.body.map((tx) => ({
                        ...tx,
                        body: {
                          ...tx.body,
                          outputs: tx.body.outputs.map((output) => ({
                            ...output,
                            value: {
                              ...output.value,
                              assets: new Map(
                                [...(output.value.assets?.entries() || [])].filter(([assetId]) =>
                                  assetIds.includes(assetId)
                                )
                              )
                            }
                          }))
                        }
                      }))
                    }
                  }
                : {})
            }))
          )
        }))
      )
  }
});
