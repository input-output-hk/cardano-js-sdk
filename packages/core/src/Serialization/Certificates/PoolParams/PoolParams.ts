/* eslint-disable max-params */
import * as Cardano from '../../../Cardano';
import * as Crypto from '@cardano-sdk/crypto';
import { CborReader, CborReaderState, CborWriter } from '../../CBOR';
import { HexBlob, InvalidArgumentError } from '@cardano-sdk/util';
import { PoolMetadata } from './PoolMetadata';
import { Relay } from './Relay';
import { UnitInterval } from '../../Common/UnitInterval';

/**
 * Stake pool update certificate parameters.
 *
 * When a stake pool operator wants to change the parameters of their pool, they
 * must submit a pool update certificate with these parameters.
 */
export class PoolParams {
  #operator: Crypto.Ed25519KeyHashHex;
  #vrfKeyHash: Cardano.VrfVkHex;
  #pledge: Cardano.Lovelace;
  #cost: Cardano.Lovelace;
  #margin: UnitInterval;
  #rewardAccount: Cardano.RewardAddress;
  #poolOwners: Array<Crypto.Ed25519KeyHashHex>;
  #relays: Array<Relay>;
  #poolMetadata?: PoolMetadata;
  #originalBytes: HexBlob | undefined = undefined;

  static readonly subgroupCount = 9;

  /**
   * Initializes a new instance of the PoolParams class.
   *
   * @param operator Key that uniquely identifies the operator of the pool.
   * @param vrfKeyHash This is the hash of the pool's Verifiable Random Function key. It's used for leader selection in the Ouroboros Praos consensus protocol.
   * @param pledge The amount of ADA that the stake pool operator themselves will delegate to the pool.
   * @param cost The minimum cost per epoch that the pool will charge. This is the cost that covers the operational expenses of the pool.
   * @param margin This is the percentage of the rewards that will be taken by the pool before distributing the rest to its delegators.
   * @param rewardAccount The address where the pool's rewards will be sent.
   * @param poolOwners The public keys of the owners of the stake pool.
   * @param relays The network addresses (IP and/or DNS) of the relay nodes running in the pool.
   * @param poolMetadata  If the pool has associated metadata, this will include the hash of that metadata and the URL where the metadata file can be found.
   */
  constructor(
    operator: Crypto.Ed25519KeyHashHex,
    vrfKeyHash: Cardano.VrfVkHex,
    pledge: Cardano.Lovelace,
    cost: Cardano.Lovelace,
    margin: UnitInterval,
    rewardAccount: Cardano.RewardAddress,
    poolOwners: Array<Crypto.Ed25519KeyHashHex>,
    relays: Array<Relay>,
    poolMetadata?: PoolMetadata
  ) {
    this.#operator = operator;
    this.#vrfKeyHash = vrfKeyHash;
    this.#pledge = pledge;
    this.#cost = cost;
    this.#margin = margin;
    this.#rewardAccount = rewardAccount;
    this.#poolOwners = poolOwners;
    this.#relays = relays;
    this.#poolMetadata = poolMetadata;
  }

