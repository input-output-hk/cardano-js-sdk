/* eslint-disable complexity,max-statements,sonarjs/cognitive-complexity */
import * as Cardano from '../../Cardano';
import { CborReader, CborReaderState, CborWriter } from '../CBOR';
import { GeneralTransactionMetadata } from './TransactionMetadata/GeneralTransactionMetadata';
import { HexBlob, InvalidArgumentError } from '@cardano-sdk/util';
import { NativeScript, PlutusV1Script, PlutusV2Script } from '../Scripts';
import { SerializationError, SerializationFailure } from '../../errors';
import { hexToBytes } from '../../util/misc';

export const SHELLEY_ERA_FIELDS_COUNT = 2;
export const ALONZO_AUX_TAG = 259;

/**
 * This type represents the segregated CDDL scripts.
 */
type CddlScripts = {
  native: Array<NativeScript> | undefined;
  plutusV1: Array<PlutusV1Script> | undefined;
  plutusV2: Array<PlutusV2Script> | undefined;
};

/**
 * Auxiliary Data encapsulate certain optional information that can be attached
 * to a transaction. This data includes transaction metadata and scripts.
 *
 * The Auxiliary Data is hashed and referenced in the transaction body.
 */
export class AuxiliaryData {
  #metadata: GeneralTransactionMetadata | undefined;
  #nativeScripts: Array<NativeScript> | undefined;
  #plutusV1Scripts: Array<PlutusV1Script> | undefined;
  #plutusV2Scripts: Array<PlutusV2Script> | undefined;
  #originalBytes: HexBlob | undefined = undefined;

