import { CML } from '../../CML';
import { Ed25519KeyHashHex } from '@cardano-sdk/crypto';
import { OpaqueString, typedBech32, usingAutoFree } from '@cardano-sdk/util';

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
  usingAutoFree((scope) => {
    const bech32 = scope.manage(CML.Address.from_bech32(rewardAccount.toString()));
    const rewardAddress = scope.manage(CML.RewardAddress.from_address(bech32)!);
    const paymentCred = scope.manage(rewardAddress.payment_cred()!);
    const keyHash = scope.manage(paymentCred.to_keyhash()!);

    return Ed25519KeyHashHex(Buffer.from(keyHash.to_bytes()).toString('hex'));
  });
