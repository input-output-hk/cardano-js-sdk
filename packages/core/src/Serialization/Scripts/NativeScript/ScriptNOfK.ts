import * as Cardano from '../../../Cardano/index.js';
import { CborReader, CborReaderState, CborWriter } from '../../CBOR/index.js';
import { HexBlob, InvalidArgumentError } from '@cardano-sdk/util';
import { NativeScript } from './NativeScript.js';

const EMBEDDED_GROUP_SIZE = 3;

/**
 * This script evaluates to true if any the sub-scripts evaluate to true. That is, if one
 * or more evaluate to true.
 *
 * If the list of sub-scripts is empty, this script evaluates to false.
 */
export class ScriptNOfK {
  #nativeScripts: Array<NativeScript>;
  #required: number;
  #originalBytes: HexBlob | undefined = undefined;

  /**
   * Initializes a new instance of the ScriptNOfK class.
   *
   * @param nativeScripts The list of sub-scripts.
   * @param required The number of sub-scripts that must evaluate to true for this script to evaluate to true.
   */
  constructor(nativeScripts: Array<NativeScript>, required: number) {
    this.#nativeScripts = nativeScripts;
    this.#required = required;
  }

  /**
   * Serializes a ScriptNOfK into CBOR format.
   *
   * @returns The ScriptNOfK in CBOR format.
   */
  toCbor(): HexBlob {
    const writer = new CborWriter();

    if (this.#originalBytes) return this.#originalBytes;

    // CDDL
    // script_n_of_k = (3, n: uint, [ * native_script ])
    writer.writeStartArray(EMBEDDED_GROUP_SIZE);
    writer.writeInt(Cardano.NativeScriptKind.RequireNOf);
    writer.writeInt(this.#required);
    writer.writeStartArray(this.#nativeScripts.length);

    for (const nativeScript of this.#nativeScripts) writer.writeEncodedValue(Buffer.from(nativeScript.toCbor(), 'hex'));

    return writer.encodeAsHex();
  }

  /**
   * Deserializes the ScriptNOfK from a CBOR byte array.
   *
   * @param cbor The CBOR encoded ScriptNOfK object.
   * @returns The new ScriptNOfK instance.
   */
  static fromCbor(cbor: HexBlob): ScriptNOfK {
    const reader = new CborReader(cbor);

    const length = reader.readStartArray();

    if (length !== EMBEDDED_GROUP_SIZE)
      throw new InvalidArgumentError(
        'cbor',
        `Expected an array of two elements, but got an array of ${length} elements`
      );

    const kind = Number(reader.readInt());

    if (kind !== Cardano.NativeScriptKind.RequireNOf)
      throw new InvalidArgumentError(
        'cbor',
        `Expected kind ${Cardano.NativeScriptKind.RequireNOf}, but got kind ${kind}`
      );

    const required = reader.readInt();

    const scripts = new Array<NativeScript>();

    reader.readStartArray();

    while (reader.peekState() !== CborReaderState.EndArray)
      scripts.push(NativeScript.fromCbor(HexBlob.fromBytes(reader.readEncodedValue())));

    reader.readEndArray();

    const script = new ScriptNOfK(scripts, Number(required));

    script.#originalBytes = cbor;

    return script;
  }

  /**
   * Creates a Core RequireAtLeastScript object from the current ScriptNOfK object.
   *
   * @returns The Core RequireAtLeastScript object.
   */
  toCore(): Cardano.RequireAtLeastScript {
    return {
      __type: Cardano.ScriptType.Native,
      kind: Cardano.NativeScriptKind.RequireNOf,
      required: this.#required,
      scripts: this.#nativeScripts.map((script) => script.toCore())
    };
  }

  /**
   * Creates a ScriptNOfK object from the given Core RequireAtLeastScript object.
   *
   * @param script The core RequireAtLeastScript object.
   */
  static fromCore(script: Cardano.RequireAtLeastScript) {
    return new ScriptNOfK(
      script.scripts.map((nativeScript) => NativeScript.fromCore(nativeScript)),
      script.required
    );
  }

  /**
   * Gets the number of sub-scripts.
   *
   * @returns The number of sub-scripts that must evaluate to true for this script to evaluate to true.
   */
  required(): number {
    return this.#required;
  }

  /**
   * Sets the number of sub-scripts.
   *
   * @param required The number of sub-scripts that must evaluate to true for this script to evaluate to true.
   */
  setRequired(required: number): void {
    this.#required = required;
    this.#originalBytes = undefined;
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
