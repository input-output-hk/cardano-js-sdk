import { consumeRemoteApi } from '../messaging/index.js';
import { supplyDistributionTrackerChannel, supplyDistributionTrackerProperties } from './util.js';
import type { MessengerDependencies } from '../messaging/index.js';

export interface ConsumeSupplyDistributionTrackerProps {
  walletName: string;
}

export const consumeSupplyDistributionTracker = (
  { walletName }: ConsumeSupplyDistributionTrackerProps,
  dependencies: MessengerDependencies
) =>
  consumeRemoteApi(
    {
      baseChannel: supplyDistributionTrackerChannel(walletName),
      properties: supplyDistributionTrackerProperties
    },
    dependencies
  );
