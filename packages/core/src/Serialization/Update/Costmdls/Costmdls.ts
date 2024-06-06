import * as Cardano from '../../../Cardano/index.js';
import { CborReader, CborReaderState, CborWriter } from '../../CBOR/index.js';
import { CostModel } from './CostModel.js';
import { InvalidStateError } from '@cardano-sdk/util';
import type { HexBlob } from '@cardano-sdk/util';

/** Map of PlutusLanguageVersion to CostModel. */
export class Costmdls {
  #models: Map<Cardano.PlutusLanguageVersion, CostModel>;
  #originalBytes: HexBlob | undefined = undefined;

  /**
   * Initializes a new instance of the Costmdls class.
   *
   * @param models The cost models.
   */
  constructor(models: Map<Cardano.PlutusLanguageVersion, CostModel> = new Map()) {
    this.#models = models;
  }

  /**
   * Serializes a Costmdls into CBOR format.
   *
   * @returns The Costmdls in CBOR format.
   */
  toCbor(): HexBlob {
    const writer = new CborWriter();

    if (this.#originalBytes) return this.#originalBytes;

    const sortedCanonically = new Map([...this.#models].sort((a, b) => (a > b ? 1 : -1)));

    // CDDL
    // costmdls =
    //   { ? 0 : [ 166* int ] ; Plutus v1, only 166 integers are used, but more are accepted (and ignored)
    //     ? 1 : [ 175* int ] ; Plutus v2, only 175 integers are used, but more are accepted (and ignored)
    //   , ? 2 : [ 179* int ] ; Plutus v3, only 179 integers are used, but more are accepted (and ignored)
    //   }
    writer.writeStartMap(sortedCanonically.size);

    for (const [key, value] of sortedCanonically) {
      writer.writeInt(key);

      writer.writeStartArray(value.costs().length);
      for (const cost of value.costs()) {
        writer.writeInt(cost);
      }
    }

    return writer.encodeAsHex();
  }

  /**
   * Deserializes the Costmdls from a CBOR byte array.
   *
   * @param cbor The CBOR encoded Costmdls object.
   * @returns The new Costmdls instance.
   */
  static fromCbor(cbor: HexBlob): Costmdls {
    const reader = new CborReader(cbor);

    reader.readStartMap();

    const models = new Map<Cardano.PlutusLanguageVersion, CostModel>();
    while (reader.peekState() !== CborReaderState.EndMap) {
      // Read key
      const language = Number(reader.readInt());
      const costs = new Array<number>();

      // Read model
      reader.readStartArray();

      while (reader.peekState() !== CborReaderState.EndArray) {
        costs.push(Number(reader.readInt()));
      }

      reader.readEndArray();

      models.set(language, new CostModel(language, costs));
    }

    reader.readEndMap();

    const costmdl = new Costmdls(models);
    costmdl.#originalBytes = cbor;

    return costmdl;
  }

  /**
   * Creates a Core CostModels object from the current Costmdls object.
   *
   * @returns The Core CostModels object.
   */
  toCore(): Cardano.CostModels {
    const models = new Map<Cardano.PlutusLanguageVersion, Cardano.CostModel>();

    for (const [key, value] of this.#models) {
      models.set(key, value.costs());
    }

    return models;
  }

  /**
   * Creates a Costmdls object from the given Core CostModels object.
   *
   * @param costModels core CostModels object.
   */
  static fromCore(costModels: Cardano.CostModels) {
    const models = new Map<Cardano.PlutusLanguageVersion, CostModel>();

    for (const [key, value] of costModels) {
      models.set(key, new CostModel(key, value));
    }

    return new Costmdls(models);
  }

  /**
   * Gets the number of elements in the Costmdls map.
   *
   * @returns The number of elements in the map.
   */
  size(): number {
    return this.#models.size;
  }

  /**
   * Inserts a new CostModel in the Costmdls map.
   *
   * @param value The cost model to be inserted.
   */
  insert(value: CostModel) {
    this.#models.set(value.language(), value);
    this.#originalBytes = undefined;
  }

  /**
   * Gets a specified element from a Costmdls object.
   *
   * @param key The key of the element to return from the Costmdls map.
   * @returns The element associated with the specified key, or undefined if the key
   * can't be found in the Map object.
   */
  get(key: Cardano.PlutusLanguageVersion): CostModel | undefined {
    return this.#models.get(key);
  }

  /**
   * Gets the list of keys present in the Costmdls map.
   *
   * @returns The list of keys present in the Costmdls map.
   */
  keys(): Array<Cardano.PlutusLanguageVersion> {
    return [...this.#models.keys()];
  }

  /**
   * Encodes the costs models following the CDDL specification, this is needed
   * for computing the script data hash of a transaction:
   *
   * https://github.com/input-output-hk/cardano-ledger/blob/master/eras/babbage/test-suite/cddl-files/babbage.cddl#L112
   */
  languageViewsEncoding(): HexBlob {
    const encodedLanguageViews = new CborWriter();
    const sortedCanonically = new Map(
      [...this.#models].sort((a, b) => {
        // The key of Plutus V1 cost models was encoded as a byte array of one byte, this should
        // alter the position of this entry in the map when we do the canonical sorting, so we are going to
        // account for that here.
        const lhs = a[0] === Cardano.PlutusLanguageVersion.V1 ? 0x41 : a[0];
        const rhs = b[0] === Cardano.PlutusLanguageVersion.V1 ? 0x41 : b[0];

        return lhs > rhs ? 1 : -1;
      })
    );

    encodedLanguageViews.writeStartMap(sortedCanonically.size);
    for (const [key, value] of sortedCanonically) {
      switch (key) {
        case Cardano.PlutusLanguageVersion.V1: {
          // For PlutusV1 (language id 0), the language view is the following:
          //   * the value of costmdls map at key 0 is encoded as an indefinite length
          //     list and the result is encoded as a bytestring. (our apologies)
          //   * the language ID tag is also encoded twice. first as a uint then as
          //     a bytestring. (our apologies)
          const writer = new CborWriter();

          writer.writeStartArray();

          for (const cost of value.costs()) {
            writer.writeInt(cost);
          }

          writer.writeEndArray();

          const innerCbor = writer.encode();

          encodedLanguageViews.writeByteString(new Uint8Array([0])); // Key of Plutus V1
          encodedLanguageViews.writeByteString(innerCbor);
          break;
        }
        case Cardano.PlutusLanguageVersion.V2:
        case Cardano.PlutusLanguageVersion.V3:
          // For PlutusV2&V3 (language id 1&2), the language view is the following:
          //    * the value of costmdls map is encoded as a definite length list.
          encodedLanguageViews.writeInt(key);
          encodedLanguageViews.writeStartArray(value.costs().length);
          for (const cost of value.costs()) {
            encodedLanguageViews.writeInt(cost);
          }
          break;
        default:
          throw new InvalidStateError('Invalid plutus language version.');
      }
    }

    return encodedLanguageViews.encodeAsHex();
  }
}
