import * as Cardano from '../../../Cardano/index.js';
import * as Crypto from '@cardano-sdk/crypto';
import { CborReader } from '../../CBOR/index.js';
import { HexBlob, InvalidStateError } from '@cardano-sdk/util';
import { ScriptAll } from './ScriptAll.js';
import { ScriptAny } from './ScriptAny.js';
import { ScriptNOfK } from './ScriptNOfK.js';
import { ScriptPubkey } from './ScriptPubkey.js';
import { TimelockExpiry } from './TimelockExpiry.js';
import { TimelockStart } from './TimelockStart.js';

const HASH_LENGTH_IN_BYTES = 28;

/**
 * The Native scripts form an expression tree, the evaluation of the script produces either true or false.
 *
 * Note that it is recursive. There are no constraints on the nesting or size, except that imposed by the overall
 * transaction size limit (given that the script must be included in the transaction in a script witnesses).
 */
export class NativeScript {
  #scriptAll: ScriptAll | undefined;
  #scriptAny: ScriptAny | undefined;
  #scripNOfK: ScriptNOfK | undefined;
  #scriptPubKey: ScriptPubkey | undefined;
  #timelockExpiry: TimelockExpiry | undefined;
  #timelockStart: TimelockStart | undefined;
  #kind: Cardano.NativeScriptKind;
  #originalBytes: HexBlob | undefined = undefined;

