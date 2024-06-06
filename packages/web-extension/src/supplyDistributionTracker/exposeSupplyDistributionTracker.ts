import { exposeApi } from '../messaging/index.js';
import { of } from 'rxjs';
import { supplyDistributionTrackerChannel, supplyDistributionTrackerProperties } from './util.js';
import type { MessengerDependencies } from '../messaging/index.js';
import type { SupplyDistributionTracker } from '@cardano-sdk/wallet';

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
