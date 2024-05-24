import { Address, AddressType } from './Address';
import { HexBlob, InvalidStringError, OpaqueString, assertIsHexString } from '@cardano-sdk/util';
import { isRewardAccount } from './PaymentAddress';

export type ScriptAddress = OpaqueString<'ScriptAddress'>;

// TODO: Script addresses are between 56 and 64 characters long, but BaseAddress generates more than that
/* const assertScriptAddressLength = (address: string) => {
  const length = address.length;
  if (length <= 56) {
    throw new InvalidStringError(address, 'Expected script address should not be less than 56 characters');
  }

  if (address.length > 64) {
    throw new InvalidStringError(address, 'Expected script address to be longer than 64 characters');
  }
};

const isAddressWithStaking = (address: string) => {
  try {
    assertScriptAddressLength(address);
  } catch {
    return true;
  }
}; */

export const ScriptAddress = (value: string): ScriptAddress => {
  const isRewardAddress = isRewardAccount(value);
  if (Address.isValid(value)) {
    if (isRewardAddress) {
      throw new Error('Address type can only be used for payment addresses');
    }
    return value as unknown as ScriptAddress;
  }

  try {
    assertIsHexString(value);
  } catch {
    throw new InvalidStringError(value, 'Expected payment address as bech32, base58 or hex-encoded bytes');
  }

  const address = Address.fromBytes(HexBlob.fromBytes(Buffer.from(value, 'hex')));

  return (address.getType() === AddressType.Byron
    ? address.toBase58()
    : address.toBech32()) as unknown as ScriptAddress;
};
