import * as util from '../util';

/**
 * mainnet or testnet stake address as bech32 string,
 * consisting of network tag and stake credential
 */
export type RewardAccount = util.OpaqueString<'RewardAccount'>;

/**
 * @param {string} value mainnet or testnet stake address as bech32 string
 * @throws InvalidStringError
 */
export const RewardAccount = (value: string): RewardAccount => util.typedBech32(value, ['stake', 'stake_test'], 47);
