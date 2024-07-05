import * as BaseEncoding from '@scure/base';
import { Bip32PublicKeyHex } from '@cardano-sdk/crypto';
import { InvalidStringError, OpaqueString, assertIsBech32WithPrefix } from '@cardano-sdk/util';

const MAX_BECH32_LENGTH_LIMIT = 1023;
const bip32PublicKeyPrefix = 'acct_shared_xvk';

/** This key is a bech32 encoded string with the prefix `acct_shared_xvk`. */
export type Cip1854ExtendedAccountPublicKey = OpaqueString<'Cip1854PublicKey'>;

export const Cip1854ExtendedAccountPublicKey = (value: string): Cip1854ExtendedAccountPublicKey => {
  try {
    assertIsBech32WithPrefix(value, [bip32PublicKeyPrefix]);
  } catch {
    throw new InvalidStringError(value, 'Expected key to be a bech32 encoded string');
  }

  return value as Cip1854ExtendedAccountPublicKey;
};

Cip1854ExtendedAccountPublicKey.fromBip32PublicKeyHex = (value: Bip32PublicKeyHex): Cip1854ExtendedAccountPublicKey => {
  const words = BaseEncoding.bech32.toWords(Buffer.from(value, 'hex'));
  return Cip1854ExtendedAccountPublicKey(
    BaseEncoding.bech32.encode(bip32PublicKeyPrefix, words, MAX_BECH32_LENGTH_LIMIT)
  );
};

Cip1854ExtendedAccountPublicKey.toBip32PublicKeyHex = (value: Cip1854ExtendedAccountPublicKey): Bip32PublicKeyHex => {
  const { words } = BaseEncoding.bech32.decode(value, MAX_BECH32_LENGTH_LIMIT);
  return Bip32PublicKeyHex(Buffer.from(BaseEncoding.bech32.fromWords(words)).toString('hex'));
};
