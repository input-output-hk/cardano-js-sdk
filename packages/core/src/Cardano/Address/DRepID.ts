import { Address, AddressType } from './Address.js';
import { assertIsBech32WithPrefix, typedBech32 } from '@cardano-sdk/util';
import type { OpaqueString } from '@cardano-sdk/util';
/** DRepID as bech32 string */
export type DRepID = OpaqueString<'DRepID'>;

/**
 * @param {string} value DRepID as bech32 string
 * @throws InvalidStringError
 */
export const DRepID = (value: string): DRepID => typedBech32(value, ['drep']);

DRepID.isValid = (value: string): boolean => {
  try {
    assertIsBech32WithPrefix(value, 'drep');
    return true;
  } catch {
    return false;
  }
};

DRepID.canSign = (value: string): boolean => {
  try {
    return DRepID.isValid(value) && Address.fromBech32(value).getType() === AddressType.EnterpriseKey;
  } catch {
    return false;
  }
};
