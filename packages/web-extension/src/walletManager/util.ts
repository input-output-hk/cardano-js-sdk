import * as Crypto from '@cardano-sdk/crypto';
import { AsyncKeyAgent } from '@cardano-sdk/key-management';

import { Cardano, Serialization } from '@cardano-sdk/core';
import { RemoteApiProperties, RemoteApiPropertyType } from '../messaging';
import { WalletManagerApi } from './walletManager.types';

export const walletManagerChannel = (channelName: string) => `${channelName}-wallet-manager`;
export const walletChannel = (channelName: string) => `${walletManagerChannel(channelName)}-wallet`;
export const repositoryChannel = (channelName: string) => `${channelName}-wallet-repository`;

export const walletManagerProperties: RemoteApiProperties<WalletManagerApi> = {
  activate: RemoteApiPropertyType.MethodReturningPromise,
  activeWalletId$: RemoteApiPropertyType.HotObservable,
  deactivate: RemoteApiPropertyType.MethodReturningPromise,
  destroyData: RemoteApiPropertyType.MethodReturningPromise,
  switchNetwork: RemoteApiPropertyType.MethodReturningPromise
};

/**
 * Predicate that returns true if the given object is a script.
 *
 * @param object The object to check.
 */
// eslint-disable-next-line @typescript-eslint/no-explicit-any
const isScript = (object: any): object is Cardano.Script =>
  object?.__type === Cardano.ScriptType.Plutus || object?.__type === Cardano.ScriptType.Native;

/**
 * Predicate that returns true if the given object is a public key.
 *
 * @param object The object to check.
 */
// eslint-disable-next-line @typescript-eslint/no-explicit-any
const isBip32PublicKeyHex = (object: any): object is Crypto.Bip32PublicKeyHex =>
  // eslint-disable-next-line wrap-regex
  typeof object === 'string' && object.length === 128 && /^[\da-f]+$/i.test(object);

/** Compute a unique walletId from the script */
export const getScriptWalletId = async (script: Cardano.Script): Promise<string> =>
  Serialization.Script.fromCore(script).hash().slice(0, 32);

/**
 * Compute a unique walletId from the extended account public key.
 *
 * @param pubKey The extended account public key.
 */
export const getExtendedAccountPublicKeyWalletId = async (pubKey: Crypto.Bip32PublicKeyHex): Promise<string> =>
  Crypto.blake2b(Crypto.blake2b.BYTES_MIN).update(Buffer.from(pubKey, 'hex')).digest('hex');

/**
 * Compute a unique walletId from the keyAgent.
 *
 * @param keyAgent The key agent.
 */
export const getKeyAgentWalletId = async (keyAgent: AsyncKeyAgent): Promise<string> =>
  getExtendedAccountPublicKeyWalletId(await keyAgent.getExtendedAccountPublicKey());

/** Compute a unique walletId. */
export const getWalletId = async (
  walletIdParam: AsyncKeyAgent | Cardano.Script | Crypto.Bip32PublicKeyHex
): Promise<string> => {
  if (isScript(walletIdParam)) return getScriptWalletId(walletIdParam);

  if (isBip32PublicKeyHex(walletIdParam)) return getExtendedAccountPublicKeyWalletId(walletIdParam);

  return getKeyAgentWalletId(walletIdParam);
};

// Add create ID and parse ID {account index and the key)
