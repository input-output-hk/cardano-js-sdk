import { ByronAddress, EnterpriseAddress, PaymentAddress, PointerAddress } from '../../Cardano/Address';
import { Point } from './ObservableCardanoNode';

export type Handle = string;

type CardanoAddress = ByronAddress | PaymentAddress | EnterpriseAddress | PointerAddress;

export interface HandleInfo {
  handle: Handle;
  hasDatum: boolean;
  resolvedAddresses: {
    cardano: CardanoAddress;
  };
  resolvedAt: Point;
}

export interface ResolveHandlesArgs {
  handles: Handle[];
}

export interface HandleProvider {
  resolveHandles(args: ResolveHandlesArgs): Promise<HandleInfo[] | null>;
}
