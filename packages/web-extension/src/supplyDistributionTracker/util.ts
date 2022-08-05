import { RemoteApiProperties, RemoteApiPropertyType } from '../messaging';
import { SupplyDistributionTracker } from '@cardano-sdk/wallet';

export const supplyDistributionTrackerChannel = (walletName: string) => `${walletName}SupplyDistributionTracker$`;

export const supplyDistributionTrackerProperties: RemoteApiProperties<SupplyDistributionTracker> = {
  lovelaceSupply$: RemoteApiPropertyType.HotObservable,
  stake$: RemoteApiPropertyType.HotObservable
};
