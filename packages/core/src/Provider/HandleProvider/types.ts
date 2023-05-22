import { ByronAddress, EnterpriseAddress, PaymentAddress, PointerAddress } from '../../Cardano/Address';
import { Point } from '../..';

export type Handle = string;

export type CardanoAddress = ByronAddress | PaymentAddress | EnterpriseAddress | PointerAddress;

export enum HandleIssuer {
  KoraLabs = 'KoraLabs'
}
export interface HandleResolution {
  issuer: HandleIssuer;
  handle: Handle;
  hasDatum: boolean;
  resolvedAddresses: {
    cardano: CardanoAddress;
  };
  resolvedAt: Point;
  code?: number | undefined;
}

export interface ResolveHandlesArgs {
  handles: Handle[];
}

export interface HandleProvider {
  resolveHandles(args: ResolveHandlesArgs): Promise<Array<HandleResolution | null>>;
}
