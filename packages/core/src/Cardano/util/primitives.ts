import { Decoded, bech32 } from 'bech32';
import { InvalidStringError } from '../../errors';

const MAX_BECH32_LENGTH_LIMIT = 1023;

// Source: https://github.com/Microsoft/Typescript/issues/202#issuecomment-811246768
export declare class OpaqueString<T extends string> extends String {
  /** This helps typescript distinguish different opaque string types. */
  protected readonly __opaqueString: T;
  /**
   * This object is already a string, but calling this makes method
   * makes typescript recognize it as such.
   */
  toString(): string;
}

/**
 * @param {string} target bech32 string to decode
 * @param {string} prefix expected prefix
 * @param {string} expectedDecodedLength number of expected words, >0
 * @throws {InvalidStringError}
 */
export const assertIsBech32WithPrefix = (target: string, prefix: string, expectedDecodedLength?: number): void => {
  let decoded: Decoded;
  try {
    decoded = bech32.decode(target, MAX_BECH32_LENGTH_LIMIT);
  } catch (error) {
    throw new InvalidStringError(`expected bech32-encoded string with '${prefix}' prefix`, error);
  }
  if (decoded.prefix !== prefix) {
    throw new InvalidStringError(`expected bech32 prefix '${prefix}', got '${decoded.prefix}''`);
  }
  if (expectedDecodedLength && decoded.words.length !== expectedDecodedLength) {
    throw new InvalidStringError(
      `expected decoded length of '${expectedDecodedLength}', got '${decoded.words.length}'`
    );
  }
};

/**
 * @param {string} target bech32 string to decode
 * @param {string} expectedLength expected string length, >0
 * @throws {InvalidStringError}
 */
export const assertIsHexString = (target: string, expectedLength?: number): void => {
  if (expectedLength && target.length !== expectedLength) {
    throw new InvalidStringError(`expected length '${expectedLength}', got ${target.length}`);
  }
  // eslint-disable-next-line wrap-regex
  if (!/^[\da-f]+$/i.test(target)) {
    throw new InvalidStringError('expected hex string');
  }
};
