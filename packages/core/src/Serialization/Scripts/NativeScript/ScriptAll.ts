import * as Cardano from '../../../Cardano/index.js';
import { CborReader, CborReaderState, CborWriter } from '../../CBOR/index.js';
import { HexBlob, InvalidArgumentError } from '@cardano-sdk/util';
import { NativeScript } from './NativeScript.js';

const EMBEDDED_GROUP_SIZE = 2;

/**
 * This script evaluates to true if all the sub-scripts evaluate to true.
 *
 * If the list of sub-scripts is empty, this script evaluates to true.
 */
export class ScriptAll {
  #nativeScripts: Array<NativeScript>;
  #originalBytes: HexBlob | undefined = undefined;

  /**
   * Initializes a new instance of the ScriptAll class.
   *
   * @param nativeScripts The list of sub-scripts.
   */
  constructor(nativeScripts: Array<NativeScript>) {
    this.#nativeScripts = nativeScripts;
  }

  /**
   * Serializes a ScriptAll into CBOR format.
   *
   * @returns The ScriptAll in CBOR format.
   */
  toCbor(): HexBlob {
    const writer = new CborWriter();

    if (this.#originalBytes) return this.#originalBytes;

    // CDDL
    // script_all = (1, [ * native_script ])
    writer.writeStartArray(EMBEDDED_GROUP_SIZE);
    writer.writeInt(Cardano.NativeScriptKind.RequireAllOf);
    writer.writeStartArray(this.#nativeScripts.length);

    for (const nativeScript of this.#nativeScripts) writer.writeEncodedValue(Buffer.from(nativeScript.toCbor(), 'hex'));

    return writer.encodeAsHex();
  }

  /**
   * Deserializes the ScriptAll from a CBOR byte array.
   *
   * @param cbor The CBOR encoded ScriptAll object.
   * @returns The new ScriptAll instance.
   */
  static fromCbor(cbor: HexBlob): ScriptAll {
    const reader = new CborReader(cbor);

    const length = reader.readStartArray();

    if (length !== EMBEDDED_GROUP_SIZE)
      throw new InvalidArgumentError(
        'cbor',
        `Expected an array of two elements, but got an array of ${length} elements`
      );

    const kind = Number(reader.readInt());

    if (kind !== Cardano.NativeScriptKind.RequireAllOf)
      throw new InvalidArgumentError(
        'cbor',
        `Expected kind ${Cardano.NativeScriptKind.RequireAllOf}, but got kind ${kind}`
      );

    const scripts = new Array<NativeScript>();

    reader.readStartArray();

    while (reader.peekState() !== CborReaderState.EndArray)
      scripts.push(NativeScript.fromCbor(HexBlob.fromBytes(reader.readEncodedValue())));

    reader.readEndArray();

    const script = new ScriptAll(scripts);

    script.#originalBytes = cbor;

    return script;
  }

  /**
   * Creates a Core RequireAllOfScript object from the current ScriptAll object.
   *
   * @returns The Core RequireAllOfScript object.
   */
  toCore(): Cardano.RequireAllOfScript {
    return {
      __type: Cardano.ScriptType.Native,
      kind: Cardano.NativeScriptKind.RequireAllOf,
      scripts: this.#nativeScripts.map((script) => script.toCore())
    };
  }

  /**
   * Creates a ScriptAll object from the given Core RequireAllOfScript object.
   *
   * @param script The core RequireAllOfScript object.
   */
  static fromCore(script: Cardano.RequireAllOfScript) {
    return new ScriptAll(script.scripts.map((nativeScript) => NativeScript.fromCore(nativeScript)));
  }

  /**
   * Gets the list of sub-scripts.
   *
   * @returns The list of sub-scripts.
   */
  nativeScripts(): Array<NativeScript> {
    return this.#nativeScripts;
  }

  /**
   * Sets the list of sub-scripts.
   *
   * @param nativeScripts The list of sub-scripts.
   */
  setNativeScripts(nativeScripts: Array<NativeScript>) {
    this.#nativeScripts = nativeScripts;
    this.#originalBytes = undefined;
  }
}
