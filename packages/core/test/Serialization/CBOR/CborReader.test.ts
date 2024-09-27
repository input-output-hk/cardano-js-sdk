/* eslint-disable no-bitwise */
/* eslint-disable unicorn/number-literal-case */
/* eslint-disable @typescript-eslint/no-explicit-any */

import { CborReader, CborReaderState, CborSimpleValue, CborTag } from '../../../src/Serialization';
import { HexBlob } from '@cardano-sdk/util';

const areEqual = (first: Uint8Array, second: Uint8Array) =>
  first.length === second.length && first.every((value, index) => value === second[index]);

const verifyInt = (hex: string, expectedVal: bigint, expectedState: CborReaderState) => {
  const reader = new CborReader(HexBlob(hex));
  expect(reader.peekState()).toBe(expectedState);
  expect(reader.readInt()).toEqual(expectedVal);
  expect(reader.peekState()).toBe(CborReaderState.Finished);
};

const verifyFloat = (hex: string, expectedVal: number, expectedState: CborReaderState) => {
  const reader = new CborReader(HexBlob(hex));
  expect(reader.peekState()).toBe(expectedState);
  expect(reader.readDouble()).toEqual(expectedVal);
  expect(reader.peekState()).toBe(CborReaderState.Finished);
};

const verifyText = (hex: string, expectedVal: string, expectedState: CborReaderState) => {
  const reader = new CborReader(HexBlob(hex));
  expect(reader.peekState()).toBe(expectedState);
  expect(reader.readTextString()).toEqual(expectedVal);
  expect(reader.peekState()).toBe(CborReaderState.Finished);
};

const getVal = (reader: CborReader): string | bigint | number[] | Map<any, any> | undefined => {
  switch (reader.peekState()) {
    case CborReaderState.ByteString:
      return [...reader.readByteString()];
    case CborReaderState.TextString:
      return reader.readTextString();
    case CborReaderState.NegativeInteger:
    case CborReaderState.UnsignedInteger:
      return reader.readInt();
    case CborReaderState.StartMap: {
      const map = new Map();
      const length = reader.readStartMap();

      // Indefinite length map
      if (length === null) {
        while (reader.peekState() !== CborReaderState.EndMap) {
          map.set(getVal(reader), getVal(reader));
        }
      } else {
        for (let i = 0; i < length!; ++i) {
          map.set(getVal(reader), getVal(reader));
        }
      }

      reader.readEndMap();

      return map;
    }
  }

  return undefined;
};

// Data points taken from https://tools.ietf.org/html/rfc7049#appendix-A
// Additional pairs generated using http://cbor.me/

