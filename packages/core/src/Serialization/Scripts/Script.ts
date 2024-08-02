import * as Crypto from '@cardano-sdk/crypto';
import { CborReader, CborWriter } from '../CBOR';
import { HexBlob, InvalidStateError } from '@cardano-sdk/util';
import { NativeScript } from './NativeScript';
import { PlutusLanguageVersion, isNativeScript } from '../../Cardano/types/Script';
import { PlutusV1Script, PlutusV2Script, PlutusV3Script } from './PlutusScript';
import { ScriptLanguage } from './ScriptLanguage';
import type * as Cardano from '../../Cardano';

const SCRIPT_SUBGROUP = 2;

/** Program that decides whether the transaction that spends the output is authorized to do so. */
export class Script {
  #nativeScript: NativeScript | undefined;
  #plutusV1: PlutusV1Script | undefined;
  #plutusV2: PlutusV2Script | undefined;
  #plutusV3: PlutusV3Script | undefined;
  #language: ScriptLanguage;
  #originalBytes: HexBlob | undefined = undefined;

  /**
   * Serializes a Script into CBOR format.
   *
   * @returns The Script in CBOR format.
   */
  toCbor(): HexBlob {
    if (this.#originalBytes) return this.#originalBytes;

    // CDDL
    // script = [ 0, native_script // 1, plutus_v1_script // 2, plutus_v2_script // 3, plutus_v3_script ]
    const writer = new CborWriter();

    let cbor;

    switch (this.#language) {
      case ScriptLanguage.Native:
        cbor = this.#nativeScript!.toCbor();
        break;
      case ScriptLanguage.PlutusV1:
        cbor = this.#plutusV1!.toCbor();
        break;
      case ScriptLanguage.PlutusV2:
        cbor = this.#plutusV2!.toCbor();
        break;
      case ScriptLanguage.PlutusV3:
        cbor = this.#plutusV3!.toCbor();
        break;
      default:
        throw new InvalidStateError(`Unexpected language value: ${this.#language}`);
    }

    writer.writeStartArray(SCRIPT_SUBGROUP);
    writer.writeInt(this.#language);
    writer.writeEncodedValue(Buffer.from(cbor, 'hex'));

    return writer.encodeAsHex();
  }

  /**
   * Deserializes the Script from a CBOR byte array.
   *
   * @param cbor The CBOR encoded Script object.
   * @returns The new Script instance.
   */
  static fromCbor(cbor: HexBlob): Script {
    let script: Script;

    const reader = new CborReader(cbor);

    reader.readStartArray();

    const language = Number(reader.readInt());
    const innerScript = HexBlob.fromBytes(reader.readEncodedValue());

    switch (language) {
      case ScriptLanguage.Native:
        script = Script.newNativeScript(NativeScript.fromCbor(innerScript));
        break;
      case ScriptLanguage.PlutusV1:
        script = Script.newPlutusV1Script(PlutusV1Script.fromCbor(innerScript));
        break;
      case ScriptLanguage.PlutusV2:
        script = Script.newPlutusV2Script(PlutusV2Script.fromCbor(innerScript));
        break;
      case ScriptLanguage.PlutusV3:
        script = Script.newPlutusV3Script(PlutusV3Script.fromCbor(innerScript));
        break;
      default:
        throw new InvalidStateError(`Unexpected language value: ${language}`);
    }

    script.#originalBytes = cbor;

    return script;
  }

  /**
   * Creates a Core Script object from the current Script object.
   *
   * @returns The Core Script object.
   */
  toCore(): Cardano.Script {
    let core;

    switch (this.#language) {
      case ScriptLanguage.Native:
        core = this.#nativeScript!.toCore();
        break;
      case ScriptLanguage.PlutusV1:
        core = this.#plutusV1!.toCore();
        break;
      case ScriptLanguage.PlutusV2:
        core = this.#plutusV2!.toCore();
        break;
      case ScriptLanguage.PlutusV3:
        core = this.#plutusV3!.toCore();
        break;
      default:
        throw new InvalidStateError(`Unexpected language: ${this.#language}`);
    }

    return core;
  }

  /**
   * Creates a Script object from the given Core Script object.
   *
   * @param coreScript The core Script object.
   */
  static fromCore(coreScript: Cardano.Script): Script {
    let script: Script;

    if (isNativeScript(coreScript)) {
      script = Script.newNativeScript(NativeScript.fromCore(coreScript));
    } else {
      switch (coreScript.version) {
        case PlutusLanguageVersion.V1:
          script = Script.newPlutusV1Script(PlutusV1Script.fromCore(coreScript));
          break;
        case PlutusLanguageVersion.V2:
          script = Script.newPlutusV2Script(PlutusV2Script.fromCore(coreScript));
          break;
        case PlutusLanguageVersion.V3:
          script = Script.newPlutusV3Script(PlutusV3Script.fromCore(coreScript));
          break;
        default:
          throw new InvalidStateError('Unexpected Plutus language version'); // Shouldn't happen.
      }
    }

    return script;
  }

  /**
   * Gets the script language.
   *
   * @returns the Script language.
   */
  language(): ScriptLanguage {
    return this.#language;
  }

  /**
   * Gets a Script from a NativeScript instance.
   *
   * @param nativeScript The NativeScript instance to 'cast' to Script.
   */
  static newNativeScript(nativeScript: NativeScript): Script {
    const script = new Script();

    script.#nativeScript = nativeScript;
    script.#language = ScriptLanguage.Native;

    return script;
  }

  /**
   * Gets a Script from a PlutusV1 instance.
   *
   * @param plutusV1Script The PlutusV1Script instance to 'cast' to Script.
   */
  static newPlutusV1Script(plutusV1Script: PlutusV1Script): Script {
    const script = new Script();

    script.#plutusV1 = plutusV1Script;
    script.#language = ScriptLanguage.PlutusV1;

    return script;
  }

  /**
   * Gets a Script from a PlutusV2 instance.
   *
   * @param plutusV2Script The PlutusV2Script instance to 'cast' to Script.
   */
  static newPlutusV2Script(plutusV2Script: PlutusV2Script): Script {
    const script = new Script();

    script.#plutusV2 = plutusV2Script;
    script.#language = ScriptLanguage.PlutusV2;

    return script;
  }

  /**
   * Gets a Script from a PlutusV3 instance.
   *
   * @param plutusV3Script The PlutusV3Script instance to 'cast' to Script.
   */
  static newPlutusV3Script(plutusV3Script: PlutusV3Script): Script {
    const script = new Script();

    script.#plutusV3 = plutusV3Script;
    script.#language = ScriptLanguage.PlutusV3;

    return script;
  }

  /**
   * Gets a NativeScript from a Script instance.
   *
   * @returns a NativeScript if the script can be down cast, otherwise, undefined.
   */
  asNative(): NativeScript | undefined {
    return this.#nativeScript;
  }

  /**
   * Gets a PlutusV1Script from a Script instance.
   *
   * @returns a PlutusV1Script if the script can be down cast, otherwise, undefined.
   */
  asPlutusV1(): PlutusV1Script | undefined {
    return this.#plutusV1;
  }

  /**
   * Gets a PlutusV2Script from a Script instance.
   *
   * @returns a PlutusV2Script if the script can be down cast, otherwise, undefined.
   */
  asPlutusV2(): PlutusV2Script | undefined {
    return this.#plutusV2;
  }

  /**
   * Gets a PlutusV3Script from a Script instance.
   *
   * @returns a PlutusV3Script if the script can be down cast, otherwise, undefined.
   */
  asPlutusV3(): PlutusV3Script | undefined {
    return this.#plutusV3;
  }

  /**
   * Computes the script hash of this script.
   *
   * @returns the script hash.
   */
  hash(): Crypto.Hash28ByteBase16 {
    let hash;
    switch (this.#language) {
      case ScriptLanguage.Native:
        hash = this.#nativeScript!.hash();
        break;
      case ScriptLanguage.PlutusV1:
        hash = this.#plutusV1!.hash();
        break;
      case ScriptLanguage.PlutusV2:
        hash = this.#plutusV2!.hash();
        break;
      case ScriptLanguage.PlutusV3:
        hash = this.#plutusV3!.hash();
        break;
      default:
        throw new InvalidStateError(`Unexpected script language ${this.#language}`); // Shouldn't happen.
    }

    return hash;
  }
}
