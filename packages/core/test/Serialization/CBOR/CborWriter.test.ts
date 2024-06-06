/* eslint-disable no-bitwise */
/* eslint-disable unicorn/number-literal-case */
/* eslint-disable @typescript-eslint/no-explicit-any */

import { CborTag, CborWriter } from '../../../src/Serialization/index.js';

// Data points taken from https://tools.ietf.org/html/rfc7049#appendix-A
// Additional pairs generated using http://cbor.me/

describe('CborWriter', () => {
  describe('Array', () => {
    it('can write an empty fixed size array', async () => {
      const writer = new CborWriter();

      writer.writeStartArray(0);

      expect(writer.encodeAsHex()).toEqual('80');
    });

    it('can write fixed size array with an unsigned number', async () => {
      const writer = new CborWriter();

      writer.writeStartArray(1);
      writer.writeInt(42);

      expect(writer.encodeAsHex()).toEqual('81182a');
    });

    it('can write a fixed size array with several unsigned numbers', async () => {
      const writer = new CborWriter();

      writer.writeStartArray(25);

      for (let i = 0; i < 25; ++i) {
        writer.writeInt(i + 1);
      }

      expect(writer.encodeAsHex()).toEqual('98190102030405060708090a0b0c0d0e0f101112131415161718181819');
    });

    it('can write a fixed size array with mixed types', async () => {
      const writer = new CborWriter();

      writer.writeStartArray(4);
      writer.writeInt(1);
      writer.writeInt(-1);
      writer.writeTextString('');
      writer.writeByteString(new Uint8Array([7]));

      expect(writer.encodeAsHex()).toEqual('840120604107');
    });

    it('can write a fixed size array of strings', async () => {
      const writer = new CborWriter();

      writer.writeStartArray(3);
      writer.writeTextString('lorem');
      writer.writeTextString('ipsum');
      writer.writeTextString('dolor');

      expect(writer.encodeAsHex()).toEqual('83656c6f72656d65697073756d65646f6c6f72');
    });

    it('can write a fixed size array of simple values', async () => {
      const writer = new CborWriter();

      writer.writeStartArray(4);
      writer.writeBoolean(false);
      writer.writeNull();
      writer.writeFloat(Number.NaN);
      writer.writeFloat(Number.POSITIVE_INFINITY);

      expect(writer.encodeAsHex()).toEqual('84f4f6faffc00000fb7ff0000000000000');
    });

    it('can write a fixed size array with nested values', async () => {
      const writer = new CborWriter();

      writer.writeStartArray(3);
      writer.writeInt(1);
      writer.writeStartArray(2);
      writer.writeInt(2);
      writer.writeInt(3);
      writer.writeStartArray(2);
      writer.writeInt(4);
      writer.writeInt(5);

      expect(writer.encodeAsHex()).toEqual('8301820203820405');
    });

    it('can write an empty indefinite length array', async () => {
      const writer = new CborWriter();

      writer.writeStartArray();
      writer.writeEndArray();

      expect(writer.encodeAsHex()).toEqual('9fff');
    });

    it('can write an indefinite length array with an unsigned number', async () => {
      const writer = new CborWriter();

      writer.writeStartArray();
      writer.writeInt(42);
      writer.writeEndArray();

      expect(writer.encodeAsHex()).toEqual('9f182aff');
    });

    it('can read indefinite length array with several unsigned numbers', async () => {
      const writer = new CborWriter();

      writer.writeStartArray();

      for (let i = 0; i < 25; ++i) {
        writer.writeInt(i + 1);
      }

      writer.writeEndArray();

      expect(writer.encodeAsHex()).toEqual('9f0102030405060708090a0b0c0d0e0f101112131415161718181819ff');
    });
  });

  describe('ByteString', () => {
    it('can write an empty fixed size ByteString', async () => {
      const writer = new CborWriter();

      writer.writeByteString(new Uint8Array([]));

      expect(writer.encodeAsHex()).toEqual('40');
    });

    it('can write a non empty fixed size ByteString', async () => {
      let writer = new CborWriter();

      writer.writeByteString(new Uint8Array([0x01, 0x02, 0x03, 0x04]));

      expect(writer.encodeAsHex()).toEqual('4401020304');

      writer = new CborWriter();

      const array = new Uint8Array(14);

      for (let i = 0; i < 14; ++i) array[i] = 0xff;

      writer.writeByteString(array);

      expect(writer.encodeAsHex()).toEqual('4effffffffffffffffffffffffffff');
    });
  });

  describe('Integer', () => {
    it('can write unsigned integers', async () => {
      expect(new CborWriter().writeInt(0).encodeAsHex()).toEqual('00');
      expect(new CborWriter().writeInt(1).encodeAsHex()).toEqual('01');
      expect(new CborWriter().writeInt(10).encodeAsHex()).toEqual('0a');
      expect(new CborWriter().writeInt(23).encodeAsHex()).toEqual('17');
      expect(new CborWriter().writeInt(24).encodeAsHex()).toEqual('1818');
      expect(new CborWriter().writeInt(25).encodeAsHex()).toEqual('1819');
      expect(new CborWriter().writeInt(100).encodeAsHex()).toEqual('1864');
      expect(new CborWriter().writeInt(1000).encodeAsHex()).toEqual('1903e8');
      expect(new CborWriter().writeInt(1_000_000).encodeAsHex()).toEqual('1a000f4240');
      expect(new CborWriter().writeInt(1_000_000_000_000).encodeAsHex()).toEqual('1b000000e8d4a51000');
      expect(new CborWriter().writeInt(255).encodeAsHex()).toEqual('18ff');
      expect(new CborWriter().writeInt(256).encodeAsHex()).toEqual('190100');
      expect(new CborWriter().writeInt(4_294_967_295).encodeAsHex()).toEqual('1affffffff');
      expect(new CborWriter().writeInt(9_223_372_036_854_775_807n).encodeAsHex()).toEqual('1b7fffffffffffffff');
      expect(new CborWriter().writeInt(4_294_967_296).encodeAsHex()).toEqual('1b0000000100000000');
      expect(new CborWriter().writeInt(65_535).encodeAsHex()).toEqual('19ffff');
      expect(new CborWriter().writeInt(65_536).encodeAsHex()).toEqual('1a00010000');
    });

    it('can write negative integers', async () => {
      expect(new CborWriter().writeInt(-1).encodeAsHex()).toEqual('20');
      expect(new CborWriter().writeInt(-10).encodeAsHex()).toEqual('29');
      expect(new CborWriter().writeInt(-24).encodeAsHex()).toEqual('37');
      expect(new CborWriter().writeInt(-100).encodeAsHex()).toEqual('3863');
      expect(new CborWriter().writeInt(-1000).encodeAsHex()).toEqual('3903e7');
      expect(new CborWriter().writeInt(-256).encodeAsHex()).toEqual('38ff');
      expect(new CborWriter().writeInt(-257).encodeAsHex()).toEqual('390100');
      expect(new CborWriter().writeInt(-65_536).encodeAsHex()).toEqual('39ffff');
      expect(new CborWriter().writeInt(-65_537).encodeAsHex()).toEqual('3a00010000');
      expect(new CborWriter().writeInt(-4_294_967_296).encodeAsHex()).toEqual('3affffffff');
      expect(new CborWriter().writeInt(-4_294_967_297).encodeAsHex()).toEqual('3b0000000100000000');
      expect(new CborWriter().writeInt(-9_223_372_036_854_775_808n).encodeAsHex()).toEqual('3b7fffffffffffffff');
    });
  });

  describe('Simple', () => {
    it('can write float values', async () => {
      expect(new CborWriter().writeFloat(0).encodeAsHex()).toEqual('fa00000000');
      expect(new CborWriter().writeFloat(-0).encodeAsHex()).toEqual('fa80000000');
      expect(new CborWriter().writeFloat(1).encodeAsHex()).toEqual('f93c00');
      expect(new CborWriter().writeFloat(1.5).encodeAsHex()).toEqual('f93e00');
      expect(new CborWriter().writeFloat(65_504).encodeAsHex()).toEqual('f97bff');
      expect(new CborWriter().writeFloat(5.960_464_477_539_063e-8).encodeAsHex()).toEqual('f90001');
      expect(new CborWriter().writeFloat(0.000_061_035_156_25).encodeAsHex()).toEqual('f90400');
      expect(new CborWriter().writeFloat(-4).encodeAsHex()).toEqual('f9c400');
      expect(new CborWriter().writeFloat(3.402_823_466_385_288_6e+38).encodeAsHex()).toEqual('fa7f7fffff');
      expect(new CborWriter().writeFloat(3.402_823_466_385_288_6e+38).encodeAsHex()).toEqual('fa7f7fffff');
    });

    it('can write null values', async () => {
      expect(new CborWriter().writeNull().encodeAsHex()).toEqual('f6');
    });

    it('can read boolean values', async () => {
      expect(new CborWriter().writeBoolean(false).encodeAsHex()).toEqual('f4');
      expect(new CborWriter().writeBoolean(true).encodeAsHex()).toEqual('f5');
    });
  });

  describe('Tag', () => {
    it('can write single tagged string value', async () => {
      const writer = new CborWriter();

      writer.writeTag(CborTag.DateTimeString);
      writer.writeTextString('2013-03-21T20:04:00Z');

      expect(writer.encodeAsHex()).toEqual('c074323031332d30332d32315432303a30343a30305a');
    });

    it('can write single tagged unix time seconds value', async () => {
      const writer = new CborWriter();

      writer.writeTag(CborTag.UnixTimeSeconds);
      writer.writeInt(1_363_896_240);

      expect(writer.encodeAsHex()).toEqual('c11a514b67b0');
    });

    it('can write single tagged unsigned bignum value', async () => {
      const writer = new CborWriter();

      writer.writeTag(CborTag.UnsignedBigNum);
      writer.writeInt(2n);

      expect(writer.encodeAsHex()).toEqual('c202');
    });

    it('can write single tagged base 16 value', async () => {
      const writer = new CborWriter();

      writer.writeTag(CborTag.Base16StringLaterEncoding);
      writer.writeByteString(new Uint8Array([1, 2, 3, 4]));

      expect(writer.encodeAsHex()).toEqual('d74401020304');
    });

    it('can write single tagged uri value', async () => {
      const writer = new CborWriter();

      writer.writeTag(CborTag.Uri);
      writer.writeTextString('http://www.example.com');

      expect(writer.encodeAsHex()).toEqual('d82076687474703a2f2f7777772e6578616d706c652e636f6d');
    });

    it('can write nested tagged values', async () => {
      const writer = new CborWriter();

      writer.writeTag(CborTag.DateTimeString);
      writer.writeTag(CborTag.DateTimeString);
      writer.writeTag(CborTag.DateTimeString);

      writer.writeTextString('2013-03-21T20:04:00Z');

      expect(writer.encodeAsHex()).toEqual('c0c0c074323031332d30332d32315432303a30343a30305a');
    });
  });

  describe('TextString', () => {
    it('can write fixed length text strings', async () => {
      expect(new CborWriter().writeTextString('').encodeAsHex()).toEqual('60');
      expect(new CborWriter().writeTextString('a').encodeAsHex()).toEqual('6161');
      expect(new CborWriter().writeTextString('IETF').encodeAsHex()).toEqual('6449455446');
      expect(new CborWriter().writeTextString('"\\').encodeAsHex()).toEqual('62225c');
      expect(new CborWriter().writeTextString('\u00FC').encodeAsHex()).toEqual('62c3bc');
      expect(new CborWriter().writeTextString('\u6C34').encodeAsHex()).toEqual('63e6b0b4');
      expect(new CborWriter().writeTextString('\u03BB').encodeAsHex()).toEqual('62cebb');
      expect(new CborWriter().writeTextString('\uD800\uDD51').encodeAsHex()).toEqual('64f0908591');
    });
  });

  describe('Map', () => {
    it('can write empty maps', async () => {
      const writer = new CborWriter();

      writer.writeStartMap(0);

      expect(writer.encodeAsHex()).toEqual('a0');
    });

    it('can write fixed length maps with numbers', async () => {
      const writer = new CborWriter();

      writer.writeStartMap(2);
      // Key.Val
      writer.writeInt(1).writeInt(2);
      writer.writeInt(3).writeInt(4);

      expect(writer.encodeAsHex()).toEqual('a201020304');
    });

    it('can write fixed length maps with strings', async () => {
      const writer = new CborWriter();

      writer.writeStartMap(5);
      // Key.Val
      writer.writeTextString('a').writeTextString('A');
      writer.writeTextString('b').writeTextString('B');
      writer.writeTextString('c').writeTextString('C');
      writer.writeTextString('d').writeTextString('D');
      writer.writeTextString('e').writeTextString('E');

      expect(writer.encodeAsHex()).toEqual('a56161614161626142616361436164614461656145');
    });

    it('can write fixed length maps with mixed types', async () => {
      const writer = new CborWriter();

      writer.writeStartMap(3);
      writer.writeTextString('a');
      writer.writeTextString('A');
      writer.writeInt(-1);
      writer.writeInt(2);
      writer.writeByteString(new Uint8Array([]));
      writer.writeByteString(new Uint8Array([1]));

      expect(writer.encodeAsHex()).toEqual('a3616161412002404101');
    });

    it('can write fixed length maps with nested types', async () => {
      const writer = new CborWriter();

      writer.writeStartMap(2);

      writer.writeTextString('a');
      writer.writeStartMap(1);
      writer.writeInt(2);
      writer.writeInt(3);

      writer.writeTextString('b');
      writer.writeStartMap(2);
      writer.writeTextString('x');
      writer.writeInt(-1);
      writer.writeTextString('y');
      writer.writeStartMap(1);
      writer.writeTextString('z');
      writer.writeInt(0);

      expect(writer.encodeAsHex()).toEqual('a26161a102036162a26178206179a1617a00');
    });

    it('can write empty indefinite length maps', async () => {
      const writer = new CborWriter();

      writer.writeStartMap();
      writer.writeEndMap();

      expect(writer.encodeAsHex()).toEqual('bfff');
    });

    it('can write indefinite length maps', async () => {
      const writer = new CborWriter();

      writer.writeStartMap();

      // Key.Val
      writer.writeTextString('a').writeTextString('A');
      writer.writeTextString('b').writeTextString('B');
      writer.writeTextString('c').writeTextString('C');
      writer.writeTextString('d').writeTextString('D');
      writer.writeTextString('e').writeTextString('E');

      writer.writeEndMap();

      expect(writer.encodeAsHex()).toEqual('bf6161614161626142616361436164614461656145ff');
    });

    it('can write indefinite length maps with mixed types', async () => {
      const writer = new CborWriter();

      writer.writeStartMap();
      writer.writeTextString('a');
      writer.writeTextString('A');
      writer.writeInt(-1);
      writer.writeInt(2);
      writer.writeByteString(new Uint8Array([]));
      writer.writeByteString(new Uint8Array([1]));
      writer.writeEndMap();

      expect(writer.encodeAsHex()).toEqual('bf616161412002404101ff');
    });
  });
});
