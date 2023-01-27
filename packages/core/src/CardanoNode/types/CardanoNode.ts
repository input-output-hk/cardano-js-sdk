import { Block, Lovelace, PoolId, Tip, VrfVkHex } from '../../Cardano';
// eslint-disable-next-line @typescript-eslint/ban-ts-comment
// @ts-ignore
import { CardanoNodeError } from './CardanoNodeErrors';
import { HealthCheckResponse } from '../../Provider';
import { Milliseconds } from '../../util';

export interface EraSummary {
  parameters: {
    epochLength: number;
    slotLength: Milliseconds;
  };
  start: {
    slot: number;
    time: Date;
  };
}

/**
 * Map of the live stake distribution, indexed by PoolId
 */
export type StakeDistribution = Map<
  PoolId,
  {
    stake: {
      pool: Lovelace;
      supply: Lovelace;
    };
    vrf: VrfVkHex;
  }
>;

export interface CardanoNode {
  eraSummaries: () => Promise<EraSummary[]>;
  /**
   * Get the start date of the network.
   *
   * @returns {Date} Network start date
   * @throws {CardanoNodeError}
   */
  systemStart: () => Promise<Date>;
  /**
   * Get the live stake distribution of the network.
   *
   * @returns {StakeDistribution}
   * @throws {CardanoNodeError}
   */
  stakeDistribution: () => Promise<StakeDistribution>;
  /**
   * Performs a health check on the CardanoNode.
   *
   * @returns {HealthCheckResponse} A promise with the health check response.
   */
  healthCheck(): Promise<HealthCheckResponse>;
}

// Similar to Ogmios.Point, but using Cardano.BlockId opaque string for hash
export type Point = Pick<Tip, 'hash' | 'slot'>;
export type Origin = 'origin';
export type TipOrOrigin = Tip | Origin;
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

export interface ChainSyncRollForward {
  tip: Tip;
  eventType: ChainSyncEventType.RollForward;
  block: Block;
  requestNext: RequestNext;
}

export interface ChainSyncRollBackward {
  eventType: ChainSyncEventType.RollBackward;
  tip: TipOrOrigin;
  requestNext: RequestNext;
}

export type ChainSyncEvent = ChainSyncRollForward | ChainSyncRollBackward;
