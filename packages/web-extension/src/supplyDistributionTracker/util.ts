import { RemoteApiPropertyType } from '../messaging/index.js';
import type { RemoteApiProperties } from '../messaging/index.js';
import type { SupplyDistributionTracker } from '@cardano-sdk/wallet';

export const supplyDistributionTrackerChannel = (walletName: string) => `${walletName}SupplyDistributionTracker$`;

export const supplyDistributionTrackerProperties: RemoteApiProperties<SupplyDistributionTracker> = {
  lovelaceSupply$: RemoteApiPropertyType.HotObservable,
  stake$: RemoteApiPropertyType.HotObservable
};