describe('CborReader', () => {
  describe('Array', () => {
    it('can read an empty fixed size array', async () => {
      const reader = new CborReader(HexBlob('80'));

      expect(reader.peekState()).toBe(CborReaderState.StartArray);

      const length = reader.readStartArray();

      expect(length).toBe(0);
      expect(reader.peekState()).toBe(CborReaderState.EndArray);

      reader.readEndArray();

      expect(reader.peekState()).toBe(CborReaderState.Finished);
    });

    it('can read fixed size array with an unsigned number', async () => {
      const reader = new CborReader(HexBlob('81182a'));

      expect(reader.peekState()).toBe(CborReaderState.StartArray);

      const length = reader.readStartArray();

      expect(length).toBe(1);
      expect(reader.peekState()).toBe(CborReaderState.UnsignedInteger);

      const number = reader.readUInt();

      expect(number).toBe(42n);
      expect(reader.peekState()).toBe(CborReaderState.EndArray);

      reader.readEndArray();

      expect(reader.peekState()).toBe(CborReaderState.Finished);
    });

    it('can read fixed size array with several unsigned numbers', async () => {
      const reader = new CborReader(HexBlob('98190102030405060708090a0b0c0d0e0f101112131415161718181819'));

      expect(reader.peekState()).toBe(CborReaderState.StartArray);

      const length = reader.readStartArray();

      expect(length).toBe(25);

      for (let i = 0; i < length!; ++i) {
        expect(reader.peekState()).toBe(CborReaderState.UnsignedInteger);

        const number = reader.readUInt();

        expect(number).toBe(BigInt(i + 1));
      }

      expect(reader.peekState()).toBe(CborReaderState.EndArray);
      reader.readEndArray();

      expect(reader.peekState()).toBe(CborReaderState.Finished);
    });

    it('can read fixed size array with several unsigned 64bits numbers', async () => {
      const reader = new CborReader(HexBlob('831BCD2FB6B45D4CF7B01BCD2FB6B45D4CF7B11BCD2FB6B45D4CF7B2'));

      expect(reader.peekState()).toBe(CborReaderState.StartArray);

      const length = reader.readStartArray();

      expect(length).toBe(3);

      for (let i = 0; i < length!; ++i) {
        expect(reader.peekState()).toBe(CborReaderState.UnsignedInteger);

        const number = reader.readUInt();

        expect(number).toBe(14_785_236_987_456_321_456n + BigInt(i));
      }

      expect(reader.peekState()).toBe(CborReaderState.EndArray);
      reader.readEndArray();

      expect(reader.peekState()).toBe(CborReaderState.Finished);
    });

    it('can read fixed size array with mixed types', async () => {
      const reader = new CborReader(HexBlob('840120604107'));

      expect(reader.peekState()).toBe(CborReaderState.StartArray);

      expect(reader.readStartArray()).toBe(4);

      expect(reader.peekState()).toBe(CborReaderState.UnsignedInteger);
      expect(reader.readUInt()).toBe(1n);

      expect(reader.peekState()).toBe(CborReaderState.NegativeInteger);
      expect(reader.readInt()).toBe(-1n);

      expect(reader.peekState()).toBe(CborReaderState.TextString);
      expect(reader.readTextString()).toBe('');

      expect(reader.peekState()).toBe(CborReaderState.ByteString);
      expect(areEqual(reader.readByteString(), new Uint8Array([7]))).toBeTruthy();

      expect(reader.peekState()).toBe(CborReaderState.EndArray);
      reader.readEndArray();
      expect(reader.peekState()).toBe(CborReaderState.Finished);
    });

    it('can read fixed size array of strings', async () => {
      const reader = new CborReader(HexBlob('83656c6f72656d65697073756d65646f6c6f72'));

      expect(reader.peekState()).toBe(CborReaderState.StartArray);

      expect(reader.readStartArray()).toBe(3);

      expect(reader.peekState()).toBe(CborReaderState.TextString);
      expect(reader.readTextString()).toBe('lorem');

      expect(reader.peekState()).toBe(CborReaderState.TextString);
      expect(reader.readTextString()).toBe('ipsum');

      expect(reader.peekState()).toBe(CborReaderState.TextString);
      expect(reader.readTextString()).toBe('dolor');

      expect(reader.peekState()).toBe(CborReaderState.EndArray);
      reader.readEndArray();
      expect(reader.peekState()).toBe(CborReaderState.Finished);
    });

    it('can read fixed size array of simple values', async () => {
      const reader = new CborReader(HexBlob('84f4f6faffc00000fb7ff0000000000000'));

      expect(reader.peekState()).toBe(CborReaderState.StartArray);

      expect(reader.readStartArray()).toBe(4);

      expect(reader.peekState()).toBe(CborReaderState.Boolean);
      expect(reader.readBoolean()).toBeFalsy();

      expect(reader.peekState()).toBe(CborReaderState.Null);
      reader.readNull();

      expect(reader.peekState()).toBe(CborReaderState.SinglePrecisionFloat);
      expect(reader.readDouble()).toBe(Number.NaN);

      expect(reader.peekState()).toBe(CborReaderState.DoublePrecisionFloat);
      expect(reader.readDouble()).toBe(Number.POSITIVE_INFINITY);

      expect(reader.peekState()).toBe(CborReaderState.EndArray);
      reader.readEndArray();
      expect(reader.peekState()).toBe(CborReaderState.Finished);
    });

    it('can read a fixed size array with nested values', async () => {
      const reader = new CborReader(HexBlob('8301820203820405'));

      expect(reader.peekState()).toBe(CborReaderState.StartArray);
      expect(reader.readStartArray()).toBe(3);

      expect(reader.readInt()).toBe(1n);

      expect(reader.peekState()).toBe(CborReaderState.StartArray);
      expect(reader.readStartArray()).toBe(2);
      expect(reader.readInt()).toBe(2n);
      expect(reader.readInt()).toBe(3n);
      expect(reader.peekState()).toBe(CborReaderState.EndArray);
      reader.readEndArray();

      expect(reader.peekState()).toBe(CborReaderState.StartArray);
      expect(reader.readStartArray()).toBe(2);
      expect(reader.readInt()).toBe(4n);
      expect(reader.readInt()).toBe(5n);
      expect(reader.peekState()).toBe(CborReaderState.EndArray);
      reader.readEndArray();

      expect(reader.peekState()).toBe(CborReaderState.EndArray);
      reader.readEndArray();

      expect(reader.peekState()).toBe(CborReaderState.Finished);
    });

    it('can read an empty indefinite length array', async () => {
      const reader = new CborReader(HexBlob('9fff'));

      expect(reader.peekState()).toBe(CborReaderState.StartArray);
      expect(reader.readStartArray()).toBe(null);
      expect(reader.peekState()).toBe(CborReaderState.EndArray);
      reader.readEndArray();

      expect(reader.peekState()).toBe(CborReaderState.Finished);
    });

    it('can read indefinite length array with an unsigned number', async () => {
      const reader = new CborReader(HexBlob('9f182aff'));

      expect(reader.peekState()).toBe(CborReaderState.StartArray);
      expect(reader.readStartArray()).toBe(null);

      expect(reader.peekState()).toBe(CborReaderState.UnsignedInteger);
      const number = reader.readUInt();
      expect(number).toBe(42n);

      expect(reader.peekState()).toBe(CborReaderState.EndArray);

      reader.readEndArray();

      expect(reader.peekState()).toBe(CborReaderState.Finished);
    });

    it('can read indefinite length array with several unsigned numbers', async () => {
      const reader = new CborReader(HexBlob('9f0102030405060708090a0b0c0d0e0f101112131415161718181819ff'));

      expect(reader.peekState()).toBe(CborReaderState.StartArray);
      expect(reader.readStartArray()).toBe(null);

      let count = 0n;

      while (reader.peekState() !== CborReaderState.EndArray) {
        ++count;
        expect(reader.peekState()).toBe(CborReaderState.UnsignedInteger);
        const number = reader.readUInt();
        expect(number).toBe(BigInt(count));
      }

      reader.readEndArray();

      expect(count).toBe(25n);
      expect(reader.peekState()).toBe(CborReaderState.Finished);
    });
  });

  describe('ByteString', () => {
    it('can read an empty fixed size ByteString', async () => {
      const reader = new CborReader(HexBlob('40'));

      expect(reader.peekState()).toBe(CborReaderState.ByteString);
      expect(reader.readByteString().length).toEqual(0);
      expect(reader.peekState()).toBe(CborReaderState.Finished);
    });

    it('can read a non empty fixed size ByteString', async () => {
      let reader = new CborReader(HexBlob('4401020304'));

      expect(reader.peekState()).toBe(CborReaderState.ByteString);
      let array = reader.readByteString();
      expect(array.length).toEqual(4);
      expect(Buffer.from(array).toString('hex')).toEqual('01020304');
      expect(reader.peekState()).toBe(CborReaderState.Finished);

      reader = new CborReader(HexBlob('4effffffffffffffffffffffffffff'));

      expect(reader.peekState()).toBe(CborReaderState.ByteString);
      array = reader.readByteString();
      expect(array.length).toEqual(14);
      expect(Buffer.from(array).toString('hex')).toEqual('ffffffffffffffffffffffffffff');
      expect(reader.peekState()).toBe(CborReaderState.Finished);
    });

    it('can read an empty indefinite size ByteString', async () => {
      let reader = new CborReader(HexBlob('5fff'));

      expect(reader.peekState()).toBe(CborReaderState.StartIndefiniteLengthByteString);
      expect(reader.readByteString().length).toEqual(0);
      expect(reader.peekState()).toBe(CborReaderState.Finished);

      reader = new CborReader(HexBlob('5f40ff'));

      expect(reader.peekState()).toBe(CborReaderState.StartIndefiniteLengthByteString);
      expect(reader.readByteString().length).toEqual(0);
      expect(reader.peekState()).toBe(CborReaderState.Finished);
    });

    it('can read a non empty indefinite size ByteString', async () => {
      let reader = new CborReader(HexBlob('5f41ab40ff'));

      expect(reader.peekState()).toBe(CborReaderState.StartIndefiniteLengthByteString);
      let array = reader.readByteString();
      expect(array.length).toEqual(1);
      expect(Buffer.from(array).toString('hex')).toEqual('ab');
      expect(reader.peekState()).toBe(CborReaderState.Finished);

      reader = new CborReader(HexBlob('5f41ab41bc40ff'));

      expect(reader.peekState()).toBe(CborReaderState.StartIndefiniteLengthByteString);
      array = reader.readByteString();
      expect(array.length).toEqual(2);
      expect(Buffer.from(array).toString('hex')).toEqual('abbc');
      expect(reader.peekState()).toBe(CborReaderState.Finished);

      reader = new CborReader(
        HexBlob(
          '5f' +
            '584064676273786767746F6768646A7074657476746B636F6376796669647171676775726A687268716169697370717275656C687679707178656577707279667677' +
            '584064676273786767746F6768646A7074657476746B636F6376796669647171676775726A687268716169697370717275656C687679707178656577707279667677' +
            '584064676273786767746F6768646A7074657476746B636F6376796669647171676775726A687268716169697370717275656C687679707178656577707279667677' +
            '584064676273786767746F6768646A7074657476746B636F6376796669647171676775726A687268716169697370717275656C687679707178656577707279667677' +
            'ff'
        )
      );

      expect(reader.peekState()).toBe(CborReaderState.StartIndefiniteLengthByteString);
      array = reader.readByteString();
      expect(array.length).toEqual(256);
      expect(Buffer.from(array).toString('hex')).toEqual(
        '64676273786767746f6768646a7074657476746b636f6376796669647171676775726a687268716169697370717275656c687679707178656577707279667677' +
          '64676273786767746f6768646a7074657476746b636f6376796669647171676775726a687268716169697370717275656c687679707178656577707279667677' +
          '64676273786767746f6768646a7074657476746b636f6376796669647171676775726a687268716169697370717275656c687679707178656577707279667677' +
          '64676273786767746f6768646a7074657476746b636f6376796669647171676775726a687268716169697370717275656c687679707178656577707279667677'
      );
      expect(reader.peekState()).toBe(CborReaderState.Finished);

      reader = new CborReader(
        HexBlob(
          '5f584037d34fac60a7dd2edba0c76fa58862c91c45ff4298e9134ba8e76be9a7513d88865bfdb9315073dc2690b0f2b59a232fbfa0a8a504df6ee9bb78e3f33fbdfef95529c9e74ff30ffe1bd1cc5795c37535899dba800000ff'
        )
      );

      expect(reader.peekState()).toBe(CborReaderState.StartIndefiniteLengthByteString);
      array = reader.readByteString();
      expect(array.length).toEqual(85);
      expect(Buffer.from(array).toString('hex')).toEqual(
        '37d34fac60a7dd2edba0c76fa58862c91c45ff4298e9134ba8e76be9a7513d88865bfdb9315073dc2690b0f2b59a232fbfa0a8a504df6ee9bb78e3f33fbdfef929c9e74ff30ffe1bd1cc5795c37535899dba800000'
      );
      expect(reader.peekState()).toBe(CborReaderState.Finished);
    });
  });

  describe('Integer', () => {
    it('can read unsigned integers', async () => {
      verifyInt('00', 0n, CborReaderState.UnsignedInteger);
      verifyInt('01', 1n, CborReaderState.UnsignedInteger);
      verifyInt('0a', 10n, CborReaderState.UnsignedInteger);
      verifyInt('17', 23n, CborReaderState.UnsignedInteger);
      verifyInt('1818', 24n, CborReaderState.UnsignedInteger);
      verifyInt('1819', 25n, CborReaderState.UnsignedInteger);
      verifyInt('1864', 100n, CborReaderState.UnsignedInteger);
      verifyInt('1903e8', 1000n, CborReaderState.UnsignedInteger);
      verifyInt('1a000f4240', 1_000_000n, CborReaderState.UnsignedInteger);
      verifyInt('1b000000e8d4a51000', 1_000_000_000_000n, CborReaderState.UnsignedInteger);
      verifyInt('18ff', 255n, CborReaderState.UnsignedInteger);
      verifyInt('190100', 256n, CborReaderState.UnsignedInteger);
      verifyInt('1affffffff', 4_294_967_295n, CborReaderState.UnsignedInteger);
      verifyInt('1b7fffffffffffffff', 9_223_372_036_854_775_807n, CborReaderState.UnsignedInteger);
      verifyInt('1b0000000100000000', 4_294_967_296n, CborReaderState.UnsignedInteger);
      verifyInt('19ffff', 65_535n, CborReaderState.UnsignedInteger);
      verifyInt('1a00010000', 65_536n, CborReaderState.UnsignedInteger);
    });

    it('can read negative integers', async () => {
      verifyInt('20', -1n, CborReaderState.NegativeInteger);
      verifyInt('29', -10n, CborReaderState.NegativeInteger);
      verifyInt('37', -24n, CborReaderState.NegativeInteger);
      verifyInt('3863', -100n, CborReaderState.NegativeInteger);
      verifyInt('3903e7', -1000n, CborReaderState.NegativeInteger);
      verifyInt('38ff', -256n, CborReaderState.NegativeInteger);
      verifyInt('390100', -257n, CborReaderState.NegativeInteger);
      verifyInt('39ffff', -65_536n, CborReaderState.NegativeInteger);
      verifyInt('3a00010000', -65_537n, CborReaderState.NegativeInteger);
      verifyInt('3affffffff', -4_294_967_296n, CborReaderState.NegativeInteger);
      verifyInt('3b0000000100000000', -4_294_967_297n, CborReaderState.NegativeInteger);
      verifyInt('3b7fffffffffffffff', -9_223_372_036_854_775_808n, CborReaderState.NegativeInteger);
    });
  });

  describe('Simple', () => {
    it('can read half precision values', async () => {
      verifyFloat('f90000', 0, CborReaderState.HalfPrecisionFloat);
      verifyFloat('f93c00', 1, CborReaderState.HalfPrecisionFloat);
      verifyFloat('f93e00', 1.5, CborReaderState.HalfPrecisionFloat);
      verifyFloat('f98000', -0, CborReaderState.HalfPrecisionFloat);
      verifyFloat('f93c00', 1, CborReaderState.HalfPrecisionFloat);
      verifyFloat('f97bff', 65_504, CborReaderState.HalfPrecisionFloat);
      verifyFloat('f90001', 5.960_464_477_539_063e-8, CborReaderState.HalfPrecisionFloat);
      verifyFloat('f90400', 0.000_061_035_156_25, CborReaderState.HalfPrecisionFloat);
      verifyFloat('f9c400', -4, CborReaderState.HalfPrecisionFloat);
      verifyFloat('f97c00', Number.POSITIVE_INFINITY, CborReaderState.HalfPrecisionFloat);
      verifyFloat('f97e00', Number.NaN, CborReaderState.HalfPrecisionFloat);
      verifyFloat('f9fc00', Number.NEGATIVE_INFINITY, CborReaderState.HalfPrecisionFloat);
    });

    it('can read single precision values', async () => {
      verifyFloat('fa47c35000', 100_000, CborReaderState.SinglePrecisionFloat);
      verifyFloat('fa7f7fffff', 3.402_823_466_385_288_6e+38, CborReaderState.SinglePrecisionFloat);
      verifyFloat('fa7f800000', Number.POSITIVE_INFINITY, CborReaderState.SinglePrecisionFloat);
      verifyFloat('fa7fc00000', Number.NaN, CborReaderState.SinglePrecisionFloat);
      verifyFloat('faff800000', Number.NEGATIVE_INFINITY, CborReaderState.SinglePrecisionFloat);
    });

    it('can read double precision values', async () => {
      verifyFloat('fb3ff199999999999a', 1.1, CborReaderState.DoublePrecisionFloat);
      verifyFloat('fb7e37e43c8800759c', 1e300, CborReaderState.DoublePrecisionFloat);
      verifyFloat('fbc010666666666666', -4.1, CborReaderState.DoublePrecisionFloat);
      verifyFloat('fb7ff0000000000000', Number.POSITIVE_INFINITY, CborReaderState.DoublePrecisionFloat);
      verifyFloat('fb7ff8000000000000', Number.NaN, CborReaderState.DoublePrecisionFloat);
      verifyFloat('fbfff0000000000000', Number.NEGATIVE_INFINITY, CborReaderState.DoublePrecisionFloat);
    });

    it('can read null values', async () => {
      const reader = new CborReader(HexBlob('f6'));
      expect(reader.peekState()).toBe(CborReaderState.Null);

      reader.readNull();

      expect(reader.peekState()).toBe(CborReaderState.Finished);
    });

    it('can read boolean values', async () => {
      let reader = new CborReader(HexBlob('f4'));
      expect(reader.peekState()).toBe(CborReaderState.Boolean);
      expect(reader.readBoolean()).toBeFalsy();
      expect(reader.peekState()).toBe(CborReaderState.Finished);

      reader = new CborReader(HexBlob('f5'));
      expect(reader.peekState()).toBe(CborReaderState.Boolean);
      expect(reader.readBoolean()).toBeTruthy();
      expect(reader.peekState()).toBe(CborReaderState.Finished);
    });

    it('can read simple values', async () => {
      const reader = new CborReader(HexBlob('e0f4f5f6f7f820f8ff'));

      expect(reader.readSimpleValue()).toEqual(0);
      expect(reader.readSimpleValue()).toEqual(CborSimpleValue.False);
      expect(reader.readSimpleValue()).toEqual(CborSimpleValue.True);

      reader.readSimpleValue(); // Null
      reader.readSimpleValue(); // Undefined

      expect(reader.readSimpleValue()).toEqual(32);
      expect(reader.readSimpleValue()).toEqual(255);

      expect(reader.peekState()).toBe(CborReaderState.Finished);
    });
  });

  describe('Skip', () => {
    it('can skip a value without decoding it', async () => {
      const reader = new CborReader(HexBlob('83656c6f72656d65697073756d65646f6c6f72'));

      reader.readStartArray();
      reader.skipValue();
      reader.skipValue();
      expect(reader.readTextString()).toBe('dolor');
      reader.readEndArray();
    });

    it('can get a value without decoding it', async () => {
      const reader = new CborReader(HexBlob('83656c6f72656d65697073756d65646f6c6f72'));

      reader.readStartArray();
      reader.skipValue();
      reader.skipValue();
      expect(areEqual(reader.readEncodedValue(), new Uint8Array([0x65, 0x64, 0x6f, 0x6c, 0x6f, 0x72]))).toBeTruthy();
      reader.readEndArray();
    });
  });

  describe('Tag', () => {
    it('can read single tagged string value', async () => {
      const reader = new CborReader(HexBlob('c074323031332d30332d32315432303a30343a30305a'));
      expect(reader.peekState()).toBe(CborReaderState.Tag);
      expect(reader.readTag()).toBe(CborTag.DateTimeString);
      expect(reader.peekState()).toBe(CborReaderState.TextString);
      expect(reader.readTextString()).toBe('2013-03-21T20:04:00Z');
      expect(reader.peekState()).toBe(CborReaderState.Finished);
    });

    it('can read single tagged unix time seconds value', async () => {
      const reader = new CborReader(HexBlob('c11a514b67b0'));
      expect(reader.peekState()).toBe(CborReaderState.Tag);
      expect(reader.readTag()).toBe(CborTag.UnixTimeSeconds);
      expect(reader.peekState()).toBe(CborReaderState.UnsignedInteger);
      expect(reader.readUInt()).toBe(1_363_896_240n);
      expect(reader.peekState()).toBe(CborReaderState.Finished);
    });

    it('can read single tagged unsigned bignum value', async () => {
      const reader = new CborReader(HexBlob('c202'));
      expect(reader.peekState()).toBe(CborReaderState.Tag);
      expect(reader.readTag()).toBe(CborTag.UnsignedBigNum);
      expect(reader.peekState()).toBe(CborReaderState.UnsignedInteger);
      expect(reader.readInt()).toBe(2n);
      expect(reader.peekState()).toBe(CborReaderState.Finished);
    });

    it('can read single tagged base 16 value', async () => {
      const reader = new CborReader(HexBlob('d74401020304'));
      expect(reader.peekState()).toBe(CborReaderState.Tag);
      expect(reader.readTag()).toBe(CborTag.Base16StringLaterEncoding);
      expect(reader.peekState()).toBe(CborReaderState.ByteString);
      expect(areEqual(reader.readByteString(), new Uint8Array([1, 2, 3, 4]))).toBeTruthy();
      expect(reader.peekState()).toBe(CborReaderState.Finished);
    });

    it('can read single tagged uri value', async () => {
      const reader = new CborReader(HexBlob('d82076687474703a2f2f7777772e6578616d706c652e636f6d'));
      expect(reader.peekState()).toBe(CborReaderState.Tag);
      expect(reader.readTag()).toBe(CborTag.Uri);
      expect(reader.peekState()).toBe(CborReaderState.TextString);
      expect(reader.readTextString()).toEqual('http://www.example.com');
      expect(reader.peekState()).toBe(CborReaderState.Finished);
    });

    it('can read nested tagged values', async () => {
      const reader = new CborReader(HexBlob('c0c0c074323031332d30332d32315432303a30343a30305a'));
      expect(reader.peekState()).toBe(CborReaderState.Tag);
      expect(reader.readTag()).toBe(CborTag.DateTimeString);
      expect(reader.peekState()).toBe(CborReaderState.Tag);
      expect(reader.readTag()).toBe(CborTag.DateTimeString);
      expect(reader.peekState()).toBe(CborReaderState.Tag);
      expect(reader.readTag()).toBe(CborTag.DateTimeString);
      expect(reader.readTextString()).toEqual('2013-03-21T20:04:00Z');
      expect(reader.peekState()).toBe(CborReaderState.Finished);
    });
  });

  describe('TextString', () => {
    it('can read fixed length text strings', async () => {
      verifyText('60', '', CborReaderState.TextString);
      verifyText('6161', 'a', CborReaderState.TextString);
      verifyText('6449455446', 'IETF', CborReaderState.TextString);
      verifyText('62225c', '"\\', CborReaderState.TextString);
      verifyText('62c3bc', '\u00FC', CborReaderState.TextString);
      verifyText('63e6b0b4', '\u6C34', CborReaderState.TextString);
      verifyText('62cebb', '\u03BB', CborReaderState.TextString);
      verifyText('64f0908591', '\uD800\uDD51', CborReaderState.TextString);
    });

    it('can read indefinite length text strings', async () => {
      verifyText('7fff', '', CborReaderState.StartIndefiniteLengthTextString);
      verifyText('7f60ff', '', CborReaderState.StartIndefiniteLengthTextString);
      verifyText('7f62616260ff', 'ab', CborReaderState.StartIndefiniteLengthTextString);
      verifyText('7f62616262626360ff', 'abbc', CborReaderState.StartIndefiniteLengthTextString);
    });
  });

  describe('Map', () => {
    it('can read empty maps', async () => {
      const reader = new CborReader(HexBlob('a0'));
      expect(reader.peekState()).toBe(CborReaderState.StartMap);

      const length = reader.readStartMap();

      expect(length).toBe(0);

      expect(reader.peekState()).toBe(CborReaderState.EndMap);
      reader.readEndMap();

      expect(reader.peekState()).toBe(CborReaderState.Finished);
    });

    it('can read fixed length maps with numbers', async () => {
      const reader = new CborReader(HexBlob('a201020304'));

      const map = getVal(reader);

      expect(map).toEqual(
        new Map([
          [1n, 2n],
          [3n, 4n]
        ])
      );

      expect(reader.peekState()).toBe(CborReaderState.Finished);
    });

    it('can read fixed length maps with strings', async () => {
      const reader = new CborReader(HexBlob('a56161614161626142616361436164614461656145'));

      const map = getVal(reader);

      expect(map).toEqual(
        new Map([
          ['a', 'A'],
          ['b', 'B'],
          ['c', 'C'],
          ['d', 'D'],
          ['e', 'E']
        ])
      );

      expect(reader.peekState()).toBe(CborReaderState.Finished);
    });

    it('can read fixed length maps with mixed types', async () => {
      const reader = new CborReader(HexBlob('a3616161412002404101'));

      const map = getVal(reader);

      expect(map).toEqual(
        new Map<any, any>([
          ['a', 'A'],
          [-1n, 2n],
          [[], [1]]
        ])
      );

      expect(reader.peekState()).toBe(CborReaderState.Finished);
    });

    it('can read fixed length maps with nested types', async () => {
      const reader = new CborReader(HexBlob('a26161a102036162a26178206179a1617a00'));

      const map = getVal(reader);

      expect(map).toEqual(
        new Map<any, any>([
          ['a', new Map([[2n, 3n]])],
          [
            'b',
            new Map<any, any>([
              ['x', -1n],
              ['y', new Map([['z', 0n]])]
            ])
          ]
        ])
      );

      expect(reader.peekState()).toBe(CborReaderState.Finished);
    });

    it('can read empty indefinite length maps', async () => {
      const reader = new CborReader(HexBlob('bfff'));
      expect(reader.peekState()).toBe(CborReaderState.StartMap);

      const length = reader.readStartMap();

      expect(length).toBe(null);

      expect(reader.peekState()).toBe(CborReaderState.EndMap);
      reader.readEndMap();

      expect(reader.peekState()).toBe(CborReaderState.Finished);
    });

    it('can read indefinite length maps', async () => {
      const reader = new CborReader(HexBlob('bf6161614161626142616361436164614461656145ff'));

      const map = getVal(reader);

      expect(map).toEqual(
        new Map([
          ['a', 'A'],
          ['b', 'B'],
          ['c', 'C'],
          ['d', 'D'],
          ['e', 'E']
        ])
      );

      expect(reader.peekState()).toBe(CborReaderState.Finished);
    });

    it('can read indefinite length maps with mixed types', async () => {
      const reader = new CborReader(HexBlob('bf616161412002404101ff'));

      const map = getVal(reader);

      expect(map).toEqual(
        new Map<any, any>([
          ['a', 'A'],
          [-1n, 2n],
          [[], [1]]
        ])
      );

      expect(reader.peekState()).toBe(CborReaderState.Finished);
    });
  });
});
