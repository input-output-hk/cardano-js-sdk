import { Asset, Cardano, HttpProviderConfigPaths, Point, Provider } from '../..';

export type Handle = string;

/**
 * @param policyId a hex encoded policyID
 * @param handle a personalized string to identify a user
 * @param hasDatum a boolean to indicated whether it contains a datum
 * @param cardanoAddress the cardano payment address resolved from the handle
 * @param resolvedAt the point at which the Handle was resolved
 */
export interface HandleResolution {
  addresses: {
    bitcoin?: string;
    cardano: Cardano.PaymentAddress;
  };
  policyId: Cardano.PolicyId;
  handle: Handle;
  /** @deprecated Use `addresses.cardano` instead. */
  cardanoAddress: Cardano.PaymentAddress;
  hasDatum: boolean;
  defaultForStakeCredential?: Handle;
  defaultForPaymentCredential?: Handle;
  image?: Asset.Uri;
  backgroundImage?: Asset.Uri;
  profilePic?: Asset.Uri;
  resolvedAt?: Point;
  parentHandle?: Handle;
}

export interface ResolveHandlesArgs {
  handles: Handle[];
  force?: boolean;
}

/**
 * @param handles array
 * @returns
 * @param HandleResolution or null
 */
export interface HandleProvider extends Provider {
  resolveHandles(args: ResolveHandlesArgs): Promise<Array<HandleResolution | null>>;
  getPolicyIds(): Promise<Cardano.PolicyId[]>;
}

export const handleProviderPaths: HttpProviderConfigPaths<HandleProvider> = {
  getPolicyIds: '/policyIds',
  healthCheck: '/health',
  resolveHandles: '/resolve'
};
