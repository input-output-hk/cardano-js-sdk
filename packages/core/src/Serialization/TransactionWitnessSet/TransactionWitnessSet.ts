/* eslint-disable sonarjs/cognitive-complexity, complexity, max-statements, unicorn/prefer-switch */
import * as Cardano from '../../Cardano';
import { BootstrapWitness } from './BootstrapWitness';
import { CborReader, CborReaderState, CborWriter } from '../CBOR';
import { CborSet } from '../Common';
import { HexBlob } from '@cardano-sdk/util';
import { NativeScript, PlutusV1Script, PlutusV2Script, PlutusV3Script } from '../Scripts';
import { PlutusData } from '../PlutusData/PlutusData';
import { Redeemer } from './Redeemer';
import { SerializationError, SerializationFailure } from '../../errors';
import { VkeyWitness } from './VkeyWitness';
import { hexToBytes } from '../../util/misc';
import _groupBy from 'lodash/groupBy';
import uniqWith from 'lodash/uniqWith';

/** This type represents the segregated CDDL scripts. */
type CddlScripts = {
  native?: CborSet<ReturnType<NativeScript['toCore']>, NativeScript>;
  plutusV1?: CborSet<ReturnType<PlutusV1Script['toCore']>, PlutusV1Script>;
  plutusV2?: CborSet<ReturnType<PlutusV2Script['toCore']>, PlutusV2Script>;
  plutusV3?: CborSet<ReturnType<PlutusV3Script['toCore']>, PlutusV3Script>;
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
  #vkeywitnesses: CborSet<ReturnType<VkeyWitness['toCore']>, VkeyWitness> | undefined;
  #nativeScripts: CborSet<ReturnType<NativeScript['toCore']>, NativeScript> | undefined;
  #bootstrapWitnesses: CborSet<ReturnType<BootstrapWitness['toCore']>, BootstrapWitness> | undefined;
  #plutusV1Scripts: CborSet<ReturnType<PlutusV1Script['toCore']>, PlutusV1Script> | undefined;
  #plutusData: CborSet<ReturnType<PlutusData['toCore']>, PlutusData> | undefined;
  #redeemers: Array<Redeemer> | undefined;
  #plutusV2Scripts: CborSet<ReturnType<PlutusV2Script['toCore']>, PlutusV2Script> | undefined;
  #plutusV3Scripts: CborSet<ReturnType<PlutusV3Script['toCore']>, PlutusV3Script> | undefined;
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
    //   { ? 0: nonempty_set<vkeywitness>
    //   , ? 1: nonempty_set<native_script>
    //   , ? 2: nonempty_set<bootstrap_witness>
    //   , ? 3: nonempty_set<plutus_v1_script>
    //   , ? 4: nonempty_set<plutus_data>
    //   , ? 5: redeemers
    //   , ? 6: nonempty_set<plutus_v2_script>
    //   , ? 7: nonempty_set<plutus_v3_script>
    //   }
    //
    // redeemers =
    //   [ + [ tag: redeemer_tag, index: uint, data: plutus_data, ex_units: ex_units ] ]
    //   / { + [ tag: redeemer_tag, index: uint ] => [ data: plutus_data, ex_units: ex_units ] }
    writer.writeStartMap(this.#getMapSize());

    if (this.#vkeywitnesses && this.#vkeywitnesses.size() > 0) {
      this.#vkeywitnesses.setValues(uniqWith(this.#vkeywitnesses.values(), (lhs, rhs) => lhs.vkey() === rhs.vkey()));
      writer.writeInt(0n);
      writer.writeEncodedValue(Buffer.from(this.#vkeywitnesses.toCbor(), 'hex'));
    }

    if (this.#nativeScripts && this.#nativeScripts.size() > 0) {
      writer.writeInt(1n);
      writer.writeEncodedValue(Buffer.from(this.#nativeScripts.toCbor(), 'hex'));
    }

    if (this.#bootstrapWitnesses && this.#bootstrapWitnesses.size() > 0) {
      this.#bootstrapWitnesses.setValues(
        uniqWith(this.#bootstrapWitnesses.values(), (lhs, rhs) => lhs.vkey() === rhs.vkey())
      );
      writer.writeInt(2n);
      writer.writeEncodedValue(Buffer.from(this.#bootstrapWitnesses.toCbor(), 'hex'));
    }

    if (this.#plutusV1Scripts && this.#plutusV1Scripts.size() > 0) {
      writer.writeInt(3n);
      writer.writeEncodedValue(Buffer.from(this.#plutusV1Scripts.toCbor(), 'hex'));
    }

    if (this.#plutusData && this.#plutusData.size() > 0) {
      writer.writeInt(4n);
      writer.writeEncodedValue(Buffer.from(this.#plutusData.toCbor(), 'hex'));
    }

    if (this.#redeemers && this.#redeemers.length > 0) {
      writer.writeInt(5n);
      writer.writeStartArray(this.#redeemers.length);

      for (const data of this.#redeemers) {
        writer.writeEncodedValue(Buffer.from(data.toCbor(), 'hex'));
      }
    }

    if (this.#plutusV2Scripts && this.#plutusV2Scripts.size() > 0) {
      writer.writeInt(6n);
      writer.writeEncodedValue(Buffer.from(this.#plutusV2Scripts.toCbor(), 'hex'));
    }

    if (this.#plutusV3Scripts && this.#plutusV3Scripts.size() > 0) {
      writer.writeInt(7n);
      writer.writeEncodedValue(Buffer.from(this.#plutusV3Scripts.toCbor(), 'hex'));
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
          witness.setVkeys(CborSet.fromCbor(HexBlob.fromBytes(reader.readEncodedValue()), VkeyWitness.fromCbor));
          break;
        case 1n:
          witness.setNativeScripts(
            CborSet.fromCbor(HexBlob.fromBytes(reader.readEncodedValue()), NativeScript.fromCbor)
          );
          break;
        case 2n:
          witness.setBootstraps(
            CborSet.fromCbor(HexBlob.fromBytes(reader.readEncodedValue()), BootstrapWitness.fromCbor)
          );
          break;
        case 3n:
          witness.setPlutusV1Scripts(
            CborSet.fromCbor(HexBlob.fromBytes(reader.readEncodedValue()), PlutusV1Script.fromCbor)
          );
          break;
        case 4n:
          witness.setPlutusData(CborSet.fromCbor(HexBlob.fromBytes(reader.readEncodedValue()), PlutusData.fromCbor));
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
          witness.setPlutusV2Scripts(
            CborSet.fromCbor(HexBlob.fromBytes(reader.readEncodedValue()), PlutusV2Script.fromCbor)
          );
          break;
        case 7n:
          witness.setPlutusV3Scripts(
            CborSet.fromCbor(HexBlob.fromBytes(reader.readEncodedValue()), PlutusV3Script.fromCbor)
          );
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
      bootstrap: this.#bootstrapWitnesses ? this.#bootstrapWitnesses.toCore() : undefined,
      datums: this.#plutusData ? this.#plutusData.toCore() : undefined,
      redeemers: this.#redeemers ? this.#redeemers.map((data) => data.toCore()) : undefined,
      scripts: scripts.length > 0 ? scripts : undefined,
      signatures: this.#vkeywitnesses ? new Map(this.#vkeywitnesses.toCore()) : new Map()
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
      witness.setVkeys(CborSet.fromCore([...coreWitness.signatures], VkeyWitness.fromCore));
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
      witness.setPlutusData(CborSet.fromCore(coreWitness.datums, PlutusData.fromCore));
    }

    if (coreWitness.bootstrap) {
      witness.setBootstraps(CborSet.fromCore(coreWitness.bootstrap, BootstrapWitness.fromCore));
    }

    return witness;
  }

  /**
   * Sets the Verification Key Witnesses, used to prove the spending of inputs on the transaction is
   * authorized by the corresponding private key(s).
   *
   * @param vkeys The set of verification key witnesses.
   */
  setVkeys(vkeys: CborSet<ReturnType<VkeyWitness['toCore']>, VkeyWitness>) {
    this.#vkeywitnesses = vkeys;
    this.#originalBytes = undefined;
  }

  /**
   * Gets the Verification Key Witnesses, used to prove the spending of inputs on the transaction is
   * authorized by the corresponding private key(s).
   *
   * @returns The set of verification key witnesses.
   */
  vkeys() {
    return this.#vkeywitnesses;
  }

  /**
   * Sets the set of native scripts required by this transaction.
   *
   * @param nativeScripts The set of native scripts.
   */
  setNativeScripts(nativeScripts: CborSet<ReturnType<NativeScript['toCore']>, NativeScript>) {
    this.#nativeScripts = nativeScripts;
    this.#originalBytes = undefined;
  }

  /**
   * Gets the set of native scripts required by this transaction.
   *
   * @returns The set of native scripts.
   */
  nativeScripts() {
    return this.#nativeScripts;
  }

  /**
   * Sets the witnesses for authorizing spending from UTxOs associated with Byron-era addresses.
   *
   * @param bootstraps The Bootstrap witnesses for this transaction.
   */
  setBootstraps(bootstraps: CborSet<ReturnType<BootstrapWitness['toCore']>, BootstrapWitness>) {
    this.#bootstrapWitnesses = bootstraps;
    this.#originalBytes = undefined;
  }

  /**
   * Gets the witnesses for authorizing spending from UTxOs associated with Byron-era addresses.
   *
   * @returns The Bootstrap witnesses for this transaction.
   */
  bootstraps() {
    return this.#bootstrapWitnesses;
  }

  /**
   * Sets the set of plutus v1 scripts required by this transaction.
   *
   * @param plutusV1Scripts The set of plutus v1 scripts.
   */
  setPlutusV1Scripts(plutusV1Scripts: CborSet<ReturnType<PlutusV1Script['toCore']>, PlutusV1Script>) {
    this.#plutusV1Scripts = plutusV1Scripts;
    this.#originalBytes = undefined;
  }

  /**
   * Gets the set of plutus v1 scripts required by this transaction.
   *
   * @returns The set of plutus v1 scripts.
   */
  plutusV1Scripts() {
    return this.#plutusV1Scripts;
  }

  /**
   * Sets the Plutus Data required by the Plutus scripts of this transaction.
   *
   * @param plutusData The Plutus Data.
   */
  setPlutusData(plutusData: CborSet<ReturnType<PlutusData['toCore']>, PlutusData>) {
    this.#plutusData = plutusData;
    this.#originalBytes = undefined;
  }

  /**
   * Gets the Plutus Data required by the Plutus scripts of this transaction.
   *
   * @returns The Plutus Data.
   */
  plutusData() {
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
  setPlutusV2Scripts(plutusV2Scripts: CborSet<ReturnType<PlutusV2Script['toCore']>, PlutusV2Script>) {
    this.#plutusV2Scripts = plutusV2Scripts;
    this.#originalBytes = undefined;
  }

  /**
   * Gets the set of plutus v2 scripts required by this transaction.
   *
   * @returns The set of plutus v2 scripts.
   */
  plutusV2Scripts() {
    return this.#plutusV2Scripts;
  }

  /**
   * Sets the set of plutus v3 scripts required by this transaction.
   *
   * @param plutusV3Scripts The set of plutus v3 scripts.
   */
  setPlutusV3Scripts(plutusV3Scripts: CborSet<ReturnType<PlutusV3Script['toCore']>, PlutusV3Script>) {
    this.#plutusV3Scripts = plutusV3Scripts;
    this.#originalBytes = undefined;
  }

  /**
   * Gets the set of plutus v3 scripts required by this transaction.
   *
   * @returns The set of plutus v3 scripts.
   */
  plutusV3Scripts() {
    return this.#plutusV3Scripts;
  }

  /**
   * Gets all the scripts present in this witness as Core scripts.
   *
   * @returns The list of scripts.
   * @private
   */
  #getCoreScripts(): Array<Cardano.Script> {
    const plutusV1 = this.#plutusV1Scripts ? this.#plutusV1Scripts.toCore() : [];
    const plutusV2 = this.#plutusV2Scripts ? this.#plutusV2Scripts.toCore() : [];
    const plutusV3 = this.#plutusV3Scripts ? this.#plutusV3Scripts.toCore() : [];
    const native = this.#nativeScripts ? this.#nativeScripts.toCore() : [];

    return [...plutusV1, ...plutusV2, ...plutusV3, ...native];
  }

  /**
   * Gets all the scripts present in this witness as CDDL scripts.
   *
   * @returns The list of scripts.
   * @private
   */
  static #getCddlScripts(scripts: Array<Cardano.Script>): CddlScripts {
    const [coreNative, coreV1, coreV2, coreV3] = scripts.reduce<
      [
        Cardano.NativeScript[] | null,
        Cardano.PlutusScript[] | null,
        Cardano.PlutusScript[] | null,
        Cardano.PlutusScript[] | null
      ]
    >(
      ([native, v1, v2, v3], script) => {
        if (script.__type === Cardano.ScriptType.Native) {
          native ? native.push(script) : (native = [script]);
        } else {
          switch (script.version) {
            case Cardano.PlutusLanguageVersion.V1:
              v1 ? v1.push(script) : (v1 = [script]);
              break;
            case Cardano.PlutusLanguageVersion.V2:
              v2 ? v2.push(script) : (v2 = [script]);
          break;
            case Cardano.PlutusLanguageVersion.V3:
              v3 ? v3.push(script) : (v3 = [script]);
          break;
        default:
              throw new SerializationError(
                SerializationFailure.InvalidScriptType,
                `Script '${script}' is not supported.`
              );
      }
    }
        return [native, v1, v2, v3];
      },
      [null, null, null, null]
    );

    return {
      ...(coreNative && { native: CborSet.fromCore(coreNative, NativeScript.fromCore) }),
      ...(coreV1 && { plutusV1: CborSet.fromCore(coreV1, PlutusV1Script.fromCore) }),
      ...(coreV2 && { plutusV2: CborSet.fromCore(coreV2, PlutusV2Script.fromCore) }),
      ...(coreV3 && { plutusV3: CborSet.fromCore(coreV3, PlutusV3Script.fromCore) })
    };
  }

  /**
   * Gets the size of the serialized map.
   *
   * @private
   */
  #getMapSize(): number {
    let mapSize = 0;

    if (this.#vkeywitnesses !== undefined && this.#vkeywitnesses.size() > 0) ++mapSize;
    if (this.#nativeScripts !== undefined && this.#nativeScripts.size() > 0) ++mapSize;
    if (this.#bootstrapWitnesses !== undefined && this.#bootstrapWitnesses.size() > 0) ++mapSize;
    if (this.#plutusV1Scripts !== undefined && this.#plutusV1Scripts.size() > 0) ++mapSize;
    if (this.#plutusData !== undefined && this.#plutusData.size() > 0) ++mapSize;
    if (this.#redeemers !== undefined && this.#redeemers.length > 0) ++mapSize;
    if (this.#plutusV2Scripts !== undefined && this.#plutusV2Scripts.size() > 0) ++mapSize;
    if (this.#plutusV3Scripts !== undefined && this.#plutusV3Scripts.size() > 0) ++mapSize;

    return mapSize;
  }
}