  /**
   * Serializes a AuxiliaryData into CBOR format.
   *
   * @returns The AuxiliaryData in CBOR format.
   */
  toCbor(): HexBlob {
    if (this.#originalBytes) return this.#originalBytes;

    // CDDL
    // auxiliary_data =
    //   metadata ; Shelley
    //   / [ transaction_metadata: metadata ; Shelley-ma
    //     , auxiliary_scripts: [ * native_script ]
    //     ]
    //   / #6.259({ ? 0 => metadata         ; Alonzo and beyond
    //       , ? 1 => [ * native_script ]
    //       , ? 2 => [ * plutus_v1_script ]
    //       , ? 3 => [ * plutus_v2_script ]
    //       })
    const writer = new CborWriter();

    const elementsSize = this.#getMapSize();

    // if possible, we encode as the more compact format.
    if (elementsSize === 1 && this.#metadata && this.#metadata.metadata()!.size > 0) {
      writer.writeEncodedValue(hexToBytes(this.#metadata.toCbor()));
    } else if (
      elementsSize === SHELLEY_ERA_FIELDS_COUNT &&
      this.#metadata &&
      this.#metadata.metadata()!.size > 0 &&
      this.#nativeScripts &&
      this.#nativeScripts.length > 0
    ) {
      writer.writeStartArray(elementsSize);

      writer.writeEncodedValue(hexToBytes(this.#metadata.toCbor()));

      writer.writeStartArray(this.#nativeScripts.length);
      for (const script of this.#nativeScripts) {
        writer.writeEncodedValue(hexToBytes(script.toCbor()));
      }
    } else {
      writer.writeTag(ALONZO_AUX_TAG);
      writer.writeStartMap(this.#getMapSize());

      if (this.#metadata && this.#metadata.metadata()!.size > 0) {
        writer.writeInt(0n);
        writer.writeEncodedValue(hexToBytes(this.#metadata.toCbor()));
      }

      if (this.#nativeScripts && this.#nativeScripts.length > 0) {
        writer.writeInt(1n);
        writer.writeStartArray(this.#nativeScripts.length);
        for (const script of this.#nativeScripts) {
          writer.writeEncodedValue(hexToBytes(script.toCbor()));
        }
      }

      if (this.#plutusV1Scripts && this.#plutusV1Scripts.length > 0) {
        writer.writeInt(2n);
        writer.writeStartArray(this.#plutusV1Scripts.length);
        for (const script of this.#plutusV1Scripts) {
          writer.writeEncodedValue(hexToBytes(script.toCbor()));
        }
      }

      if (this.#plutusV2Scripts && this.#plutusV2Scripts.length > 0) {
        writer.writeInt(3n);
        writer.writeStartArray(this.#plutusV2Scripts.length);
        for (const script of this.#plutusV2Scripts) {
          writer.writeEncodedValue(hexToBytes(script.toCbor()));
        }
      }
    }

    return writer.encodeAsHex();
  }

  /**
   * Deserializes the AuxiliaryData from a CBOR byte array.
   *
   * @param cbor The CBOR encoded AuxiliaryData object.
   * @returns The new AuxiliaryData instance.
   */
  static fromCbor(cbor: HexBlob): AuxiliaryData {
    const reader = new CborReader(cbor);

    const auxData = new AuxiliaryData();

    const peekState = reader.peekState();

    // CDDL
    // auxiliary_data =
    //  #6.259({ ? 0 => metadata         ; Alonzo and beyond
    //     , ? 1 => [ * native_script ]
    //     , ? 2 => [ * plutus_v1_script ]
    //     , ? 3 => [ * plutus_v2_script ]
    //     })
    if (peekState === CborReaderState.StartMap) {
      auxData.#metadata = GeneralTransactionMetadata.fromCbor(HexBlob.fromBytes(reader.readEncodedValue()));
    } else if (peekState === CborReaderState.Tag) {
      const tag = reader.readTag() as number;

      if (tag !== ALONZO_AUX_TAG) {
        throw new InvalidArgumentError('cbor', `Expected tag '${ALONZO_AUX_TAG}', but got ${tag}.`);
      }

      reader.readStartMap();

      while (reader.peekState() !== CborReaderState.EndMap) {
        const key = reader.readInt();

        switch (key) {
          case 0n:
            auxData.#metadata = GeneralTransactionMetadata.fromCbor(HexBlob.fromBytes(reader.readEncodedValue()));
            break;
          case 1n:
            auxData.setNativeScripts(new Array<NativeScript>());
            reader.readStartArray();
            while (reader.peekState() !== CborReaderState.EndArray) {
              auxData.nativeScripts()!.push(NativeScript.fromCbor(HexBlob.fromBytes(reader.readEncodedValue())));
            }
            reader.readEndArray();
            break;
          case 2n: {
            auxData.setPlutusV1Scripts(new Array<PlutusV1Script>());
            reader.readStartArray();
            while (reader.peekState() !== CborReaderState.EndArray) {
              auxData.plutusV1Scripts()!.push(PlutusV1Script.fromCbor(HexBlob.fromBytes(reader.readEncodedValue())));
            }
            reader.readEndArray();
            break;
          }
          case 3n: {
            auxData.setPlutusV2Scripts(new Array<PlutusV2Script>());
            reader.readStartArray();
            while (reader.peekState() !== CborReaderState.EndArray) {
              auxData.plutusV2Scripts()!.push(PlutusV2Script.fromCbor(HexBlob.fromBytes(reader.readEncodedValue())));
            }
            reader.readEndArray();
            break;
          }
        }
      }

      reader.readEndMap();
    } else {
      // CDDL
      // auxiliary_data =
      //   metadata ; Shelley
      //   / [ transaction_metadata: metadata ; Shelley-ma
      //     , auxiliary_scripts: [ * native_script ]
      //     ]
      reader.readStartArray();

      auxData.#metadata = GeneralTransactionMetadata.fromCbor(HexBlob.fromBytes(reader.readEncodedValue()));

      auxData.setNativeScripts(new Array<NativeScript>());
      reader.readStartArray();
      while (reader.peekState() !== CborReaderState.EndArray) {
        auxData.nativeScripts()!.push(NativeScript.fromCbor(HexBlob.fromBytes(reader.readEncodedValue())));
      }
      reader.readEndArray();
    }

    auxData.#originalBytes = cbor;
    return auxData;
  }

  /**
   * Creates a Core AuxiliaryData object from the current AuxiliaryData object.
   *
   * @returns The Core AuxiliaryData object.
   */
  toCore(): Cardano.AuxiliaryData {
    const scripts = this.#getCoreScripts();
    return {
      blob: this.#metadata ? this.#metadata.toCore() : undefined,
      scripts: scripts.length > 0 ? scripts : undefined
    };
  }

  /**
   * Creates a AuxiliaryData object from the given Core AuxiliaryData object.
   *
   * @param auxData The core AuxiliaryData object.
   */
  static fromCore(auxData: Cardano.AuxiliaryData): AuxiliaryData {
    const result = new AuxiliaryData();

    if (auxData.blob) {
      result.setMetadata(GeneralTransactionMetadata.fromCore(auxData.blob));
    }

    if (auxData.scripts) {
      const scripts = AuxiliaryData.#getCddlScripts(auxData.scripts);

      if (scripts.native) result.setNativeScripts(scripts.native);
      if (scripts.plutusV1) result.setPlutusV1Scripts(scripts.plutusV1);
      if (scripts.plutusV2) result.setPlutusV2Scripts(scripts.plutusV2);
    }

    return result;
  }

  /**
   * Gets the transaction metadata. this is supplementary information that can be
   * attached to a transaction. It's not essential for transaction validation but
   * can be used for various purposes, including record-keeping, identity solutions, and more.
   *
   * @returns The transaction metadata.
   */
  metadata(): GeneralTransactionMetadata | undefined {
    return this.#metadata;
  }

  /**
   * Sets the transaction metadata. this is supplementary information that can be
   * attached to a transaction. It's not essential for transaction validation but
   * can be used for various purposes, including record-keeping, identity solutions, and more.
   *
   * @param metadata The transaction metadata.
   */
  setMetadata(metadata: GeneralTransactionMetadata) {
    this.#metadata = metadata;
    this.#originalBytes = undefined;
  }

  /**
   * Gets the set of native scripts present in the auxiliary data.
   *
   * @returns The set of native scripts.
   */
  nativeScripts(): Array<NativeScript> | undefined {
    return this.#nativeScripts;
  }

  /**
   * Sets the set of native scripts present in the auxiliary data.
   *
   * @param nativeScripts The set of native scripts.
   */
  setNativeScripts(nativeScripts: Array<NativeScript>) {
    this.#nativeScripts = nativeScripts;
    this.#originalBytes = undefined;
  }

  /**
   * Gets the set of plutus v1 scripts present in the auxiliary data.
   *
   * @returns The set of plutus v1 scripts.
   */
  plutusV1Scripts(): Array<PlutusV1Script> | undefined {
    return this.#plutusV1Scripts;
  }

  /**
   * Sets the set of v1 scripts scripts present in the auxiliary data.
   *
   * @param plutusV1Scripts The set of v1 scripts scripts.
   */
  setPlutusV1Scripts(plutusV1Scripts: Array<PlutusV1Script>) {
    this.#plutusV1Scripts = plutusV1Scripts;
    this.#originalBytes = undefined;
  }

  /**
   * Gets the set of plutus v2 scripts present in the auxiliary data.
   *
   * @returns The set of plutus v2 scripts.
   */
  plutusV2Scripts(): Array<PlutusV2Script> | undefined {
    return this.#plutusV2Scripts;
  }

  /**
   * Sets the set of v2 scripts present in the auxiliary data.
   *
   * @param plutusV2Scripts The set of v2 scripts.
   */
  setPlutusV2Scripts(plutusV2Scripts: Array<PlutusV2Script>) {
    this.#plutusV2Scripts = plutusV2Scripts;
    this.#originalBytes = undefined;
  }

  /**
   * Gets the size of the serialized map.
   *
   * @private
   */
  #getMapSize(): number {
    let mapSize = 0;

    if (this.#metadata !== undefined && this.#metadata.metadata()!.size > 0) ++mapSize;
    if (this.#nativeScripts !== undefined && this.#nativeScripts.length > 0) ++mapSize;
    if (this.#plutusV1Scripts !== undefined && this.#plutusV1Scripts.length > 0) ++mapSize;
    if (this.#plutusV2Scripts !== undefined && this.#plutusV2Scripts.length > 0) ++mapSize;

    return mapSize;
  }

  /**
   * Gets all the scripts present in this witness as Core scripts.
   *
   * @returns The list of scripts.
   * @private
   */
  #getCoreScripts(): Array<Cardano.Script> {
    const plutusV1 = this.#plutusV1Scripts ? this.#plutusV1Scripts.map((script) => script.toCore()) : [];
    const plutusV2 = this.#plutusV2Scripts ? this.#plutusV2Scripts.map((script) => script.toCore()) : [];
    const native = this.#nativeScripts ? this.#nativeScripts.map((script) => script.toCore()) : [];

    return [...plutusV1, ...plutusV2, ...native];
  }

  /**
   * Gets all the scripts present in this witness as CDDL scripts.
   *
   * @returns The list of scripts.
   * @private
   */
  static #getCddlScripts(scripts: Array<Cardano.Script>): CddlScripts {
    const result: CddlScripts = { native: undefined, plutusV1: undefined, plutusV2: undefined };

    for (const script of scripts) {
      switch (script.__type) {
        case Cardano.ScriptType.Native:
          if (!result.native) result.native = new Array<NativeScript>();

          result.native.push(NativeScript.fromCore(script));
          break;
        case Cardano.ScriptType.Plutus:
          if (script.version === Cardano.PlutusLanguageVersion.V1) {
            if (!result.plutusV1) result.plutusV1 = new Array<PlutusV1Script>();

            result.plutusV1.push(PlutusV1Script.fromCore(script));
          } else if (script.version === Cardano.PlutusLanguageVersion.V2) {
            if (!result.plutusV2) result.plutusV2 = new Array<PlutusV2Script>();

            result.plutusV2.push(PlutusV2Script.fromCore(script));
          }
          break;
        default:
          throw new SerializationError(SerializationFailure.InvalidScriptType, `Script '${script}' is not supported.`);
      }
    }

    return result;
  }
}
