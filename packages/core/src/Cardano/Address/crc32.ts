/* eslint-disable no-bitwise */

/** Precomputed lookup table for the reflected CRC-32 polynomial `0xEDB88320`. */
const CRC32_TABLE = (() => {
  const table = new Uint32Array(256);
  for (let n = 0; n < 256; n++) {
    let c = n;
    for (let k = 0; k < 8; k++) {
      c = (c & 1) === 1 ? 0xed_b8_83_20 ^ (c >>> 1) : c >>> 1;
    }
    table[n] = c >>> 0;
  }
  return table;
})();

/**
 * Computes the CRC-32 checksum (IEEE 802.3 / zlib variant) of the given bytes.
 *
 * Reflected polynomial `0xEDB88320`, initial value `0xFFFFFFFF`, final XOR `0xFFFFFFFF`,
 * returned as an unsigned 32-bit integer. This is the checksum used by Byron-era address
 * encoding; verified bit-for-bit against the canonical CRC-32 test vectors (see `crc32.test.ts`).
 *
 * @param data The bytes to checksum.
 * @returns The unsigned 32-bit CRC-32 checksum.
 */
export const crc32 = (data: Uint8Array): number => {
  let crc = 0xff_ff_ff_ff;
  for (const datum of data) {
    crc = CRC32_TABLE[(crc ^ datum) & 0xff] ^ (crc >>> 8);
  }
  return (crc ^ 0xff_ff_ff_ff) >>> 0;
};
