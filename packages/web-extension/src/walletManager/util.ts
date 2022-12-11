import { AsyncKeyAgent } from '@cardano-sdk/key-management';
import blake2b from 'blake2b';

import { RemoteApiProperties, RemoteApiPropertyType } from '../messaging';
import { WalletManagerApi, WalletManagerProps } from './walletManager.types';

export const walletManagerChannel = (walletName: WalletManagerProps['walletName']) => `${walletName}-wallet-manager`;
export const walletChannel = (walletName: WalletManagerProps['walletName']) =>
  `${walletManagerChannel(walletName)}-wallet`;

export const walletManagerProperties: RemoteApiProperties<WalletManagerApi> = {
  activate: RemoteApiPropertyType.MethodReturningPromise,
  deactivate: RemoteApiPropertyType.MethodReturningPromise,
  destroy: RemoteApiPropertyType.MethodReturningPromise
};

/**
 * Compute a unique walletId from the keyAgent chainId and the root public key hash.
 * `networkId-networkMagic-blake2bHashOfExtendedAccountPublicKey`
 */
export const getWalletId = async (keyAgent: AsyncKeyAgent): Promise<string> => {
  const { networkId, networkMagic } = await keyAgent.getChainId();
  const extendedAccountPublicKey = await keyAgent.extendedAccountPublicKey();
  const pubKey = Buffer.from(extendedAccountPublicKey, 'hex');
  const pubKeyHash = blake2b(blake2b.BYTES_MIN).update(pubKey).digest('hex');

  return `${networkId}-${networkMagic}-${pubKeyHash}`;
};
