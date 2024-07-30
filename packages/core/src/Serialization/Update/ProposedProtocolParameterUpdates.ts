import * as Crypto from '@cardano-sdk/crypto';
import {
  ProposedProtocolParameterUpdates as CardanoProposedProtocolParameterUpdates,
  GenesisDelegateKeyHash,
  ProtocolParametersUpdate
} from '../../Cardano/types/ProtocolParameters';
import { CborReader, CborReaderState, CborWriter } from '../CBOR';
import { HexBlob } from '@cardano-sdk/util';
import { ProtocolParamUpdate } from './ProtocolParamUpdate';

/**
 * In the Cardano network, stakeholders can propose changes to the protocol parameters. These proposals are then
 * collected into a set which represents the ProposedProtocolParameterUpdates.
 *
 * This proposed protocol parameter updates are represented as a map of genesis delegate key hash to parameters updates. So in principles,
 * each genesis delegate can propose a different update.
 */
export class ProposedProtocolParameterUpdates {
  #proposedUpdates = new Map<GenesisDelegateKeyHash, ProtocolParamUpdate>();
  #originalBytes: HexBlob | undefined = undefined;

  /**
   * Initializes a new instance of the ProposedProtocolParameterUpdates class.
   *
   * @param proposedUpdates The proposed updates.
   */
  constructor(proposedUpdates: Map<GenesisDelegateKeyHash, ProtocolParamUpdate>) {
    this.#proposedUpdates = proposedUpdates;
  }

  /**
   * Serializes a ProposedProtocolParameterUpdates into CBOR format.
   *
   * @returns The ProposedProtocolParameterUpdates in CBOR format.
   */
  toCbor(): HexBlob {
    const writer = new CborWriter();

    if (this.#originalBytes) return this.#originalBytes;

    const sortedCanonically = new Map([...this.#proposedUpdates].sort((a, b) => (a > b ? 1 : -1)));

    // CDDL
    // proposed_protocol_parameter_updates =
    //   { * genesisDelegateKeyHash => protocol_param_update }
    writer.writeStartMap(sortedCanonically.size);

    for (const [key, value] of sortedCanonically) {
      writer.writeByteString(Buffer.from(key, 'hex'));
      writer.writeEncodedValue(Buffer.from(value.toCbor(), 'hex'));
    }

    return writer.encodeAsHex();
  }

  /**
   * Deserializes the ProposedProtocolParameterUpdates  from a CBOR byte array.
   *
   * @param cbor The CBOR encoded ProposedProtocolParameterUpdates  object.
   * @returns The new ProposedProtocolParameterUpdates  instance.
   */
  static fromCbor(cbor: HexBlob): ProposedProtocolParameterUpdates {
    const reader = new CborReader(cbor);
    const proposedUpdates = new Map<GenesisDelegateKeyHash, ProtocolParamUpdate>();

    reader.readStartMap();

    while (reader.peekState() !== CborReaderState.EndMap) {
      const genesisHash = Crypto.Hash28ByteBase16(HexBlob.fromBytes(reader.readByteString()));
      const params = ProtocolParamUpdate.fromCbor(HexBlob.fromBytes(reader.readEncodedValue()));

      proposedUpdates.set(genesisHash, params);
    }

    reader.readEndMap();

    const updates = new ProposedProtocolParameterUpdates(proposedUpdates);
    updates.#originalBytes = cbor;

    return updates;
  }

  /**
   * Creates a Core ProposedProtocolParameterUpdates object from the current ProposedProtocolParameterUpdates object.
   *
   * @returns The Core ProposedProtocolParameterUpdates object.
   */
  toCore(): CardanoProposedProtocolParameterUpdates {
    return new Map<GenesisDelegateKeyHash, ProtocolParametersUpdate>(
      [...this.#proposedUpdates].map(([key, value]) => [key, value.toCore()])
    );
  }

  /**
   * Creates a ProposedProtocolParameterUpdates object from the given Core ProposedProtocolParameterUpdates object.
   *
   * @param updates core ProposedProtocolParameterUpdates object.
   */
  static fromCore(updates: CardanoProposedProtocolParameterUpdates) {
    return new ProposedProtocolParameterUpdates(
      new Map<GenesisDelegateKeyHash, ProtocolParamUpdate>(
        [...updates].map(([key, value]) => [key, ProtocolParamUpdate.fromCore(value)])
      )
    );
  }

  /**
   * Gets the number of elements in the proposed updates map.
   *
   * @returns The number of entries in the map.
   */
  size(): number {
    return this.#proposedUpdates.size;
  }

  /**
   * Inserts a new ProtocolParametersUpdate in the map.
   *
   * @param key The key hash of the genesis delegate proposing the update.
   * @param value The parameters that are being proposed for the update.
   */
  insert(key: GenesisDelegateKeyHash, value: ProtocolParamUpdate): void {
    this.#proposedUpdates.set(key, value);
  }

  /**
   * Gets a ProtocolParametersUpdate given a genesis delegate key hash.
   *
   * @param key The key hash of the genesis delegate proposing the update.
   */
  get(key: GenesisDelegateKeyHash): ProtocolParamUpdate | undefined {
    return this.#proposedUpdates.get(key);
  }

  /**
   * Gets the genesis delegate key hashes present in the map.
   *
   * @returns The genesis delegate key hashes.
   */
  keys(): Array<GenesisDelegateKeyHash> {
    return [...this.#proposedUpdates.keys()];
  }
}
