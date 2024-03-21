import { CborReader, CborSet, CborTag, CborWriter } from '../../../src/Serialization';
import { HexBlob } from '@cardano-sdk/util';

class TestNumber {
  #value: number;
  constructor(value: number) {
    this.#value = value;
  }

  toCbor() {
    const writer = new CborWriter();
    writer.writeInt(this.#value);
    return writer.encodeAsHex();
  }

  toCore() {
    return this.#value;
  }

  static fromCbor(cbor: HexBlob) {
    const reader = new CborReader(cbor);
    return new TestNumber(Number(reader.readInt()));
  }

  static fromCore(v: number) {
    return new TestNumber(v);
  }
}

describe('CborSet', () => {
  const testNumbers = [1, 2, 3];
  let testCbor: HexBlob;
  let testCborConway: HexBlob;
  let set: CborSet<number, TestNumber>;

  beforeEach(() => {
    set = CborSet.fromCore<number, TestNumber>(testNumbers, TestNumber.fromCore);

    // Manually serialize as array
    const writer = new CborWriter();
    writer.writeStartArray(testNumbers.length);
    for (const num of testNumbers) {
      writer.writeInt(num);
    }
    testCbor = writer.encodeAsHex();

    // Manually serialize as 258 tag + array
    writer.reset();
    writer.writeTag(CborTag.Set);
    writer.writeStartArray(testNumbers.length);
    for (const num of testNumbers) {
      writer.writeInt(num);
    }
    testCborConway = writer.encodeAsHex();
  });

  afterEach(() => (CborSet.useConwaySerialization = false));

  it('can serialize as array', () => {
    expect(testCbor).toEqual(set.toCbor());
  });

  it('can serialize as 258 tag set', () => {
    CborSet.useConwaySerialization = true;
    expect(testCborConway).toEqual(set.toCbor());
  });

  it('correctly deserialize a CBOR array', () => {
    const arraySet = CborSet.fromCbor(testCbor, TestNumber.fromCbor);
    expect(arraySet.values().map((v) => v.toCore())).toEqual(testNumbers);
  });

  it('correctly deserialize a CBOR tagged array', () => {
    const arraySet = CborSet.fromCbor(testCborConway, TestNumber.fromCbor);
    expect(arraySet.values().map((v) => v.toCore())).toEqual(testNumbers);
  });

  it.each([false, true])('can serialize an empty array with set tag %s', (useConwaySerialization) => {
    const writer = new CborWriter();
    if (useConwaySerialization) {
      writer.writeTag(CborTag.Set);
    }
    writer.writeStartArray(0);
    const emptyArrayCbor = writer.encodeAsHex();

    const emptySet = CborSet.fromCore<number, TestNumber>([], TestNumber.fromCore);
    CborSet.useConwaySerialization = useConwaySerialization;
    expect(emptySet.toCbor()).toEqual(emptyArrayCbor);
  });

  it('can update the set values and serialize correctly', () => {
    const testNumbersReduced = testNumbers.slice(0, -1);

    const set2 = CborSet.fromCore<number, TestNumber>(testNumbersReduced, TestNumber.fromCore);
    set2.setValues([...set2.values(), TestNumber.fromCore(testNumbers[testNumbers.length - 1])]);
    expect(set2.toCbor()).toEqual(testCbor);
    expect(set2.toCore()).toEqual(testNumbers);
  });
});
