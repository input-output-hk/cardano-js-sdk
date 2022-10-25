import { MessengerDependencies, exposeApi } from '../messaging';
import { SupplyDistributionTracker } from '@cardano-sdk/wallet';
import { of } from 'rxjs';
import { supplyDistributionTrackerChannel, supplyDistributionTrackerProperties } from './util';

export interface ExposeSupplyDistributionTrackerProps {
  supplyDistributionTracker: SupplyDistributionTracker;
  walletName: string;
}

export const exposeSupplyDistributionTracker = (
  { supplyDistributionTracker: wallet, walletName }: ExposeSupplyDistributionTrackerProps,
  dependencies: MessengerDependencies
) =>
  exposeApi(
    {
      api$: of(wallet),
      baseChannel: supplyDistributionTrackerChannel(walletName),
      properties: supplyDistributionTrackerProperties
    },
    dependencies
  );
