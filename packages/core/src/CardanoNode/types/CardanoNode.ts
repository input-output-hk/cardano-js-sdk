import type { Lovelace, PoolId, VrfVkHex } from '../../Cardano/index.js';
// eslint-disable-next-line @typescript-eslint/ban-ts-comment
// @ts-ignore
import type { HealthCheckResponse } from '../../Provider/index.js';
import type { Milliseconds } from '../../util/index.js';

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

/** Map of the live stake distribution, indexed by PoolId */
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
