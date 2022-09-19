import * as typesUtil from '../util';
import { InvalidStringError } from '../../errors';

/**
 * mainnet or testnet address (Shelley as bech32 string, Byron as base58-encoded string)
 */
export type Address = typesUtil.OpaqueString<'Address'>;

/**
 * @param {string} value mainnet or testnet address
 * @throws InvalidStringError
 */

const isRewardAccount = (address: string) => {
  try {
    typesUtil.assertIsBech32WithPrefix(address, ['stake', 'stake_test']);
    return true;
  } catch {
    return false;
  }
};

export const Address = (value: string): Address => {
  if (typesUtil.isAddress(value) && !isRewardAccount(value)) {
    return value as unknown as Address;
  }
  throw new InvalidStringError(`Invalid address: ${value}`);
};
