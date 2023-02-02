import { OpaqueString, typedBech32 } from '@cardano-sdk/util';

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
