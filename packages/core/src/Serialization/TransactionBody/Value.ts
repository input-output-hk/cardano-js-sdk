import * as Crypto from '@cardano-sdk/crypto';
import { AssetName, Value as CardanoValue, Lovelace, TokenMap } from '../../Cardano/types';
import { CborReader, CborReaderState, CborWriter } from '../CBOR';
import { HexBlob, InvalidArgumentError } from '@cardano-sdk/util';
import { multiAssetsToTokenMap, sortCanonically, tokenMapToMultiAsset } from './Utils';

const VALUE_ARRAY_SIZE = 2;

/**
 * A Value object encapsulates the quantity of assets of different types,
 * including ADA (Cardano's native cryptocurrency) expressed in lovelace,
 * where 1 ADA = 1,000,000 lovelace, and other native tokens. Each key in the
 * tokens object is a unique identifier for an asset, and the corresponding
 * value is the quantity of that asset.
 */
export class Value {
  #coin = 0n;
  #multiasset: TokenMap | undefined = undefined;
  #originalBytes: HexBlob | undefined = undefined;

  /**
   * Initializes a new instance of the Value class.
   *
   * @param coin  Amount of lovelace represented by this Value.
   * @param multiasset The collection of native assets represented by this Value.
   */
  constructor(coin: Lovelace, multiasset?: TokenMap) {
    this.#coin = coin;

    // We need to segregate the token map as a multiasset to be able to sort it correctly in canonical form.
    this.#multiasset = multiasset
      ? multiAssetsToTokenMap(new Map([...tokenMapToMultiAsset(multiasset!).entries()].sort(sortCanonically)))
      : undefined;
  }

  /**
   * Serializes a Value into CBOR format.
   *
   * @returns The Value in CBOR format.
   */
  toCbor(): HexBlob {
    if (this.#originalBytes) return this.#originalBytes;

    // CDDL
    // value = coin / [coin, multiasset<uint>]
    const writer = new CborWriter();

    if (!this.#multiasset || this.#multiasset.size <= 0) {
      writer.writeInt(this.#coin);
    } else {
      writer.writeStartArray(VALUE_ARRAY_SIZE);
      writer.writeInt(this.#coin);

      const multiassets = tokenMapToMultiAsset(this.#multiasset);

      const sortedMultiAssets = new Map([...multiassets!.entries()].sort(sortCanonically));
      writer.writeStartMap(sortedMultiAssets.size);

      for (const [scriptHash, assets] of sortedMultiAssets.entries()) {
        writer.writeByteString(Buffer.from(scriptHash, 'hex'));

        const sortedAssets = new Map([...assets!.entries()].sort(sortCanonically));
        writer.writeStartMap(sortedAssets.size);
        for (const [assetName, quantity] of sortedAssets.entries()) {
          writer.writeByteString(Buffer.from(assetName, 'hex'));
          writer.writeInt(quantity);
        }
      }
    }

    return writer.encodeAsHex();
  }

  /**
   * Deserializes the Value from a CBOR byte array.
   *
   * @param cbor The CBOR encoded Value object.
   * @returns The new Value instance.
   */
  static fromCbor(cbor: HexBlob): Value {
    const reader = new CborReader(cbor);

    if (reader.peekState() === CborReaderState.UnsignedInteger) {
      const coins = reader.readInt();
      return new Value(coins);
    }

    const length = reader.readStartArray();

    if (length !== VALUE_ARRAY_SIZE)
      throw new InvalidArgumentError(
        'cbor',
        `Expected an array of ${VALUE_ARRAY_SIZE} elements, but got an array of ${length} elements`
      );

    const coins = reader.readInt();
    const multiassets = new Map<Crypto.Hash28ByteBase16, Map<AssetName, bigint>>();

    reader.readStartMap();
    while (reader.peekState() !== CborReaderState.EndMap) {
      const scriptHash = HexBlob.fromBytes(reader.readByteString()) as unknown as Crypto.Hash28ByteBase16;

      if (!multiassets.has(scriptHash)) multiassets.set(scriptHash, new Map<AssetName, bigint>());

      reader.readStartMap();
      while (reader.peekState() !== CborReaderState.EndMap) {
        const assetName = Buffer.from(reader.readByteString()).toString('hex') as unknown as AssetName;
        const quantity = reader.readInt();

        multiassets.get(scriptHash)!.set(assetName, quantity);
      }
      reader.readEndMap();
    }
    reader.readEndMap();

    const sortedAssets = new Map([...multiAssetsToTokenMap(multiassets)].sort(sortCanonically));
    const value = new Value(coins, sortedAssets);
    value.#originalBytes = cbor;

    return value;
  }

  /**
   * Creates a Core Value object from the current Value object.
   *
   * @returns The Core Value object.
   */
  toCore(): CardanoValue {
    return { assets: this.#multiasset, coins: this.#coin };
  }

  /**
   * Creates a Value object from the given Core Value object.
   *
   * @param coreValue The core Value object.
   */
  static fromCore(coreValue: CardanoValue): Value {
    return new Value(coreValue.coins, coreValue.assets);
  }

  /**
   * Gets the coin amount included in this Value.
   *
   * @returns The coin amount of this value in lovelace,
   * where 1 ADA = 1,000,000 lovelace.
   */
  coin(): Lovelace {
    return this.#coin;
  }

  /**
   * Sets the coin amount to be included in this Value.
   *
   * @param coin The coin amount of this value in lovelace,
   * where 1 ADA = 1,000,000 lovelace.
   */
  setCoin(coin: Lovelace): void {
    this.#coin = coin;
    this.#originalBytes = undefined;
  }

  /**
   * Gets the assets included in this Value.
   *
   * Each key in the tokens object is a unique identifier for an asset,
   * and the corresponding value is the quantity of that asset.
   *
   * The asset identifiers for native tokens are constructed
   * as the hash of the policy script under which they were minted,
   * concatenated with a name for the token.
   *
   * @returns A mapping of asset identifiers to their quantities.
   */
  multiasset(): TokenMap | undefined {
    return this.#multiasset;
  }

  /**
   * Sets the assets included in this Value.
   *
   * @param multiasset A mapping of asset identifiers to their quantities.
   */
  setMultiasset(multiasset: TokenMap): void {
    // We need to segregate the token map as a multiasset to be able to sort it correctly in canonical form.
    this.#multiasset = multiAssetsToTokenMap(
      new Map([...tokenMapToMultiAsset(multiasset!).entries()].sort(sortCanonically))
    );

    this.#originalBytes = undefined;
  }
}
