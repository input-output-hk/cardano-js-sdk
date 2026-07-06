import { CborReader, CborWriter } from '../../CBOR';
import { Credential } from '../../Common/Credential';
import { HexBlob, InvalidArgumentError } from '@cardano-sdk/util';
import { NativeScriptKind, ScriptType } from '../../../Cardano/types/Script';
import type * as Cardano from '../../../Cardano';

const EMBEDDED_GROUP_SIZE = 2;

/**
 * This script evaluates to true if the given credential is present in the guards of the
 * transaction body (Dijkstra era onwards).
 */
export class RequireGuard {
  #credential: Credential;
  #originalBytes: HexBlob | undefined = undefined;

  /**
   * Initializes a new instance of the RequireGuard class.
   *
   * @param credential The credential that must be present in the transaction body guards.
   */
  constructor(credential: Credential) {
    this.#credential = credential;
  }

  /**
   * Serializes a RequireGuard into CBOR format.
   *
   * @returns The RequireGuard in CBOR format.
   */
  toCbor(): HexBlob {
    const writer = new CborWriter();

    if (this.#originalBytes) return this.#originalBytes;

    // CDDL
    // script_require_guard = (6, credential)
    writer.writeStartArray(EMBEDDED_GROUP_SIZE);
    writer.writeInt(NativeScriptKind.RequireGuard);
    writer.writeEncodedValue(Buffer.from(this.#credential.toCbor(), 'hex'));

    return writer.encodeAsHex();
  }

  /**
   * Deserializes the RequireGuard from a CBOR byte array.
   *
   * @param cbor The CBOR encoded RequireGuard object.
   * @returns The new RequireGuard instance.
   */
  static fromCbor(cbor: HexBlob): RequireGuard {
    const reader = new CborReader(cbor);

    const length = reader.readStartArray();

    if (length !== EMBEDDED_GROUP_SIZE)
      throw new InvalidArgumentError(
        'cbor',
        `Expected an array of two elements, but got an array of ${length} elements`
      );

    const kind = Number(reader.readInt());

    if (kind !== NativeScriptKind.RequireGuard)
      throw new InvalidArgumentError('cbor', `Expected kind ${NativeScriptKind.RequireGuard}, but got kind ${kind}`);

    const credential = Credential.fromCbor(HexBlob.fromBytes(reader.readEncodedValue()));

    const script = new RequireGuard(credential);

    script.#originalBytes = cbor;

    return script;
  }

  /**
   * Creates a Core RequireGuardScript object from the current RequireGuard object.
   *
   * @returns The Core RequireGuardScript object.
   */
  toCore(): Cardano.RequireGuardScript {
    return {
      __type: ScriptType.Native,
      credential: this.#credential.toCore(),
      kind: NativeScriptKind.RequireGuard
    };
  }

  /**
   * Creates a RequireGuard object from the given Core RequireGuardScript object.
   *
   * @param script The core RequireGuardScript object.
   */
  static fromCore(script: Cardano.RequireGuardScript) {
    return new RequireGuard(Credential.fromCore(script.credential));
  }

  /**
   * Gets the credential that must be present in the transaction body guards.
   *
   * @returns The credential.
   */
  credential(): Credential {
    return this.#credential;
  }

  /**
   * Sets the credential that must be present in the transaction body guards.
   *
   * @param credential The credential.
   */
  setCredential(credential: Credential): void {
    this.#credential = credential;
    this.#originalBytes = undefined;
  }
}
