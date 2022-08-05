import { Lovelace } from '../../Cardano';
import { StakeDistribution } from '../types';

/**
 * Transforms StakeDistribution to a single live stake value of the network
 *
 * @param {StakeDistribution} stakeDistribution
 */

export const toLiveStake = (stakeDistribution: StakeDistribution): Lovelace =>
  [...stakeDistribution.values()].reduce((accumulator, { stake }) => accumulator + stake.pool, BigInt(0));