  /**
   * Serializes a PoolMetadata into CBOR format.
   *
   * @returns The PoolMetadata in CBOR format.
   */
  toCbor(): HexBlob {
    const writer = new CborWriter();

    if (this.#originalBytes) return this.#originalBytes;

    // CDDL
    // pool_params = ( operator:       pool_keyhash
    //               , vrf_keyhash:    vrf_keyhash
    //               , pledge:         coin
    //               , cost:           coin
    //               , margin:         unit_interval
    //               , reward_account: reward_account
    //               , pool_owners:    set<addr_keyhash>
    //               , relays:         [* relay]
    //               , pool_metadata:  pool_metadata / null
    //               )
    writer.writeStartArray(PoolParams.subgroupCount);
    return this.toFlattenedCbor(writer);
  }

  /**
   * Serializes a PoolMetadata flattened (without grouping), into CBOR format, assuming the caller already created
   * the grouping.
   * An example is the PoolRegistration certificate which flattens the pool parameters in the pool_registration, rather
   * than insert as a subgroup
   *
   * @param the parent writer that already created the subgroup
   * @returns The PoolMetadata in CBOR format.
   */
  toFlattenedCbor(writer: CborWriter): HexBlob {
    writer.writeByteString(Buffer.from(this.#operator, 'hex'));
    writer.writeByteString(Buffer.from(this.#vrfKeyHash, 'hex'));
    writer.writeInt(this.#pledge);
    writer.writeInt(this.#cost);
    writer.writeEncodedValue(Buffer.from(this.#margin.toCbor(), 'hex'));
    writer.writeByteString(Buffer.from(this.#rewardAccount.toAddress().toBytes(), 'hex'));

    writer.writeStartArray(this.#poolOwners.length);
    for (const owner of this.#poolOwners) writer.writeByteString(Buffer.from(owner, 'hex'));

    writer.writeStartArray(this.#relays.length);
    for (const relay of this.#relays) writer.writeEncodedValue(Buffer.from(relay.toCbor(), 'hex'));

    if (this.#poolMetadata) {
      writer.writeEncodedValue(Buffer.from(this.#poolMetadata.toCbor(), 'hex'));
    } else {
      writer.writeNull();
    }

    return writer.encodeAsHex();
  }

  /**
   * Deserializes the PoolParams from a CBOR byte array.
   *
   * @param cbor The CBOR encoded PoolParams object.
   * @returns The new PoolParams instance.
   */
  static fromCbor(cbor: HexBlob): PoolParams {
    const reader = new CborReader(cbor);

    const length = reader.readStartArray();

    if (length !== PoolParams.subgroupCount)
      throw new InvalidArgumentError(
        'cbor',
        `Expected an array of ${PoolParams.subgroupCount} elements, but got an array of ${length} elements`
      );

    const params = PoolParams.fromFlattenedCbor(reader);

    params.#originalBytes = cbor;

    return params;
  }

  /**
   * Read the params one by one. Reading the grouping array was done previously.
   * An example is the PoolRegistration certificate which flattens the pool parameters into an array that includes the
   * certificate type.
   *
   * @param reader The reader that started reading the subgroup
   * @returns The new PoolParams instance.
   */
  static fromFlattenedCbor(reader: CborReader): PoolParams {
    const operator = Crypto.Ed25519KeyHashHex(HexBlob.fromBytes(reader.readByteString()));
    const vrfKeyHash = Cardano.VrfVkHex(HexBlob.fromBytes(reader.readByteString()));
    const pledge = reader.readInt();
    const cost = reader.readInt();
    const margin = UnitInterval.fromCbor(HexBlob.fromBytes(reader.readEncodedValue()));
    const rewardAccount = Cardano.Address.fromBytes(HexBlob.fromBytes(reader.readByteString())).asReward()!;
    const poolOwner = new Array<Crypto.Ed25519KeyHashHex>();
    const relays = new Array<Relay>();
    let poolMetadata;

    // Pool owners.
    reader.readStartArray();

    while (reader.peekState() !== CborReaderState.EndArray)
      poolOwner.push(Crypto.Ed25519KeyHashHex(HexBlob.fromBytes(reader.readByteString())));

    reader.readEndArray();

    // Relays
    reader.readStartArray();

    while (reader.peekState() !== CborReaderState.EndArray)
      relays.push(Relay.fromCbor(HexBlob.fromBytes(reader.readEncodedValue())));

    reader.readEndArray();

    if (reader.peekState() !== CborReaderState.Null) {
      poolMetadata = PoolMetadata.fromCbor(HexBlob.fromBytes(reader.readEncodedValue()));
    } else {
      reader.readNull();
    }

    return new PoolParams(operator, vrfKeyHash, pledge, cost, margin, rewardAccount, poolOwner, relays, poolMetadata);
  }

  /**
   * Creates a Core PoolParameters object from the current PoolParams object.
   *
   * @returns The Core PoolParameters object.
   */
  toCore(): Cardano.PoolParameters {
    const rewardAccountAddress = this.#rewardAccount.toAddress();

    return {
      cost: this.#cost,
      id: Cardano.PoolId.fromKeyHash(this.#operator),
      margin: this.#margin.toCore(),
      metadataJson: this.#poolMetadata?.toCore(),
      owners: this.#poolOwners.map((keyHash) =>
        Cardano.createRewardAccount(keyHash, rewardAccountAddress.getNetworkId())
      ),
      pledge: this.#pledge,
      relays: this.#relays.map((relay) => relay.toCore()),
      rewardAccount: this.#rewardAccount.toAddress().toBech32() as Cardano.RewardAccount,
      vrf: this.#vrfKeyHash
    };
  }

  /**
   * Creates a PoolParams object from the given Core PoolParameters object.
   *
   * @param params core PoolParameters object.
   */
  static fromCore(params: Cardano.PoolParameters) {
    return new PoolParams(
      Cardano.PoolId.toKeyHash(params.id),
      params.vrf,
      params.pledge,
      params.cost,
      UnitInterval.fromCore(params.margin),
      Cardano.Address.fromBech32(params.rewardAccount).asReward()!,
      params.owners.map((owner) =>
        Crypto.Ed25519KeyHashHex(Cardano.Address.fromBech32(owner).asReward()!.getPaymentCredential()!.hash)
      ),
      params.relays.map((relay) => Relay.fromCore(relay)),
      params.metadataJson ? PoolMetadata.fromCore(params.metadataJson) : undefined
    );
  }

  /**
   * Gets the key hash of the stake pool operator.
   *
   * @returns Key that uniquely identifies the operator of the pool.
   */
  operator(): Crypto.Ed25519KeyHashHex {
    return this.#operator;
  }

  /**
   * Sets the key hash of the stake pool operator.
   *
   * @param operator Key that uniquely identifies the operator of the pool.
   */
  setOperator(operator: Crypto.Ed25519KeyHashHex): void {
    this.#operator = operator;
    this.#originalBytes = undefined;
  }

  /**
   * Gets the hash of the pool's Verifiable Random Function key. It's used for leader
   * selection in the Ouroboros Praos consensus protocol.
   *
   * @returns The pool Verifiable Random Function key hash.
   */
  vrfKeyHash(): Cardano.VrfVkHex {
    return this.#vrfKeyHash;
  }

  /**
   * Sets the hash of the pool's Verifiable Random Function key. It's used for leader
   * selection in the Ouroboros Praos consensus protocol.
   *
   * @param vrfKeyHash The pool Verifiable Random Function key hash.
   */
  setVrfKeyHash(vrfKeyHash: Cardano.VrfVkHex): void {
    this.#vrfKeyHash = vrfKeyHash;
    this.#originalBytes = undefined;
  }

  /**
   * Gets the amount of ADA that the stake pool operator themselves will delegate to the pool.
   *
   * @returns The amount of ADA pledged by the pool operator.
   */
  pledge(): Cardano.Lovelace {
    return this.#pledge;
  }

  /**
   * Sets the amount of ADA that the stake pool operator themselves will delegate to the pool.
   *
   * @param pledge The amount of ADA pledged by the pool operator.
   */
  setPledge(pledge: Cardano.Lovelace): void {
    this.#pledge = pledge;
    this.#originalBytes = undefined;
  }

  /**
   * Gets the minimum cost per epoch that the pool will charge. This is the cost
   * that covers the operational expenses of the pool.
   *
   * @returns The pool fixed cost.
   */
  cost(): Cardano.Lovelace {
    return this.#cost;
  }

  /**
   * Sets the minimum cost per epoch that the pool will charge. This is the cost
   * that covers the operational expenses of the pool.
   *
   * @param cost The pool fixed cost.
   */
  setCost(cost: Cardano.Lovelace): void {
    this.#cost = cost;
    this.#originalBytes = undefined;
  }

  /**
   * Gets the percentage of the rewards that will be taken by the pool before distributing
   * the rest to its delegators.
   *
   * @returns The margin of the pool.
   */
  margin(): UnitInterval {
    return this.#margin;
  }

  /**
   * Sets the percentage of the rewards that will be taken by the pool before distributing
   * the rest to its delegators.
   *
   * @param margin The margin of the pool.
   */
  setMargin(margin: UnitInterval): void {
    this.#margin = margin;
    this.#originalBytes = undefined;
  }

  /**
   * Gets the address where the pool's rewards will be sent.
   *
   * @returns The pool's rewards address.
   */
  rewardAccount(): Cardano.RewardAddress {
    return this.#rewardAccount;
  }

  /**
   * Sets the address where the pool's rewards will be sent.
   *
   * @param rewardAccount The pool's rewards address.
   */
  setRewardAccount(rewardAccount: Cardano.RewardAddress): void {
    this.#rewardAccount = rewardAccount;
    this.#originalBytes = undefined;
  }

  /**
   * Gets the public keys of the owners of the stake pool.
   *
   * @returns The pool owners key hashes.
   */
  poolOwners(): Array<Crypto.Ed25519KeyHashHex> {
    return this.#poolOwners;
  }

  /**
   * Sets the public keys of the owners of the stake pool.
   *
   * @param poolOwners The pool owners key hashes.
   */
  setPoolOwners(poolOwners: Array<Crypto.Ed25519KeyHashHex>): void {
    this.#poolOwners = [...poolOwners];
    this.#originalBytes = undefined;
  }

  /**
   * Gets the network addresses (IP and/or DNS) of the relay nodes running in the pool.
   *
   * @returns The network addresses of the pool relay nodes.
   */
  relays(): Array<Relay> {
    return this.#relays;
  }

  /**
   * Sets the network addresses (IP and/or DNS) of the relay nodes running in the pool.
   *
   * @param relays The network addresses of the pool relay nodes.
   */
  setRelays(relays: Array<Relay>): void {
    this.#relays = [...relays];
    this.#originalBytes = undefined;
  }

  /**
   * Gets the pool associated metadata.
   *
   * @returns The pool associated metadata if any; otherwise; undefined.
   */
  poolMetadata(): PoolMetadata | undefined {
    return this.#poolMetadata;
  }

  /**
   * Sets the pool associated metadata.
   *
   * @param poolMetadata The pool associated metadata if any; otherwise; undefined.
   */
  setPoolMetadata(poolMetadata: PoolMetadata): void {
    this.#poolMetadata = poolMetadata;
    this.#originalBytes = undefined;
  }
}
