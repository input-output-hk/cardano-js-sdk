import * as Crypto from '@cardano-sdk/crypto';
import { CborReader, CborWriter } from '../../CBOR';
import { HexBlob, InvalidArgumentError } from '@cardano-sdk/util';
import { NativeScriptKind, ScriptType } from '../../../Cardano/types/Script';
import type * as Cardano from '../../../Cardano';

const EMBEDDED_GROUP_SIZE = 2;

/**
 * This script evaluates to true if the transaction also includes a valid key witness
 * where the witness verification key hashes to the given hash.
 *
 * In other words, this checks that the transaction is signed by a particular key, identified by its verification
 * key hash.
 */
export class ScriptPubkey {
  #keyHash: Crypto.Ed25519KeyHashHex;
  #originalBytes: HexBlob | undefined = undefined;

  /**
   * Initializes a new instance of the ScriptPubkey class.
   *
   * @param keyHash The hash of an Ed25519 verification key.
   */
  constructor(keyHash: Crypto.Ed25519KeyHashHex) {
    this.#keyHash = keyHash;
  }

  /**
   * Serializes a ScriptPubkey into CBOR format.
   *
   * @returns The ScriptPubkey in CBOR format.
   */
  toCbor(): HexBlob {
    const writer = new CborWriter();

    if (this.#originalBytes) return this.#originalBytes;

    // CDDL
    // script_pubkey = (0, addr_keyhash)
    writer.writeStartArray(EMBEDDED_GROUP_SIZE);
    writer.writeInt(NativeScriptKind.RequireSignature);
    writer.writeByteString(Buffer.from(this.#keyHash, 'hex'));

    return writer.encodeAsHex();
  }

  /**
   * Deserializes the ScriptPubkey from a CBOR byte array.
   *
   * @param cbor The CBOR encoded ScriptPubkey object.
   * @returns The new ScriptPubkey instance.
   */
  static fromCbor(cbor: HexBlob): ScriptPubkey {
    const reader = new CborReader(cbor);

    const length = reader.readStartArray();

    if (length !== EMBEDDED_GROUP_SIZE)
      throw new InvalidArgumentError(
        'cbor',
        `Expected an array of two elements, but got an array of ${length} elements`
      );

    const kind = Number(reader.readInt());

    if (kind !== NativeScriptKind.RequireSignature)
      throw new InvalidArgumentError(
        'cbor',
        `Expected kind ${NativeScriptKind.RequireSignature}, but got kind ${kind}`
      );

    const key = Crypto.Ed25519KeyHashHex(HexBlob.fromBytes(reader.readByteString()));

    const script = new ScriptPubkey(key);

    script.#originalBytes = cbor;

    return script;
  }

  /**
   * Creates a Core ScriptPubkey object from the current ScriptPubkey object.
   *
   * @returns The Core RequireSignatureScript object.
   */
  toCore(): Cardano.RequireSignatureScript {
    return {
      __type: ScriptType.Native,
      keyHash: this.#keyHash,
      kind: NativeScriptKind.RequireSignature
    };
  }

  /**
   * Creates a ScriptPubkey object from the given Core RequireSignatureScript object.
   *
   * @param script The core RequireSignatureScript object.
   */
  static fromCore(script: Cardano.RequireSignatureScript) {
    return new ScriptPubkey(script.keyHash);
  }

  /**
   * Gets the hash of a verification key.
   *
   * @returns The hash of a Ed25519 verification key.
   */
  keyHash(): Crypto.Ed25519KeyHashHex {
    return this.#keyHash;
  }

  /**
   * Sets the hash of a verification key.
   *
   * @param keyHash The hash of an Ed25519 verification key.
   */
  setKeyHash(keyHash: Crypto.Ed25519KeyHashHex): void {
    this.#keyHash = keyHash;
    this.#originalBytes = undefined;
  }
}
