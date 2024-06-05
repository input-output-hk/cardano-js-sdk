import { Cardano, Serialization } from '../../src';
import { HexBlob } from '@cardano-sdk/util';

describe('PlutusData', () => {
  it('round trip serializations produce the same core type output', () => {
    const plutusData: Cardano.PlutusData = 123n;
    const fromCore = Serialization.PlutusData.fromCore(plutusData);
    const cbor = fromCore.toCbor();
    const fromCbor = Serialization.PlutusData.fromCbor(cbor);
    expect(fromCbor.toCore()).toEqual(plutusData);
  });

  it('converts (TODO: describe is special about this that fails) inline datum', () => {
    // tx: https://preprod.cexplorer.io/tx/32d2b9062680c7ef5673114abce804d8b854f54440518e48a6db3e555f3a84d2
    // parsed datum: https://preprod.cexplorer.io/datum/f20e5a0a42a9015cd4e53f8b8c020e535957f782ea3231453fe4cf46a52d07c9
    const cbor = HexBlob(
      'd8799fa3446e616d6548537061636542756445696d6167654b697066733a2f2f7465737445696d616765583061723a2f2f66355738525a6d4151696d757a5f7679744659396f66497a6439517047614449763255587272616854753401ff'
    );
    expect(() => Serialization.PlutusData.fromCbor(cbor)).not.toThrowError();
  });

  it('can compute correct hash', () => {
    const data = Serialization.PlutusData.fromCbor(HexBlob('46010203040506'));

    // Hash was generated with the CSL
    expect(data.hash()).toEqual('f5e45fd57d6c5591dd9e83e76943827c4f4a9eacefd5ac974f48afd8420765a6');
  });

  describe('Integer', () => {
    it('can encode a positive integer', () => {
      const data = Serialization.PlutusData.newInteger(5n);
      expect(data.toCbor()).toEqual('05');
    });

    it('can encode a negative integer', () => {
      const data = Serialization.PlutusData.newInteger(-5n);
      expect(data.toCbor()).toEqual('24');
    });

    it('can encode an integer bigger than unsigned 64bits', () => {
      const data = Serialization.PlutusData.newInteger(18_446_744_073_709_551_616n);
      expect(data.toCbor()).toEqual('c249010000000000000000');
    });

    it('can encode a negative integer bigger than unsigned 64bits', () => {
      const data = Serialization.PlutusData.newInteger(-18_446_744_073_709_551_616n);
      expect(data.toCbor()).toEqual('3bffffffffffffffff');
    });

    it('can decode a positive integer', () => {
      const data = Serialization.PlutusData.fromCbor(HexBlob('05'));
      expect(data.asInteger()).toEqual(5n);
    });

    it('can decode a negative integer', () => {
      const data = Serialization.PlutusData.fromCbor(HexBlob('24'));
      expect(data.asInteger()).toEqual(-5n);
    });

    it('can decode an integer bigger than unsigned 64bits', () => {
      const data = Serialization.PlutusData.fromCbor(HexBlob('c249010000000000000000'));
      expect(data.asInteger()).toEqual(18_446_744_073_709_551_616n);
    });

    it('can decode a negative integer bigger than unsigned 64bits', () => {
      const data = Serialization.PlutusData.fromCbor(HexBlob('3bffffffffffffffff'));
      expect(data.asInteger()).toEqual(-18_446_744_073_709_551_616n);
    });
  });

  describe('Bytes', () => {
    it('can encode a small byte string (less than 64 bytes)', () => {
      const data = Serialization.PlutusData.newBytes(new Uint8Array([0x01, 0x02, 0x03, 0x04, 0x05, 0x06]));
      expect(data.toCbor()).toEqual('46010203040506');
    });

    it('can decode a small byte string (less than 64 bytes)', () => {
      const data = Serialization.PlutusData.fromCbor(HexBlob('46010203040506'));
      expect(HexBlob.fromBytes(data.asBoundedBytes()!)).toEqual('010203040506');
    });

    it('can encode a big byte string (more than 64 bytes)', () => {
      const payload = new Uint8Array([
        0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x01, 0x02,
        0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x01, 0x02, 0x03, 0x04,
        0x05, 0x06, 0x07, 0x08, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06,
        0x07, 0x08, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08,
        0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x01, 0x02,
        0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x01, 0x02, 0x03, 0x04,
        0x05, 0x06, 0x07, 0x08, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06,
        0x07, 0x08, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08,
        0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x01, 0x02,
        0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x01, 0x02, 0x03, 0x04,
        0x05, 0x06, 0x07, 0x08, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06,
        0x07, 0x08, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08,
        0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x01, 0x02,
        0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x01, 0x02, 0x03, 0x04,
        0x05, 0x06, 0x07, 0x08
      ]);

      const data = Serialization.PlutusData.newBytes(payload);
      expect(data.toCbor()).toEqual(
        '5f584001020304050607080102030405060708010203040506070801020304050607080102030405060708010203040506070801020304050607080102030405060708584001020304050607080102030405060708010203040506070801020304050607080102030405060708010203040506070801020304050607080102030405060708584001020304050607080102030405060708010203040506070801020304050607080102030405060708010203040506070801020304050607080102030405060708584001020304050607080102030405060708010203040506070801020304050607080102030405060708010203040506070801020304050607080102030405060708ff'
      );
    });

    it('can decode a big byte string (more than 64 bytes)', () => {
      const payload = [
        0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x01, 0x02,
        0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x01, 0x02, 0x03, 0x04,
        0x05, 0x06, 0x07, 0x08, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06,
        0x07, 0x08, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08,
        0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x01, 0x02,
        0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x01, 0x02, 0x03, 0x04,
        0x05, 0x06, 0x07, 0x08, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06,
        0x07, 0x08, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08,
        0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x01, 0x02,
        0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x01, 0x02, 0x03, 0x04,
        0x05, 0x06, 0x07, 0x08, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06,
        0x07, 0x08, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08,
        0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x01, 0x02,
        0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x01, 0x02, 0x03, 0x04,
        0x05, 0x06, 0x07, 0x08
      ];

      const data = Serialization.PlutusData.fromCbor(
        HexBlob(
          '5f584001020304050607080102030405060708010203040506070801020304050607080102030405060708010203040506070801020304050607080102030405060708584001020304050607080102030405060708010203040506070801020304050607080102030405060708010203040506070801020304050607080102030405060708584001020304050607080102030405060708010203040506070801020304050607080102030405060708010203040506070801020304050607080102030405060708584001020304050607080102030405060708010203040506070801020304050607080102030405060708010203040506070801020304050607080102030405060708ff'
        )
      );
      expect([...data.asBoundedBytes()!]).toEqual(payload);
    });
  });

  describe('List', () => {
    it('can encode simple plutus list', () => {
      const data = new Serialization.PlutusList();

      data.add(Serialization.PlutusData.newInteger(1n));
      data.add(Serialization.PlutusData.newInteger(2n));
      data.add(Serialization.PlutusData.newInteger(3n));
      data.add(Serialization.PlutusData.newInteger(4n));
      data.add(Serialization.PlutusData.newInteger(5n));

      expect(data.toCbor()).toEqual('9f0102030405ff');
    });

    it('can encode a list of plutus list', () => {
      const innerList = new Serialization.PlutusList();

      innerList.add(Serialization.PlutusData.newInteger(1n));
      innerList.add(Serialization.PlutusData.newInteger(2n));
      innerList.add(Serialization.PlutusData.newInteger(3n));
      innerList.add(Serialization.PlutusData.newInteger(4n));
      innerList.add(Serialization.PlutusData.newInteger(5n));

      const outer = new Serialization.PlutusList();

      outer.add(Serialization.PlutusData.newInteger(1n));
      outer.add(Serialization.PlutusData.newInteger(2n));
      outer.add(Serialization.PlutusData.newList(innerList));
      outer.add(Serialization.PlutusData.newList(innerList));
      outer.add(Serialization.PlutusData.newInteger(5n));

      expect(outer.toCbor()).toEqual('9f01029f0102030405ff9f0102030405ff05ff');
    });
  });

  describe('Map', () => {
    it('can encode simple plutus map', () => {
      const data = new Serialization.PlutusMap();

      data.insert(Serialization.PlutusData.newInteger(1n), Serialization.PlutusData.newInteger(2n));

      expect(data.toCbor()).toEqual('a10102');
    });

    it('can find an element in a plutus map with key - Integer', () => {
      const data = new Serialization.PlutusMap();

      data.insert(Serialization.PlutusData.newInteger(1n), Serialization.PlutusData.newInteger(2n));

      expect(data.get(Serialization.PlutusData.newInteger(1n))).toEqual(Serialization.PlutusData.newInteger(2n));
      expect(data.get(Serialization.PlutusData.newInteger(2n))).toBeUndefined();
    });

    it('can find an element in a plutus map with key - Bytes', () => {
      const data = new Serialization.PlutusMap();

      data.insert(
        Serialization.PlutusData.newBytes(new Uint8Array([0, 1, 2])),
        Serialization.PlutusData.newInteger(2n)
      );

      expect(data.get(Serialization.PlutusData.newBytes(new Uint8Array([0, 1, 2])))).toEqual(
        Serialization.PlutusData.newInteger(2n)
      );

      expect(data.get(Serialization.PlutusData.newBytes(new Uint8Array([0, 1, 2, 3])))).toBeUndefined();
    });

    it('can find an element in a plutus map with key - PlutusList', () => {
      const data = new Serialization.PlutusMap();

      const list1 = new Serialization.PlutusList();
      list1.add(Serialization.PlutusData.newInteger(1n));
      list1.add(Serialization.PlutusData.newInteger(2n));
      list1.add(Serialization.PlutusData.newInteger(5n));

      const list2 = new Serialization.PlutusList();
      list2.add(Serialization.PlutusData.newInteger(1n));
      list2.add(Serialization.PlutusData.newInteger(2n));
      list2.add(Serialization.PlutusData.newInteger(5n));

      const list3 = new Serialization.PlutusList();
      list3.add(Serialization.PlutusData.newInteger(1n));
      list3.add(Serialization.PlutusData.newInteger(2n));

      data.insert(Serialization.PlutusData.newList(list1), Serialization.PlutusData.newInteger(2n));

      expect(data.get(Serialization.PlutusData.newList(list2))).toEqual(Serialization.PlutusData.newInteger(2n));

      expect(data.get(Serialization.PlutusData.newList(list3))).toBeUndefined();
    });

    it('can find an element in a plutus map with key - PlutusMap', () => {
      const data = new Serialization.PlutusMap();

      const map1 = new Serialization.PlutusMap();
      const list1 = new Serialization.PlutusList();
      list1.add(Serialization.PlutusData.newInteger(1n));
      list1.add(Serialization.PlutusData.newInteger(2n));
      list1.add(Serialization.PlutusData.newInteger(5n));
      map1.insert(Serialization.PlutusData.newList(list1), Serialization.PlutusData.newInteger(1n));

      const map2 = new Serialization.PlutusMap();
      const list2 = new Serialization.PlutusList();
      list2.add(Serialization.PlutusData.newInteger(1n));
      list2.add(Serialization.PlutusData.newInteger(2n));
      list2.add(Serialization.PlutusData.newInteger(5n));
      map2.insert(Serialization.PlutusData.newList(list2), Serialization.PlutusData.newInteger(1n));

      const map3 = new Serialization.PlutusMap();
      const list3 = new Serialization.PlutusList();
      list3.add(Serialization.PlutusData.newInteger(1n));
      list3.add(Serialization.PlutusData.newInteger(2n));
      map3.insert(Serialization.PlutusData.newList(list3), Serialization.PlutusData.newInteger(1n));

      data.insert(Serialization.PlutusData.newMap(map1), Serialization.PlutusData.newInteger(1n));

      expect(data.get(Serialization.PlutusData.newMap(map2))).toEqual(Serialization.PlutusData.newInteger(2n));
      expect(data.get(Serialization.PlutusData.newMap(map3))).toBeUndefined();
    });

    it('can find an element in a plutus map with key - Constr', () => {
      const data = new Serialization.PlutusMap();

      const list1 = new Serialization.PlutusList();
      list1.add(Serialization.PlutusData.newInteger(1n));
      list1.add(Serialization.PlutusData.newInteger(2n));
      list1.add(Serialization.PlutusData.newInteger(3n));
      const constr1 = new Serialization.ConstrPlutusData(0n, list1);

      const list2 = new Serialization.PlutusList();
      list2.add(Serialization.PlutusData.newInteger(1n));
      list2.add(Serialization.PlutusData.newInteger(2n));
      list2.add(Serialization.PlutusData.newInteger(3n));
      const constr2 = new Serialization.ConstrPlutusData(0n, list2);

      const list3 = new Serialization.PlutusList();
      list3.add(Serialization.PlutusData.newInteger(1n));
      list3.add(Serialization.PlutusData.newInteger(2n));
      const constr3 = new Serialization.ConstrPlutusData(1n, list2);

      data.insert(Serialization.PlutusData.newConstrPlutusData(constr1), Serialization.PlutusData.newInteger(2n));

      expect(data.get(Serialization.PlutusData.newConstrPlutusData(constr2))).toEqual(
        Serialization.PlutusData.newInteger(2n)
      );
      expect(data.get(Serialization.PlutusData.newConstrPlutusData(constr3))).toBeUndefined();
    });
  });

  describe('Constr', () => {
    it('can encode simple Constr', () => {
      const args = new Serialization.PlutusList();
      args.add(Serialization.PlutusData.newInteger(1n));
      args.add(Serialization.PlutusData.newInteger(2n));
      args.add(Serialization.PlutusData.newInteger(3n));
      args.add(Serialization.PlutusData.newInteger(4n));
      args.add(Serialization.PlutusData.newInteger(5n));

      const data = new Serialization.ConstrPlutusData(0n, args);

      expect(data.toCbor()).toEqual('d8799f0102030405ff');
    });
  });

  describe('Deep equality', () => {
    it('Integer', () => {
      expect(Serialization.PlutusData.newInteger(1n).equals(Serialization.PlutusData.newInteger(1n))).toBeTruthy();
      expect(Serialization.PlutusData.newInteger(1n).equals(Serialization.PlutusData.newInteger(2n))).toBeFalsy();
    });

    it('Bytes', () => {
      expect(
        Serialization.PlutusData.newBytes(new Uint8Array([0, 1, 2])).equals(
          Serialization.PlutusData.newBytes(new Uint8Array([0, 1, 2]))
        )
      ).toBeTruthy();
      expect(
        Serialization.PlutusData.newBytes(new Uint8Array([0, 1, 2])).equals(
          Serialization.PlutusData.newBytes(new Uint8Array([0, 1]))
        )
      ).toBeFalsy();
    });

    it('PlutusList', () => {
      const list1 = new Serialization.PlutusList();
      list1.add(Serialization.PlutusData.newInteger(1n));
      list1.add(Serialization.PlutusData.newInteger(2n));
      list1.add(Serialization.PlutusData.newInteger(5n));

      const list2 = new Serialization.PlutusList();
      list2.add(Serialization.PlutusData.newInteger(1n));
      list2.add(Serialization.PlutusData.newInteger(2n));
      list2.add(Serialization.PlutusData.newInteger(5n));

      const list3 = new Serialization.PlutusList();
      list3.add(Serialization.PlutusData.newInteger(1n));
      list3.add(Serialization.PlutusData.newInteger(2n));

      expect(list1.equals(list2)).toBeTruthy();
      expect(list1.equals(list3)).toBeFalsy();
    });

    it('PlutusMap', () => {
      const map1 = new Serialization.PlutusMap();
      const list1 = new Serialization.PlutusList();
      list1.add(Serialization.PlutusData.newInteger(1n));
      list1.add(Serialization.PlutusData.newInteger(2n));
      list1.add(Serialization.PlutusData.newInteger(5n));
      map1.insert(Serialization.PlutusData.newList(list1), Serialization.PlutusData.newInteger(1n));

      const map2 = new Serialization.PlutusMap();
      const list2 = new Serialization.PlutusList();
      list2.add(Serialization.PlutusData.newInteger(1n));
      list2.add(Serialization.PlutusData.newInteger(2n));
      list2.add(Serialization.PlutusData.newInteger(5n));
      map2.insert(Serialization.PlutusData.newList(list2), Serialization.PlutusData.newInteger(1n));

      const map3 = new Serialization.PlutusMap();
      const list3 = new Serialization.PlutusList();
      list3.add(Serialization.PlutusData.newInteger(1n));
      list3.add(Serialization.PlutusData.newInteger(2n));
      map3.insert(Serialization.PlutusData.newList(list3), Serialization.PlutusData.newInteger(1n));

      expect(map1.equals(map2)).toBeTruthy();
      expect(map1.equals(map3)).toBeFalsy();
    });

    it('Constr', () => {
      const list1 = new Serialization.PlutusList();
      list1.add(Serialization.PlutusData.newInteger(1n));
      list1.add(Serialization.PlutusData.newInteger(2n));
      list1.add(Serialization.PlutusData.newInteger(3n));
      const constr1 = new Serialization.ConstrPlutusData(0n, list1);

      const list2 = new Serialization.PlutusList();
      list2.add(Serialization.PlutusData.newInteger(1n));
      list2.add(Serialization.PlutusData.newInteger(2n));
      list2.add(Serialization.PlutusData.newInteger(3n));
      const constr2 = new Serialization.ConstrPlutusData(0n, list2);

      const list3 = new Serialization.PlutusList();
      list3.add(Serialization.PlutusData.newInteger(1n));
      list3.add(Serialization.PlutusData.newInteger(2n));
      const constr3 = new Serialization.ConstrPlutusData(1n, list2);

      expect(constr1.equals(constr2)).toBeTruthy();
      expect(constr1.equals(constr3)).toBeFalsy();
    });
  });
});
