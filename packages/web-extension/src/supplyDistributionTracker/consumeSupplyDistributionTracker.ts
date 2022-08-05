import { MessengerDependencies, consumeRemoteApi } from '../messaging';
import { supplyDistributionTrackerChannel, supplyDistributionTrackerProperties } from './util';

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
