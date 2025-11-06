import * as BaseEncoding from '@scure/base';
import { Credential, CredentialType } from './Address';
import { OpaqueString, typedBech32 } from '@cardano-sdk/util';

/** Payment credential as bech32 (addr_vkh for key hash, script for script hash - per CIP-5) */
export type PaymentCredential = OpaqueString<'PaymentCredential'>;

/**
 * @param {string} value payment credential as bech32 string (addr_vkh for key hash, script for script hash)
 * @throws InvalidStringError
 */
export const PaymentCredential = (value: string): PaymentCredential => {
  try {
    return typedBech32(value, ['addr_vkh'], 45);
  } catch {
    return typedBech32(value, ['script'], 45);
  }
};

/**
 * Converts address Credential to bech32 PaymentCredential.
 *
 * @param credential The credential to convert.
 * @returns The payment credential as bech32 string.
 */
PaymentCredential.fromCredential = (credential: Credential): PaymentCredential => {
  const words = BaseEncoding.bech32.toWords(Buffer.from(credential.hash, 'hex'));
  const prefix = credential.type === CredentialType.KeyHash ? 'addr_vkh' : 'script';
  return BaseEncoding.bech32.encode(prefix, words, 1023) as PaymentCredential;
};
