import { Cardano, calculateStabilityWindowSlotsCount } from '@cardano-sdk/core';
import { withStaticContext } from './withStaticContext';

export type WithStabilityWindow = { stabilityWindowSlotsCount: number };

/**
 * Adds `stabilityWindowSlotsCount` to each event
 */
export const withStabilityWindow = <ExtraRollForwardPropsIn, ExtraRollBackwardPropsIn>(
  genesisParameters: Cardano.CompactGenesis
) =>
  withStaticContext<WithStabilityWindow, ExtraRollForwardPropsIn, ExtraRollBackwardPropsIn>({
    stabilityWindowSlotsCount: calculateStabilityWindowSlotsCount(genesisParameters)
  });
