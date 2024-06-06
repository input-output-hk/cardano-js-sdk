import type { Runtime } from 'webextension-polyfill';

export type Origin = string;

/** Resolve true to authorise access to the WalletAPI, or resolve false to deny. Errors: `ApiError` */
export type RequestAccess = (sender: Runtime.MessageSender) => Promise<boolean>;
export type RevokeAccess = RequestAccess;
export type HaveAccess = RequestAccess;

export interface AuthenticatorApi {
  requestAccess: RequestAccess;
  revokeAccess: RevokeAccess;
  haveAccess: HaveAccess;
}

type RemoteRequestAccess = () => Promise<boolean>;
type RemoteRevokeAccess = RemoteRequestAccess;
type RemoteHaveAccess = RemoteRequestAccess;

/**
 * This is different to Authenticator, because methods don't have 'origin' arg.
 * This authenticator is intended to be used to authenticate yourself, from a content-script etc.
 *
 * Methods must never throw.
 */
export interface RemoteAuthenticator {
  requestAccess: RemoteRequestAccess;
  revokeAccess: RemoteRevokeAccess;
  haveAccess: RemoteHaveAccess;
}

export type RemoteAuthenticatorMethod = keyof RemoteAuthenticator;
