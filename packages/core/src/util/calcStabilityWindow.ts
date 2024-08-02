import type { Cardano } from '..';

/**
 * 3k/f (where k is the security parameter in genesis, and f is the active slot co-efficient parameter
 * in genesis that determines the probability for amount of blocks created in an epoch.)
 */
export const calculateStabilityWindowSlotsCount = ({
  securityParameter,
  activeSlotsCoefficient
}: Pick<Cardano.CompactGenesis, 'securityParameter' | 'activeSlotsCoefficient'>): number =>
  (3 * securityParameter) / activeSlotsCoefficient;
