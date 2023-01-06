import { Address, Ed25519KeyHash, NetworkId, RewardAccount } from '../Cardano';
import { CML } from './CML';
import { parseCmlAddress } from './parseCmlAddress';
import { usingAutoFree } from '@cardano-sdk/util';

export const addressNetworkId = (address: RewardAccount | Address): NetworkId =>
  usingAutoFree((scope) => parseCmlAddress(scope, address.toString())!.network_id());

export const createRewardAccount = (stakeKeyHash: Ed25519KeyHash, networkId: NetworkId) =>
  usingAutoFree((scope) => {
    const keyHash = scope.manage(CML.Ed25519KeyHash.from_hex(stakeKeyHash.toString()));
    const stakeCredential = scope.manage(CML.StakeCredential.from_keyhash(keyHash));
    const rewardAccount = scope.manage(CML.RewardAddress.new(networkId, stakeCredential));
    return RewardAccount(scope.manage(rewardAccount.to_address()).to_bech32());
  });
