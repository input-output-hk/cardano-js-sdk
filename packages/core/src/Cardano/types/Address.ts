import * as typesUtil from '../util';
import { InvalidStringError } from '../..';
import { util as addressUtil } from '../../Address';

/**
 * mainnet or testnet address (Shelley as bech32 string, Byron as base58-encoded string)
 */
export type Address = typesUtil.OpaqueString<'Address'>;

/**
 * @param {string} value mainnet or testnet address
 * @throws InvalidStringError
 */
export const Address = (value: string): Address => {
  if (addressUtil.isAddress(value)) {
    return value as unknown as Address;
  }
  throw new InvalidStringError(`Invalid address: ${value}`);
};
