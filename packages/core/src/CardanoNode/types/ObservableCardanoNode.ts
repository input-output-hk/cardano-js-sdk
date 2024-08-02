import { bufferChainSyncEvent } from '../util/bufferChainSyncEvent';
import type { Cardano, HealthCheckResponse, Serialization } from '../..';
import type { EraSummary } from './CardanoNode';
import type { Observable } from 'rxjs';

// Similar to Ogmios.Point, but using Cardano.BlockId opaque string for hash
export type Point = Pick<Cardano.Tip, 'hash' | 'slot'>;
export type Origin = 'origin';
export type TipOrOrigin = Cardano.Tip | Origin;
export type PointOrOrigin = Point | Origin;
export type Intersection = {
  point: PointOrOrigin;
  tip: TipOrOrigin;
};

export enum ChainSyncEventType {
  RollForward,
  RollBackward
}

export type RequestNext = () => void;

export interface WithRequestNext {
  requestNext: RequestNext;
}

export interface ChainSyncRollForward extends WithRequestNext {
  tip: Cardano.Tip;
  eventType: ChainSyncEventType.RollForward;
  block: Cardano.Block;
}

export interface ChainSyncRollBackward extends WithRequestNext {
  eventType: ChainSyncEventType.RollBackward;
  point: PointOrOrigin;
  tip: TipOrOrigin;
}

export type ChainSyncEvent = ChainSyncRollForward | ChainSyncRollBackward;

export interface ObservableChainSync {
  /** Observable that can be used to subscribe to Chain Sync events from `intersection`. */
  chainSync$: Observable<ChainSyncEvent>;
  intersection: Intersection;
}

export interface ObservableCardanoNode {
  eraSummaries$: Observable<EraSummary[]>;
  genesisParameters$: Observable<Cardano.CompactGenesis>;
  healthCheck$: Observable<HealthCheckResponse>;
  /**
   * Find a common point between your local state and the node.
   *
   * Keeps the observable active until unsubscribed,
   * as this client could potentially switch to another node due to connection errors.
   * If you only need to find intersection once,
   * make sure to combine this with an appropriate operator (e.g. `take(1)`)
   *
   * chainSync$ in the emitted object is an independent Observable,
   * which keeps track of subscriber's cursor (starting from initial intersection)
   * and can opaquely switch to another node (tracks this client).
   *
   * @param points must be sorted tip to origin
   * @throws CardanoNodeErrors.CardanoClientErrors.IntersectionNotFoundError when
   * intersection point is not found by the node
   * (probably due to a rollback). User is expected to handle the rollback and call `findIntersect`
   * with a different set of points.
   * @throws CardanoNodeErrors.CardanoClientErrors.ConnectionError after reaching reconnection maxAttempts
   * @throws CardanoNodeErrors.CardanoClientErrors.UnknownResultError if server response doesn't match
   * client's expectations (version mismatch?)
   * @throws CardanoNodeErrors.UnknownCardanoNodeError on any other unexpected/unhandled errors
   */
  findIntersect(points: PointOrOrigin[]): Observable<ObservableChainSync>;

  /**
   * @param tx serialized transaction
   * @returns transaction id
   */
  submitTx(tx: Serialization.TxCBOR): Observable<Cardano.TransactionId>;
}

export const ObservableCardanoNode = { bufferChainSyncEvent } as const;
