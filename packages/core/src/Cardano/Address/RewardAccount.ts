import { Address, CredentialType } from './Address';
import { Ed25519KeyHashHex, Hash28ByteBase16 } from '@cardano-sdk/crypto';
import { NetworkId } from '../ChainId';
import { OpaqueString, typedBech32 } from '@cardano-sdk/util';
import { RewardAddress } from './RewardAddress';

/**
 * mainnet or testnet stake address as bech32 string,
 * consisting of network tag and stake credential
 */
export type RewardAccount = OpaqueString<'RewardAccount'>;

/**
 * @param {string} value mainnet or testnet stake address as bech32 string
 * @throws InvalidStringError
 */
export const RewardAccount = (value: string): RewardAccount => typedBech32(value, ['stake', 'stake_test'], 47);
RewardAccount.toHash = (rewardAccount: RewardAccount): Ed25519KeyHashHex =>
  Ed25519KeyHashHex(Address.fromBech32(rewardAccount).asReward()!.getPaymentCredential().hash);

/**
 * Creates a reward account from a given key hash and network id.
 *
 * @param stakeKeyHash The stake key hash.
 * @param networkId The network id.
 */
export const createRewardAccount = (stakeKeyHash: Ed25519KeyHashHex, networkId: NetworkId) =>
  RewardAccount(
    RewardAddress.fromCredentials(networkId, { hash: Hash28ByteBase16(stakeKeyHash), type: CredentialType.KeyHash })
      .toAddress()
      .toBech32()
  );
