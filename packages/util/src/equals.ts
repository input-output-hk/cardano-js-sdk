import isEqual from 'lodash/isEqual.js';

export const deepEquals = <T>(a: T, b: T) => isEqual(a, b);

export const strictEquals = <T>(a: T, b: T) => a === b;

export const sameArrayItems = <T>(arrayA: T[], arrayB: T[], itemEquals: (a: T, b: T) => boolean) =>
  arrayA.length === arrayB.length && arrayA.every((a) => arrayB.some((b) => itemEquals(a, b)));

/**
 * Performs a constant-time comparison of two number values to mitigate timing attacks (CWE-208).
 *
 * This function prevents timing attacks by ensuring that the time it takes to compare two number values
 * is consistent, regardless of the values being compared because all bits are compared using XOR operator
 *
 * @param {number} a - The first number value to compare.
 * @param {number} b - The second number value to compare.
 * @returns {boolean} - Returns true if both number values are identical, otherwise returns false.
 */
export const areNumbersEqualInConstantTime = (a: number, b: number): boolean => (a ^ b) === 0;

/**
 * Performs a constant-time comparison of two strings to mitigate timing attacks (CWE-208).
 *
 * This function is designed to prevent timing attacks by ensuring that the time it takes to compare two strings
 * does not depend on the contents of the strings themselves. It achieves this by comparing all characters
 * up to the length of the longer string, treating out-of-bounds characters as zeros, and using bitwise operations
 * to maintain constant time execution.
 *
 * @param {string} a - The first string to compare.
 * @param {string} b - The second string to compare.
 * @returns {boolean} - Returns true if the strings are identical, false otherwise.
 */
export const areStringsEqualInConstantTime = (a: string, b: string): boolean => {
  // Calculate the maximum length of the two strings. This value will be used to loop through each character.
  const maxLength = Math.max(a.length, b.length);

  // It loops through the maximum length of the two strings, ensuring that the iteration count doesn't leak information about the length difference.
  const results: (0 | 1)[] = Array.from(
    { length: maxLength },
    (_, i) => (a.charCodeAt(i) === b.charCodeAt(i) ? 1 : 0) // Return 1 if the characters are equal, otherwise return 0.
  );

  // Reduce the results array to a single value, using bitwise AND, explicitly casting the result as binary 0 | 1.
  // We do not use booleans here (true/false) instead 0 and 1 because bitwise operations in JavaScript operate on 32-bit integers.
  const areAllCharactersEqual = results.reduce(
    (accumulator, currentValue) => (accumulator & currentValue) as 0 | 1, // Cast to 0 | 1 to satisfy TypeScript's strict type checking.
    1
  );

  return areAllCharactersEqual === 1; // Return `true` if all characters matched, otherwise `false`.
};
