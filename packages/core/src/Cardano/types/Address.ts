import * as typesUtil from '../util';
import { InvalidStringError } from '../..';
import { util as addressUtil } from '../../Address';

/**
 * mainnet or testnet address as bech32 string, consisting of
 * network tag, payment credential and optional stake credential
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
