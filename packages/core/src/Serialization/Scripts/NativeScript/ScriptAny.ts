import { CborReader, CborReaderState, CborWriter } from '../../CBOR';
import { HexBlob, InvalidArgumentError } from '@cardano-sdk/util';
import { NativeScript } from './NativeScript';
import { NativeScriptKind, RequireAnyOfScript, ScriptType } from '../../../Cardano/types';

const EMBEDDED_GROUP_SIZE = 2;

/**
 * This script evaluates to true if any the sub-scripts evaluate to true. That is, if one
 * or more evaluate to true.
 *
 * If the list of sub-scripts is empty, this script evaluates to false.
 */
export class ScriptAny {
  #nativeScripts: Array<NativeScript>;
  #originalBytes: HexBlob | undefined = undefined;

  /**
   * Initializes a new instance of the ScriptAny class.
   *
   * @param nativeScripts The list of sub-scripts.
   */
  constructor(nativeScripts: Array<NativeScript>) {
    this.#nativeScripts = nativeScripts;
  }

  /**
   * Serializes a ScriptAny into CBOR format.
   *
   * @returns The ScriptAny in CBOR format.
   */
  toCbor(): HexBlob {
    const writer = new CborWriter();

    if (this.#originalBytes) return this.#originalBytes;

    // CDDL
    // script_any = (2, [ * native_script ])
    writer.writeStartArray(EMBEDDED_GROUP_SIZE);
    writer.writeInt(NativeScriptKind.RequireAnyOf);
    writer.writeStartArray(this.#nativeScripts.length);

    for (const nativeScript of this.#nativeScripts) writer.writeEncodedValue(Buffer.from(nativeScript.toCbor(), 'hex'));

    return writer.encodeAsHex();
  }

  /**
   * Deserializes the ScriptAny from a CBOR byte array.
   *
   * @param cbor The CBOR encoded ScriptAny object.
   * @returns The new ScriptAny instance.
   */
  static fromCbor(cbor: HexBlob): ScriptAny {
    const reader = new CborReader(cbor);

    const length = reader.readStartArray();

    if (length !== EMBEDDED_GROUP_SIZE)
      throw new InvalidArgumentError(
        'cbor',
        `Expected an array of two elements, but got an array of ${length} elements`
      );

    const kind = Number(reader.readInt());

    if (kind !== NativeScriptKind.RequireAnyOf)
      throw new InvalidArgumentError('cbor', `Expected kind ${NativeScriptKind.RequireAnyOf}, but got kind ${kind}`);

    const scripts = new Array<NativeScript>();

    reader.readStartArray();

    while (reader.peekState() !== CborReaderState.EndArray)
      scripts.push(NativeScript.fromCbor(HexBlob.fromBytes(reader.readEncodedValue())));

    reader.readEndArray();

    const script = new ScriptAny(scripts);

    script.#originalBytes = cbor;

    return script;
  }

  /**
   * Creates a Core RequireAnyOfScript object from the current ScriptAny object.
   *
   * @returns The Core RequireAnyOfScript object.
   */
  toCore(): RequireAnyOfScript {
    return {
      __type: ScriptType.Native,
      kind: NativeScriptKind.RequireAnyOf,
      scripts: this.#nativeScripts.map((script) => script.toCore())
    };
  }

  /**
   * Creates a ScriptAny object from the given Core RequireAnyOfScript object.
   *
   * @param script The core RequireAnyOfScript object.
   */
  static fromCore(script: RequireAnyOfScript) {
    return new ScriptAny(script.scripts.map((nativeScript) => NativeScript.fromCore(nativeScript)));
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
