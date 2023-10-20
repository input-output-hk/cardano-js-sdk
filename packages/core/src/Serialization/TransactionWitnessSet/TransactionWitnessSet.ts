/* eslint-disable sonarjs/cognitive-complexity, complexity, max-statements, unicorn/prefer-switch */
import * as Cardano from '../../Cardano';
import { BootstrapWitness } from './BootstrapWitness';
import { CborReader, CborReaderState, CborWriter } from '../CBOR';
import { HexBlob } from '@cardano-sdk/util';
import { NativeScript, PlutusV1Script, PlutusV2Script, PlutusV3Script } from '../Scripts';
import { PlutusData } from '../PlutusData/PlutusData';
import { Redeemer } from './Redeemer';
import { SerializationError, SerializationFailure } from '../../errors';
import { VkeyWitness } from './VkeyWitness';
import uniqWith from 'lodash/uniqWith';

/** This type represents the segregated CDDL scripts. */
type CddlScripts = {
  native: Array<NativeScript> | undefined;
  plutusV1: Array<PlutusV1Script> | undefined;
  plutusV2: Array<PlutusV2Script> | undefined;
  plutusV3: Array<PlutusV3Script> | undefined;
};

/**
 * A witness is a piece of information that allows you to efficiently verify the
 * authenticity of the transaction (also known as proof).
 *
 * In Cardano, transactions have multiple types of authentication proofs, these can range
 * from signatures for spending UTxOs, to scripts (with its arguments, datums and redeemers) for
 * smart contract execution.
 */
export class TransactionWitnessSet {
  #vkeywitnesses: Array<VkeyWitness> | undefined;
  #nativeScripts: Array<NativeScript> | undefined;
  #bootstrapWitnesses: Array<BootstrapWitness> | undefined;
  #plutusV1Scripts: Array<PlutusV1Script> | undefined;
  #plutusData: Array<PlutusData> | undefined;
  #redeemers: Array<Redeemer> | undefined;
  #plutusV2Scripts: Array<PlutusV2Script> | undefined;
  #plutusV3Scripts: Array<PlutusV3Script> | undefined;
  #originalBytes: HexBlob | undefined = undefined;

