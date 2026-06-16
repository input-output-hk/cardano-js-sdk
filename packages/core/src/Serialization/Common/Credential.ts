import { CborReader, CborWriter } from '../CBOR';
import { CredentialType } from '../../Cardano/Address/Address';
import { Hash28ByteBase16 } from '@cardano-sdk/crypto';
import { HexBlob, InvalidArgumentError, InvalidStateError } from '@cardano-sdk/util';
import { hexToBytes } from '../../util/misc';
import type { Cardano } from '../..';

const CREDENTIAL_ARRAY_SIZE = 2;

/**
 * Reads a credential type discriminant from the reader, throwing if it is not a known credential type.
 *
 * @param reader The CBOR reader positioned at the credential type value.
 * @returns The credential type.
 */
export const readCredentialType = (reader: CborReader): CredentialType => {
  const type = Number(reader.readInt());

  if (type !== CredentialType.KeyHash && type !== CredentialType.ScriptHash)
    throw new InvalidStateError(`Unexpected credential type value: ${type}`);

  return type;
};

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

    const type = readCredentialType(reader);
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
