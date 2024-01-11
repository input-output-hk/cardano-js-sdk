/* eslint-disable unicorn/number-literal-case */
import { add256bits, add28Mul8, le32 } from '../../src';

describe('add28Mul8V2', () => {
  it('adds two 256-bit numbers, but for the first 28 bytes, it multiplies the second number by 8 before adding', async () => {
    // Arrange
    const x = new Uint8Array(32).fill(1);
    const y = new Uint8Array(32).fill(2);

    // Expected Output:
    // The first 28 bytes should be 17 (1 + 2*8), and the remaining 4 bytes should be 1 (1 + 0 carry from multiplication).
    const expected = new Uint8Array(32).fill(17);
    expected.fill(1, 28);

    // Act
    const result = add28Mul8(x, y);

    // Assert
    expect(result).toEqual(expected);
  });
});

describe('add256bitsV2', () => {
  it('adds two 256-bit numbers (represented as Uint8Arrays).', async () => {
    // Arrange
    const x = new Uint8Array(32).fill(128);
    const y = new Uint8Array(32).fill(10);
    const expected = new Uint8Array(32).fill(138);

    // Act
    const result = add256bits(x, y);

    // Assert
    expect(result).toEqual(expected);
  });
});

describe('le32', () => {
  it('converts a 32-bit number into a little-endian Uint8Array.', async () => {
    // Arrange
    const i = 2_864_434_397;
    const expected = new Uint8Array([0xdd, 0xcc, 0xbb, 0xaa]);

    // Act
    const result = le32(i);

    // Assert
    expect(result).toEqual(expected);
  });
});