  /**
   * Serializes a TransactionWitnessSet into CBOR format.
   *
   * @returns The TransactionWitnessSet in CBOR format.
   */
  toCbor(): HexBlob {
    const writer = new CborWriter();

    if (this.#originalBytes) return this.#originalBytes;

    // CDDL
    // transaction_witness_set =
    //   { ? 0: [* vkeywitness ]
    //   , ? 1: [* native_script ]
    //   , ? 2: [* bootstrap_witness ]
    //   , ? 3: [* plutus_v1_script ]
    //   , ? 4: [* plutus_data ]
    //   , ? 5: [* redeemer ]
    //   , ? 6: [* plutus_v2_script ]
    //   , ? 7: [* plutus_v3_script ]
    //   }
    writer.writeStartMap(this.#getMapSize());

    if (this.#vkeywitnesses && this.#vkeywitnesses.length > 0) {
      const uniqueWitnesses = uniqWith(this.#vkeywitnesses, (lhs, rhs) => lhs.vkey() === rhs.vkey());

      writer.writeInt(0n);
      writer.writeStartArray(uniqueWitnesses.length);

      for (const witness of uniqueWitnesses) {
        writer.writeEncodedValue(Buffer.from(witness.toCbor(), 'hex'));
      }
    }

    if (this.#nativeScripts && this.#nativeScripts.length > 0) {
      writer.writeInt(1n);
      writer.writeStartArray(this.#nativeScripts.length);

      for (const script of this.#nativeScripts) {
        writer.writeEncodedValue(Buffer.from(script.toCbor(), 'hex'));
      }
    }

    if (this.#bootstrapWitnesses && this.#bootstrapWitnesses.length > 0) {
      const uniqueWitnesses = uniqWith(this.#bootstrapWitnesses, (lhs, rhs) => lhs.vkey() === rhs.vkey());

      writer.writeInt(2n);
      writer.writeStartArray(uniqueWitnesses.length);

      for (const witness of uniqueWitnesses) {
        writer.writeEncodedValue(Buffer.from(witness.toCbor(), 'hex'));
      }
    }

    if (this.#plutusV1Scripts && this.#plutusV1Scripts.length > 0) {
      writer.writeInt(3n);
      writer.writeStartArray(this.#plutusV1Scripts.length);

      for (const script of this.#plutusV1Scripts) {
        writer.writeEncodedValue(Buffer.from(script.toCbor(), 'hex'));
      }
    }

    if (this.#plutusData && this.#plutusData.length > 0) {
      writer.writeInt(4n);
      writer.writeStartArray(this.#plutusData.length);

      for (const data of this.#plutusData) {
        writer.writeEncodedValue(Buffer.from(data.toCbor(), 'hex'));
      }
    }

    if (this.#redeemers && this.#redeemers.length > 0) {
      writer.writeInt(5n);
      writer.writeStartArray(this.#redeemers.length);

      for (const data of this.#redeemers) {
        writer.writeEncodedValue(Buffer.from(data.toCbor(), 'hex'));
      }
    }

    if (this.#plutusV2Scripts && this.#plutusV2Scripts.length > 0) {
      writer.writeInt(6n);
      writer.writeStartArray(this.#plutusV2Scripts.length);

      for (const script of this.#plutusV2Scripts) {
        writer.writeEncodedValue(Buffer.from(script.toCbor(), 'hex'));
      }
    }

    if (this.#plutusV3Scripts && this.#plutusV3Scripts.length > 0) {
      writer.writeInt(7n);
      writer.writeStartArray(this.#plutusV3Scripts.length);

      for (const script of this.#plutusV3Scripts) {
        writer.writeEncodedValue(Buffer.from(script.toCbor(), 'hex'));
      }
    }

    return writer.encodeAsHex();
  }

  /**
   * Deserializes the TransactionWitnessSet from a CBOR byte array.
   *
   * @param cbor The CBOR encoded TransactionWitnessSet object.
   * @returns The new TransactionWitnessSet instance.
   */
  static fromCbor(cbor: HexBlob): TransactionWitnessSet {
    const reader = new CborReader(cbor);

    const witness = new TransactionWitnessSet();

    reader.readStartMap();

    while (reader.peekState() !== CborReaderState.EndMap) {
      const key = reader.readInt();

      switch (key) {
        case 0n:
          witness.setVkeys(new Array<VkeyWitness>());
          reader.readStartArray();

          while (reader.peekState() !== CborReaderState.EndArray) {
            witness.vkeys()!.push(VkeyWitness.fromCbor(HexBlob.fromBytes(reader.readEncodedValue())));
          }

          reader.readEndArray();
          break;
        case 1n:
          witness.setNativeScripts(new Array<NativeScript>());
          reader.readStartArray();

          while (reader.peekState() !== CborReaderState.EndArray) {
            witness.nativeScripts()!.push(NativeScript.fromCbor(HexBlob.fromBytes(reader.readEncodedValue())));
          }

          reader.readEndArray();
          break;
        case 2n:
          witness.setBootstraps(new Array<BootstrapWitness>());
          reader.readStartArray();

          while (reader.peekState() !== CborReaderState.EndArray) {
            witness.bootstraps()!.push(BootstrapWitness.fromCbor(HexBlob.fromBytes(reader.readEncodedValue())));
          }

          reader.readEndArray();
          break;
        case 3n:
          witness.setPlutusV1Scripts(new Array<PlutusV1Script>());
          reader.readStartArray();

          while (reader.peekState() !== CborReaderState.EndArray) {
            witness.plutusV1Scripts()!.push(PlutusV1Script.fromCbor(HexBlob.fromBytes(reader.readEncodedValue())));
          }

          reader.readEndArray();
          break;
        case 4n:
          witness.setPlutusData(new Array<PlutusData>());
          reader.readStartArray();

          while (reader.peekState() !== CborReaderState.EndArray) {
            witness.plutusData()!.push(PlutusData.fromCbor(HexBlob.fromBytes(reader.readEncodedValue())));
          }

          reader.readEndArray();
          break;
        case 5n:
          witness.setRedeemers(new Array<Redeemer>());
          reader.readStartArray();

          while (reader.peekState() !== CborReaderState.EndArray) {
            witness.redeemers()!.push(Redeemer.fromCbor(HexBlob.fromBytes(reader.readEncodedValue())));
          }

          reader.readEndArray();
          break;
        case 6n:
          witness.setPlutusV2Scripts(new Array<PlutusV2Script>());
          reader.readStartArray();

          while (reader.peekState() !== CborReaderState.EndArray) {
            witness.plutusV2Scripts()!.push(PlutusV2Script.fromCbor(HexBlob.fromBytes(reader.readEncodedValue())));
          }

          reader.readEndArray();
          break;
        case 7n:
          witness.setPlutusV3Scripts(new Array<PlutusV3Script>());
          reader.readStartArray();

          while (reader.peekState() !== CborReaderState.EndArray) {
            witness.plutusV3Scripts()!.push(PlutusV3Script.fromCbor(HexBlob.fromBytes(reader.readEncodedValue())));
          }

          reader.readEndArray();
          break;
      }
    }

    reader.readEndMap();

    witness.#originalBytes = cbor;

    return witness;
  }

  /**
   * Creates a Core Witness object from the current TransactionWitnessSet object.
   *
   * @returns The Core TransactionWitnessSet object.
   */
  toCore(): Cardano.Witness {
    const scripts = this.#getCoreScripts();
    return {
      bootstrap: this.#bootstrapWitnesses ? this.#bootstrapWitnesses.map((witness) => witness.toCore()) : undefined,
      datums: this.#plutusData ? this.#plutusData.map((data) => data.toCore()) : undefined,
      redeemers: this.#redeemers ? this.#redeemers.map((data) => data.toCore()) : undefined,
      scripts: scripts.length > 0 ? scripts : undefined,
      signatures: this.#vkeywitnesses ? new Map(this.#vkeywitnesses.map((witness) => witness.toCore())) : new Map()
    };
  }

  /**
   * Creates a TransactionWitnessSet object from the given Core Witness object.
   *
   * @param coreWitness The core Witness object.
   */
  static fromCore(coreWitness: Cardano.Witness): TransactionWitnessSet {
    const witness = new TransactionWitnessSet();

    if (coreWitness.signatures) {
      witness.setVkeys([...coreWitness.signatures].map((vkWitness) => VkeyWitness.fromCore(vkWitness)));
    }

    if (coreWitness.scripts) {
      const scripts = TransactionWitnessSet.#getCddlScripts(coreWitness.scripts);

      if (scripts.native) witness.setNativeScripts(scripts.native);
      if (scripts.plutusV1) witness.setPlutusV1Scripts(scripts.plutusV1);
      if (scripts.plutusV2) witness.setPlutusV2Scripts(scripts.plutusV2);
      if (scripts.plutusV3) witness.setPlutusV3Scripts(scripts.plutusV3);
    }

    if (coreWitness.redeemers) {
      witness.setRedeemers(coreWitness.redeemers.map((data) => Redeemer.fromCore(data)));
    }

    if (coreWitness.datums) {
      witness.setPlutusData(coreWitness.datums.map((data) => PlutusData.fromCore(data)));
    }

    if (coreWitness.bootstrap) {
      witness.setBootstraps(coreWitness.bootstrap.map((bootstrap) => BootstrapWitness.fromCore(bootstrap)));
    }

    return witness;
  }

  /**
   * Sets the Verification Key Witnesses, used to prove the spending of inputs on the transaction is
   * authorized by the corresponding private key(s).
   *
   * @param vkeys The set of verification key witnesses.
   */
  setVkeys(vkeys: Array<VkeyWitness>) {
    this.#vkeywitnesses = vkeys;
    this.#originalBytes = undefined;
  }

  /**
   * Gets the Verification Key Witnesses, used to prove the spending of inputs on the transaction is
   * authorized by the corresponding private key(s).
   *
   * @returns The set of verification key witnesses.
   */
  vkeys(): Array<VkeyWitness> | undefined {
    return this.#vkeywitnesses;
  }

  /**
   * Sets the set of native scripts required by this transaction.
   *
   * @param nativeScripts The set of native scripts.
   */
  setNativeScripts(nativeScripts: Array<NativeScript>) {
    this.#nativeScripts = nativeScripts;
    this.#originalBytes = undefined;
  }

  /**
   * Gets the set of native scripts required by this transaction.
   *
   * @returns The set of native scripts.
   */
  nativeScripts(): Array<NativeScript> | undefined {
    return this.#nativeScripts;
  }

  /**
   * Sets the witnesses for authorizing spending from UTxOs associated with Byron-era addresses.
   *
   * @param bootstraps The Bootstrap witnesses for this transaction.
   */
  setBootstraps(bootstraps: Array<BootstrapWitness>) {
    this.#bootstrapWitnesses = bootstraps;
    this.#originalBytes = undefined;
  }

  /**
   * Gets the witnesses for authorizing spending from UTxOs associated with Byron-era addresses.
   *
   * @returns The Bootstrap witnesses for this transaction.
   */
  bootstraps(): Array<BootstrapWitness> | undefined {
    return this.#bootstrapWitnesses;
  }

  /**
   * Sets the set of plutus v1 scripts required by this transaction.
   *
   * @param plutusV1Scripts The set of plutus v1 scripts.
   */
  setPlutusV1Scripts(plutusV1Scripts: Array<PlutusV1Script>) {
    this.#plutusV1Scripts = plutusV1Scripts;
    this.#originalBytes = undefined;
  }

  /**
   * Gets the set of plutus v1 scripts required by this transaction.
   *
   * @returns The set of plutus v1 scripts.
   */
  plutusV1Scripts(): Array<PlutusV1Script> | undefined {
    return this.#plutusV1Scripts;
  }

  /**
   * Sets the Plutus Data required by the Plutus scripts of this transaction.
   *
   * @param plutusData The Plutus Data.
   */
  setPlutusData(plutusData: Array<PlutusData>) {
    this.#plutusData = plutusData;
    this.#originalBytes = undefined;
  }

  /**
   * Gets the Plutus Data required by the Plutus scripts of this transaction.
   *
   * @returns The Plutus Data.
   */
  plutusData(): Array<PlutusData> | undefined {
    return this.#plutusData;
  }

  /**
   * Sets the redeemers required by the Plutus scripts of this transaction.
   *
   * @param redeemers The redeemers.
   */
  setRedeemers(redeemers: Array<Redeemer>) {
    this.#redeemers = redeemers;
    this.#originalBytes = undefined;
  }

  /**
   * Gets the redeemers required by the Plutus scripts of this transaction.
   *
   * @returns The redeemers.
   */
  redeemers(): Array<Redeemer> | undefined {
    return this.#redeemers;
  }

  /**
   * Sets the set of plutus v2 scripts required by this transaction.
   *
   * @param plutusV2Scripts The set of plutus v2 scripts.
   */
  setPlutusV2Scripts(plutusV2Scripts: Array<PlutusV2Script>) {
    this.#plutusV2Scripts = plutusV2Scripts;
    this.#originalBytes = undefined;
  }

  /**
   * Gets the set of plutus v2 scripts required by this transaction.
   *
   * @returns The set of plutus v2 scripts.
   */
  plutusV2Scripts(): Array<PlutusV2Script> | undefined {
    return this.#plutusV2Scripts;
  }

  /**
   * Sets the set of plutus v3 scripts required by this transaction.
   *
   * @param plutusV3Scripts The set of plutus v3 scripts.
   */
  setPlutusV3Scripts(plutusV3Scripts: Array<PlutusV3Script>) {
    this.#plutusV3Scripts = plutusV3Scripts;
    this.#originalBytes = undefined;
  }

  /**
   * Gets the set of plutus v3 scripts required by this transaction.
   *
   * @returns The set of plutus v3 scripts.
   */
  plutusV3Scripts(): Array<PlutusV3Script> | undefined {
    return this.#plutusV3Scripts;
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
    const plutusV3 = this.#plutusV3Scripts ? this.#plutusV3Scripts.map((script) => script.toCore()) : [];
    const native = this.#nativeScripts ? this.#nativeScripts.map((script) => script.toCore()) : [];

    return [...plutusV1, ...plutusV2, ...plutusV3, ...native];
  }

  /**
   * Gets all the scripts present in this witness as CDDL scripts.
   *
   * @returns The list of scripts.
   * @private
   */
  static #getCddlScripts(scripts: Array<Cardano.Script>): CddlScripts {
    const result: CddlScripts = { native: undefined, plutusV1: undefined, plutusV2: undefined, plutusV3: undefined };

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
          } else if (script.version === Cardano.PlutusLanguageVersion.V3) {
            if (!result.plutusV3) result.plutusV3 = new Array<PlutusV3Script>();

            result.plutusV3.push(PlutusV3Script.fromCore(script));
          }
          break;
        default:
          throw new SerializationError(SerializationFailure.InvalidScriptType, `Script '${script}' is not supported.`);
      }
    }

    return result;
  }

  /**
   * Gets the size of the serialized map.
   *
   * @private
   */
  #getMapSize(): number {
    let mapSize = 0;

    if (this.#vkeywitnesses !== undefined && this.#vkeywitnesses.length > 0) ++mapSize;
    if (this.#nativeScripts !== undefined && this.#nativeScripts.length > 0) ++mapSize;
    if (this.#bootstrapWitnesses !== undefined && this.#bootstrapWitnesses.length > 0) ++mapSize;
    if (this.#plutusV1Scripts !== undefined && this.#plutusV1Scripts.length > 0) ++mapSize;
    if (this.#plutusData !== undefined && this.#plutusData.length > 0) ++mapSize;
    if (this.#redeemers !== undefined && this.#redeemers.length > 0) ++mapSize;
    if (this.#plutusV2Scripts !== undefined && this.#plutusV2Scripts.length > 0) ++mapSize;
    if (this.#plutusV3Scripts !== undefined && this.#plutusV3Scripts.length > 0) ++mapSize;

    return mapSize;
  }
}
