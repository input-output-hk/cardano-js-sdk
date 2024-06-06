import { CborReader, CborWriter } from '../CBOR/index.js';
import { HexBlob, InvalidArgumentError } from '@cardano-sdk/util';
import { hexToBytes } from '../../util/misc/index.js';
import type { Cardano } from '../../index.js';
import type { Hash28ByteBase16 } from '@cardano-sdk/crypto';

const CREDENTIAL_ARRAY_SIZE = 2;

export class Credential {
  #value: Cardano.Credential;

  private constructor(value: Cardano.Credential) {
    this.#value = value;
  }

  toCbor() {
    const writer = new CborWriter();
    writer.writeStartArray(CREDENTIAL_ARRAY_SIZE);
    writer.writeInt(this.#value.type);
    writer.writeByteString(hexToBytes(this.#value.hash as unknown as HexBlob));
    return writer.encodeAsHex();
  }

  static fromCbor(cbor: HexBlob): Credential {
    const reader = new CborReader(cbor);
    if (reader.readStartArray() !== CREDENTIAL_ARRAY_SIZE)
      throw new InvalidArgumentError(
        'cbor',
        `Expected an array of ${CREDENTIAL_ARRAY_SIZE} elements, but got an array of ${length} elements`
      );

    const type = Number(reader.readUInt());
    const hash = HexBlob.fromBytes(reader.readByteString()) as unknown as Hash28ByteBase16;

    reader.readEndArray();
    return new Credential({ hash, type });
  }

  toCore(): Cardano.Credential {
    return { ...this.#value };
  }

  static fromCore(credential: Cardano.Credential): Credential {
    return new Credential({ ...credential });
  }

  value() {
    return { ...this.#value };
  }
}
