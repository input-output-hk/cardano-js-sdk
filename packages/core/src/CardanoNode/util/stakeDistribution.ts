import type { Lovelace } from '../../Cardano/index.js';
import type { StakeDistribution } from '../types/index.js';

/**
 * Transforms StakeDistribution to a single live stake value of the network
 *
 * @param {StakeDistribution} stakeDistribution
 */

export const toLiveStake = (stakeDistribution: StakeDistribution): Lovelace =>
  [...stakeDistribution.values()].reduce((accumulator, { stake }) => accumulator + stake.pool, BigInt(0));
