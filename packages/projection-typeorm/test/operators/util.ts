import {
  BaseProjectionEvent,
  BootstrapExtraProps,
  ProjectionEvent,
  RollBackwardEvent,
  WithBlock,
  WithNetworkInfo
} from '@cardano-sdk/projection';
import { BigIntMath } from '@cardano-sdk/util';
import { Cardano, ChainSyncEventType, Point } from '@cardano-sdk/core';
import { Observable, lastValueFrom, takeWhile } from 'rxjs';
import { generateRandomHexString, logger } from '@cardano-sdk/util-dev';

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