  /**
   * Serializes a NativeScript into CBOR format.
   *
   * @returns The NativeScript in CBOR format.
   */
  toCbor(): HexBlob {
    if (this.#originalBytes) return this.#originalBytes;

    let cbor;

    switch (this.#kind) {
      case Cardano.NativeScriptKind.RequireSignature:
        cbor = this.#scriptPubKey!.toCbor();
        break;
      case Cardano.NativeScriptKind.RequireAllOf:
        cbor = this.#scriptAll!.toCbor();
        break;
      case Cardano.NativeScriptKind.RequireAnyOf:
        cbor = this.#scriptAny!.toCbor();
        break;
      case Cardano.NativeScriptKind.RequireNOf:
        cbor = this.#scripNOfK!.toCbor();
        break;
      case Cardano.NativeScriptKind.RequireTimeAfter:
        cbor = this.#timelockStart!.toCbor();
        break;
      case Cardano.NativeScriptKind.RequireTimeBefore:
        cbor = this.#timelockExpiry!.toCbor();
        break;
      default:
        throw new InvalidStateError(`Unexpected kind value: ${this.#kind}`);
    }

    return cbor;
  }

  /**
   * Deserializes the NativeScript from a CBOR byte array.
   *
   * @param cbor The CBOR encoded NativeScript object.
   * @returns The new NativeScript instance.
   */
  static fromCbor(cbor: HexBlob): NativeScript {
    let nativeScript: NativeScript;

    const reader = new CborReader(cbor);

    reader.readStartArray();
    const kind = Number(reader.readInt());

    switch (kind) {
      case Cardano.NativeScriptKind.RequireSignature:
        nativeScript = NativeScript.newScriptPubkey(ScriptPubkey.fromCbor(cbor));
        break;
      case Cardano.NativeScriptKind.RequireAllOf:
        nativeScript = NativeScript.newScriptAll(ScriptAll.fromCbor(cbor));
        break;
      case Cardano.NativeScriptKind.RequireAnyOf:
        nativeScript = NativeScript.newScriptAny(ScriptAny.fromCbor(cbor));
        break;
      case Cardano.NativeScriptKind.RequireNOf:
        nativeScript = NativeScript.newScriptNOfK(ScriptNOfK.fromCbor(cbor));
        break;
      case Cardano.NativeScriptKind.RequireTimeAfter:
        nativeScript = NativeScript.newTimelockStart(TimelockStart.fromCbor(cbor));
        break;
      case Cardano.NativeScriptKind.RequireTimeBefore:
        nativeScript = NativeScript.newTimelockExpiry(TimelockExpiry.fromCbor(cbor));
        break;
      default:
        throw new InvalidStateError(`Unexpected kind value: ${kind}`);
    }

    nativeScript.#originalBytes = cbor;

    return nativeScript;
  }

  /**
   * Creates a Core NativeScript object from the current NativeScript object.
   *
   * @returns The Core NativeScript object.
   */
  toCore(): Cardano.NativeScript {
    let core;

    switch (this.#kind) {
      case Cardano.NativeScriptKind.RequireSignature:
        core = this.#scriptPubKey!.toCore();
        break;
      case Cardano.NativeScriptKind.RequireAllOf:
        core = this.#scriptAll!.toCore();
        break;
      case Cardano.NativeScriptKind.RequireAnyOf:
        core = this.#scriptAny!.toCore();
        break;
      case Cardano.NativeScriptKind.RequireNOf:
        core = this.#scripNOfK!.toCore();
        break;
      case Cardano.NativeScriptKind.RequireTimeAfter:
        core = this.#timelockStart!.toCore();
        break;
      case Cardano.NativeScriptKind.RequireTimeBefore:
        core = this.#timelockExpiry!.toCore();
        break;
      default:
        throw new InvalidStateError(`Unexpected kind value: ${this.#kind}`);
    }

    return core;
  }

  /**
   * Creates a NativeScript object from the given Core NativeScript object.
   *
   * @param script The core NativeScript object.
   */
  static fromCore(script: Cardano.NativeScript): NativeScript {
    let nativeScript: NativeScript;

    switch (script.kind) {
      case Cardano.NativeScriptKind.RequireSignature:
        nativeScript = NativeScript.newScriptPubkey(ScriptPubkey.fromCore(script));
        break;
      case Cardano.NativeScriptKind.RequireAllOf:
        nativeScript = NativeScript.newScriptAll(ScriptAll.fromCore(script));
        break;
      case Cardano.NativeScriptKind.RequireAnyOf:
        nativeScript = NativeScript.newScriptAny(ScriptAny.fromCore(script));
        break;
      case Cardano.NativeScriptKind.RequireNOf:
        nativeScript = NativeScript.newScriptNOfK(ScriptNOfK.fromCore(script));
        break;
      case Cardano.NativeScriptKind.RequireTimeAfter:
        nativeScript = NativeScript.newTimelockStart(TimelockStart.fromCore(script));
        break;
      case Cardano.NativeScriptKind.RequireTimeBefore:
        nativeScript = NativeScript.newTimelockExpiry(TimelockExpiry.fromCore(script));
        break;
      default:
        throw new InvalidStateError('Unexpected kind value'); // Shouldn't happen.
    }

    return nativeScript;
  }

  /**
   * Computes the script hash of this native script.
   *
   * @returns the script hash.
   */
  hash(): Crypto.Hash28ByteBase16 {
    // To compute a script hash, note that you must prepend a tag to the bytes of
    // the script before hashing. The tags in the Babbage era for native scripts is "\x00"
    const bytes = `00${this.toCbor()}`;

    const hash = Crypto.blake2b(HASH_LENGTH_IN_BYTES).update(Buffer.from(bytes, 'hex')).digest();

    return Crypto.Hash28ByteBase16(HexBlob.fromBytes(hash));
  }

  /**
   * Gets the native script kind.
   *
   * @returns The native script kind.
   */
  kind(): Cardano.NativeScriptKind {
    return this.#kind;
  }

  /**
   * Gets a NativeScript from a ScriptPubkey instance.
   *
   * @param scriptPubkey The ScriptPubkey instance to 'cast' to native script.
   */
  static newScriptPubkey(scriptPubkey: ScriptPubkey): NativeScript {
    const script = new NativeScript();

    script.#scriptPubKey = scriptPubkey;
    script.#kind = Cardano.NativeScriptKind.RequireSignature;

    return script;
  }

  /**
   * Gets a NativeScript from a ScriptAll instance.
   *
   * @param scriptAll The ScriptAll instance to 'cast' to native script.
   */
  static newScriptAll(scriptAll: ScriptAll): NativeScript {
    const script = new NativeScript();

    script.#scriptAll = scriptAll;
    script.#kind = Cardano.NativeScriptKind.RequireAllOf;

    return script;
  }

  /**
   * Gets a NativeScript from a ScriptAny instance.
   *
   * @param scriptAny The ScriptAny instance to 'cast' to native script.
   */
  static newScriptAny(scriptAny: ScriptAny): NativeScript {
    const script = new NativeScript();

    script.#scriptAny = scriptAny;
    script.#kind = Cardano.NativeScriptKind.RequireAnyOf;

    return script;
  }

  /**
   * Gets a NativeScript from a ScriptNOfK instance.
   *
   * @param scriptNOfK The ScriptNOfK instance to 'cast' to native script.
   */
  static newScriptNOfK(scriptNOfK: ScriptNOfK): NativeScript {
    const script = new NativeScript();

    script.#scripNOfK = scriptNOfK;
    script.#kind = Cardano.NativeScriptKind.RequireNOf;

    return script;
  }

  /**
   * Gets a NativeScript from a TimelockStart instance.
   *
   * @param timelockStart The TimelockStart instance to 'cast' to native script.
   */
  static newTimelockStart(timelockStart: TimelockStart): NativeScript {
    const script = new NativeScript();

    script.#timelockStart = timelockStart;
    script.#kind = Cardano.NativeScriptKind.RequireTimeAfter;

    return script;
  }

  /**
   * Gets a NativeScript from a TimelockExpiry instance.
   *
   * @param timelockExpiry The TimelockExpiry instance to 'cast' to native script.
   */
  static newTimelockExpiry(timelockExpiry: TimelockExpiry): NativeScript {
    const script = new NativeScript();

    script.#timelockExpiry = timelockExpiry;
    script.#kind = Cardano.NativeScriptKind.RequireTimeBefore;

    return script;
  }

  /**
   * Gets a ScriptPubkey from a NativeScript instance.
   *
   * @returns a ScriptPubkey if the native script can be down cast, otherwise, undefined.
   */
  asScriptPubkey(): ScriptPubkey | undefined {
    return this.#scriptPubKey;
  }

  /**
   * Gets a ScriptAll from a NativeScript instance.
   *
   * @returns a ScriptAll if the native script can be down cast, otherwise, undefined.
   */
  asScriptAll(): ScriptAll | undefined {
    return this.#scriptAll;
  }

  /**
   * Gets a ScriptAny from a NativeScript instance.
   *
   * @returns a ScriptAny if the native script can be down cast, otherwise, undefined.
   */
  asScriptAny(): ScriptAny | undefined {
    return this.#scriptAny;
  }

  /**
   * Gets a ScriptNOfK from a NativeScript instance.
   *
   * @returns a ScriptNOfK if the native script can be down cast, otherwise, undefined.
   */
  asScriptNOfK(): ScriptNOfK | undefined {
    return this.#scripNOfK;
  }

  /**
   * Gets a TimelockStart from a NativeScript instance.
   *
   * @returns a TimelockStart if the native script can be down cast, otherwise, undefined.
   */
  asTimelockStart(): TimelockStart | undefined {
    return this.#timelockStart;
  }

  /**
   * Gets a TimelockExpiry from a NativeScript instance.
   *
   * @returns a TimelockExpiry if the native script can be down cast, otherwise, undefined.
   */
  asTimelockExpiry(): TimelockExpiry | undefined {
    return this.#timelockExpiry;
  }
}
