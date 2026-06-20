import {
  byteArrayToIPv6String,
  byteArrayToIpV4String,
  ipV4StringToByteArray,
  ipV6StringToByteArray
} from '../../../../src/Serialization/Certificates/PoolParams/Relay/ipUtils';

// These vectors were verified byte-for-byte against the previously-used `ip-address` library
// across the full corpus below (validation, expansion and canonical formatting) before the
// dependency was replaced with the local implementation.

describe('PoolParams/Relay/ipUtils', () => {
  describe('IPv4', () => {
    it('round-trips a valid address', () => {
      expect(ipV4StringToByteArray('10.3.2.10')).toEqual(new Uint8Array([10, 3, 2, 10]));
      expect(byteArrayToIpV4String(new Uint8Array([10, 3, 2, 10]))).toBe('10.3.2.10');
    });

    it('handles the bounds', () => {
      expect(ipV4StringToByteArray('0.0.0.0')).toEqual(new Uint8Array([0, 0, 0, 0]));
      expect(ipV4StringToByteArray('255.255.255.255')).toEqual(new Uint8Array([255, 255, 255, 255]));
    });

    it.each(['256.1.1.1', '1.2.3', '1.2.3.4.5', 'a.b.c.d', '', '1.2.3.'])('rejects invalid string %p', (invalid) => {
      expect(() => ipV4StringToByteArray(invalid)).toThrow('Invalid IP V4 string');
    });

    it('rejects a byte array of the wrong length', () => {
      expect(() => byteArrayToIpV4String(new Uint8Array([1, 2, 3]))).toThrow('expected 4 bytes');
    });
  });

  describe('IPv6', () => {
    it('expands a fully-written address to 16 bytes', () => {
      expect(ipV6StringToByteArray('0102:0304:0102:0304:0102:0304:0102:0304')).toEqual(
        new Uint8Array([1, 2, 3, 4, 1, 2, 3, 4, 1, 2, 3, 4, 1, 2, 3, 4])
      );
    });

    it('expands a `::` compressed address', () => {
      expect(ipV6StringToByteArray('::1')).toEqual(new Uint8Array([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1]));
      expect(ipV6StringToByteArray('::')).toEqual(new Uint8Array(16));
    });

    it('expands an IPv4-mapped address', () => {
      // ::ffff:10.3.2.10 -> ...:ffff:0a03:020a
      expect(ipV6StringToByteArray('::ffff:10.3.2.10')).toEqual(
        new Uint8Array([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0xff, 0xff, 0x0a, 0x03, 0x02, 0x0a])
      );
    });

    it.each(['1::2::3', 'xyz::', '12345::', '2001:db8:::1', '', ':::'])('rejects invalid string %p', (invalid) => {
      expect(() => ipV6StringToByteArray(invalid)).toThrow('Invalid IP V6 string');
    });

    it('formats bytes as a non-shortened canonical string', () => {
      expect(
        byteArrayToIPv6String(new Uint8Array([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0xff, 0xff, 0x0a, 0x03, 0x02, 0x0a]))
      ).toBe('0000:0000:0000:0000:0000:ffff:0a03:020a');
      expect(byteArrayToIPv6String(new Uint8Array([1, 2, 3, 4, 1, 2, 3, 4, 1, 2, 3, 4, 1, 2, 3, 4]))).toBe(
        '0102:0304:0102:0304:0102:0304:0102:0304'
      );
    });

    it('round-trips string -> bytes -> canonical string', () => {
      const canonical = '0000:0000:0000:0000:0000:ffff:0a03:020a';
      expect(byteArrayToIPv6String(ipV6StringToByteArray('::ffff:10.3.2.10'))).toBe(canonical);
      expect(byteArrayToIPv6String(ipV6StringToByteArray(canonical))).toBe(canonical);
    });
  });
});
