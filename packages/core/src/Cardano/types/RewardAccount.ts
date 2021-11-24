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
export const RewardAccount = (value: string): RewardAccount => {
  util.assertIsBech32WithPrefix(value, ['stake', 'stake_test'], 47);
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  return value as any as RewardAccount;
};
