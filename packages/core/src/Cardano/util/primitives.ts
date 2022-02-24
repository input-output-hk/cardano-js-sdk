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

const isOneOf = <T>(target: T, options: T | T[]) =>
  (Array.isArray(options) && options.includes(target)) || target === options;

export const assertIsBech32WithPrefix = (
  target: string,
  prefix: string | string[],
  expectedDecodedLength?: number | number[]
): void => {
  let decoded: Decoded;
  try {
    decoded = bech32.decode(target, MAX_BECH32_LENGTH_LIMIT);
  } catch (error) {
    throw new InvalidStringError(`expected bech32-encoded string with '${prefix}' prefix`, error);
  }
  if (!isOneOf(decoded.prefix, prefix)) {
    throw new InvalidStringError(`expected bech32 prefix '${prefix}', got '${decoded.prefix}''`);
  }
  if (expectedDecodedLength && !isOneOf(decoded.words.length, expectedDecodedLength)) {
    throw new InvalidStringError(
      `expected decoded length of '${expectedDecodedLength}', got '${decoded.words.length}'`
    );
  }
};

/**
 * @param {string} target bech32 string to decode
 * @param {string} prefix expected prefix
 * @param {string} expectedDecodedLength number of expected words, >0
 * @throws {InvalidStringError}
 */
export const typedBech32 = <T>(
  target: string,
  prefix: string | string[],
  expectedDecodedLength?: number | number[]
) => {
  assertIsBech32WithPrefix(target, prefix, expectedDecodedLength);
  return target as unknown as T;
};

const assertLength = (expectedLength: number | undefined, target: string) => {
  if (expectedLength && target.length !== expectedLength) {
    throw new InvalidStringError(`expected length '${expectedLength}', got ${target.length}`);
  }
};

/**
 * @param {string} target hex string to validate
 * @param {string} expectedLength expected string length, >0
 * @throws {InvalidStringError}
 */
export const assertIsHexString = (target: string, expectedLength?: number): void => {
  assertLength(expectedLength, target);
  // eslint-disable-next-line wrap-regex
  if (!/^[\da-f]+$/i.test(target)) {
    throw new InvalidStringError('expected hex string');
  }
};

/**
 * @param {string} value hex string to validate
 * @param {string} length expected string length, >0
 * @throws {InvalidStringError}
 */
export const typedHex = <T>(value: string, length?: number): T => {
  assertIsHexString(value, length);
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  return value as any as T;
};

export type HexBlob = OpaqueString<'HexBlob'>;
export const HexBlob = (target: string): HexBlob => typedHex(target);
/**
 * Cast HexBlob it into another OpaqueString type.
 *
 * @param {HexBlob} target hex string to convert
 * @param {number} expectedLength optionally validate the length
 */
export const castHexBlob = <T>(target: HexBlob, expectedLength?: number) => {
  assertLength(expectedLength, target.toString());
  return target as unknown as T;
};

/**
 * 32 byte hash as hex string
 */
export type Hash32ByteBase16<T extends string = 'Hash32ByteBase16'> = OpaqueString<T>;

/**
 * @param {string} value 32 byte hash as hex string
 * @throws InvalidStringError
 */
export const Hash32ByteBase16 = <T extends string = 'Hash32ByteBase16'>(value: string): Hash32ByteBase16<T> =>
  typedHex<Hash32ByteBase16<T>>(value, 64);
Hash32ByteBase16.fromHexBlob = <T>(value: HexBlob) => castHexBlob<T>(value, 64);

/**
 * 28 byte hash as hex string
 */
export type Hash28ByteBase16<T extends string = 'Hash28ByteBase16'> = OpaqueString<T>;

/**
 * @param {string} value 28 byte hash as hex string
 * @throws InvalidStringError
 */
export const Hash28ByteBase16 = <T extends string = 'Hash28ByteBase16'>(value: string): Hash28ByteBase16<T> =>
  typedHex<Hash32ByteBase16<T>>(value, 56);
