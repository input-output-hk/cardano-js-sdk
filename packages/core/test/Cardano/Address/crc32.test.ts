import { crc32 } from '../../../src/Cardano/Address/crc32';

const bytes = (str: string) => new TextEncoder().encode(str);

describe('Cardano/Address/crc32', () => {
  // Canonical CRC-32/ISO-HDLC ("CRC-32/IEEE", zlib) check values, from the CRC RevEng catalogue:
  // https://reveng.sourceforge.io/crc-catalogue/all.htm#crc.cat.crc-32-iso-hdlc
  // ("123456789" -> 0xCBF43926). These pin the implementation bit-for-bit to the standard variant.
  it('returns 0 for empty input', () => {
    expect(crc32(new Uint8Array())).toBe(0);
  });

  it('matches the standard "123456789" check value (0xCBF43926)', () => {
    expect(crc32(bytes('123456789'))).toBe(0xcb_f4_39_26);
  });

  it('matches the "quick brown fox" vector (0x414FA339)', () => {
    expect(crc32(bytes('The quick brown fox jumps over the lazy dog'))).toBe(0x41_4f_a3_39);
  });

  it('matches the 0..255 byte-sequence vector (0x29058C73)', () => {
    expect(crc32(new Uint8Array(Array.from({ length: 256 }, (_, i) => i)))).toBe(0x29_05_8c_73);
  });

  it('returns an unsigned 32-bit integer', () => {
    const result = crc32(bytes('any payload'));
    expect(result).toBeGreaterThanOrEqual(0);
    expect(result).toBeLessThanOrEqual(0xff_ff_ff_ff);
    expect(Number.isInteger(result)).toBe(true);
  });

  it('is order-sensitive', () => {
    expect(crc32(bytes('ab'))).not.toBe(crc32(bytes('ba')));
  });
});
