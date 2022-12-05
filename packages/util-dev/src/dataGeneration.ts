/**
 * Generates a random byte array in hexadecimal value.
 *
 * @param size The size of the hex string in bytes.
 */
export const generateRandomHexString = (size: number) =>
  [...Array.from({ length: size })]
    .map(() => Math.floor(Math.random() * 16).toString(16))
    .join('')
    .toLowerCase();

/**
 * Generates a random BigInt number between two values.
 *
 * @param min The minimum value.
 * @param max The maximum value.
 */
export const generateRandomBigInt = (min: number, max: number): bigint =>
  BigInt(Math.floor(Math.random() * (max + 1 - min) + min));
