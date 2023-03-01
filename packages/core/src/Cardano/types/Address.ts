import { CML } from '../../CML';
import {
  InvalidStringError,
  OpaqueString,
  assertIsBech32WithPrefix,
  assertIsHexString,
  usingAutoFree
} from '@cardano-sdk/util';
import { isAddress } from '../util/address';

/**
 * mainnet or testnet address (Shelley as bech32 string, Byron as base58-encoded string)
 */
export type PaymentAddress = OpaqueString<'Address'>;

/**
 * @param {string} address mainnet or testnet address
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

/**
 * Transform a `value` into `Cardano.PaymentAddress`,
 * Resulting PaymentAddress will be base58 in case of Byron era or bech32 in case of Shelley era or newer.
 *
 * @param value bech32 string, base58 string or hex-encoded bytes address.
 * @throws {InvalidStringError} if value is invalid
 */

export const PaymentAddress = (value: string): PaymentAddress => {
  if (isAddress(value)) {
    if (isRewardAccount(value)) {
      throw new InvalidStringError(value, 'Address type can only be used for payment addresses');
    }
    return value as unknown as PaymentAddress;
  }

  try {
    assertIsHexString(value);
  } catch {
    throw new InvalidStringError(value, 'Expected payment address as bech32, base58 or hex-encoded bytes');
  }

  return usingAutoFree((scope) => {
    try {
      return PaymentAddress(scope.manage(CML.ByronAddress.from_bytes(Buffer.from(value, 'hex'))).to_base58());
    } catch {
      try {
        return PaymentAddress(scope.manage(CML.Address.from_bytes(Buffer.from(value, 'hex'))).to_bech32());
      } catch {
        throw new InvalidStringError(value, 'Invalid payment address');
      }
    }
  });
};
