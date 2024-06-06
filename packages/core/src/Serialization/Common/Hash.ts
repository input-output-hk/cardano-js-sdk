import { CborReader, CborWriter } from '../CBOR/index.js';
import { HexBlob } from '@cardano-sdk/util';

export class Hash<T extends string> {
  #value: T;

  constructor(value: T) {
    this.#value = value;
  }

  toCbor() {
    const writer = new CborWriter();
    writer.writeByteString(Buffer.from(this.#value, 'hex'));
    return writer.encodeAsHex();
  }

  static fromCbor<T extends string>(cbor: HexBlob): Hash<T> {
    const reader = new CborReader(cbor);
    return new Hash<T>(HexBlob.fromBytes(reader.readByteString()) as unknown as T);
  }

  toCore() {
    return this.#value;
  }

  static fromCore<T extends string>(hash: T): Hash<T> {
    return new Hash<T>(hash);
  }

  value() {
    return this.#value;
  }
}
