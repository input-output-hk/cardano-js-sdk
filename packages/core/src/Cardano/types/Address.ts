import { InvalidStringError } from '../../errors';
import { OpaqueString, assertIsBech32WithPrefix } from '../util/primitives';
import { isAddress } from '../util/address';

/**
 * mainnet or testnet address (Shelley as bech32 string, Byron as base58-encoded string)
 */
export type Address = OpaqueString<'Address'>;

/**
 * @param {string} value mainnet or testnet address
 * @throws InvalidStringError
 */

const isRewardAccount = (address: string) => {
  try {
    assertIsBech32WithPrefix(address, ['stake', 'stake_test']);
    return true;
  } catch {
    return false;
  }
};

export const Address = (value: string): Address => {
  if (isAddress(value) && !isRewardAccount(value)) {
    return value as unknown as Address;
  }
  throw new InvalidStringError(`Invalid address: ${value}`);
};
