import { Cardano, Point, Provider } from '../..';

export type Handle = string;
export type Uri = `ipfs://${string}`; // IPFS hash

/**
 * @param policyId a hex encoded policyID
 * @param handle a personalized string to identify a user
 * @param hasDatum a boolean to indicated whether it contains a datum
 * @param resolvedAddresses the addresses resolved from the handle
 * @param resolvedAt the point at which the Handle was resolved
 */
export interface HandleResolution {
  policyId: Cardano.PolicyId;
  handle: Handle;
  hasDatum: boolean;
  resolvedAddresses: {
    cardano: Cardano.PaymentAddress;
  };
  resolvedAt: Point;
  createdAt?: Point;
  defaultInWallet?: Handle;
  backgroundImage?: Uri;
  profilePic?: Uri;
  image?: Uri;
  updatedAt?: Point;
}

export interface ResolveHandlesArgs {
  handles: Handle[];
}

/**
 * @param handles array
 * @returns
 * @param HandleResolution or null
 */
export interface HandleProvider extends Provider {
  resolveHandles(args: ResolveHandlesArgs): Promise<Array<HandleResolution | null>>;
}
