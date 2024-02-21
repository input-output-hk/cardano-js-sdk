import * as Cardano from '../../Cardano';
import * as Crypto from '@cardano-sdk/crypto';
import { CborReader, CborReaderState, CborWriter } from '../CBOR';
import { CertificateKind } from './CertificateKind';
import { HexBlob, InvalidArgumentError } from '@cardano-sdk/util';
import { PoolMetadata, PoolParams, Relay } from './PoolParams';
import { UnitInterval } from '../Common';

const EMBEDDED_GROUP_SIZE = 10;

/**
 * This certificate is used to register a new stake pool. It includes various details
 * about the pool such as the pledge, costs, margin, reward account, and the pool's owners and relays.
 */
export class PoolRegistration {
  #params: PoolParams;
  #originalBytes: HexBlob | undefined = undefined;

  /**
   * Initializes a new instance of the PoolRegistration class.
   *
   * @param params The pool registration/update parameters.
   */
  constructor(params: PoolParams) {
    this.#params = params;
  }

  /**
   * Serializes a PoolRegistration into CBOR format.
   *
   * @returns The PoolRegistration in CBOR format.
   */
  toCbor(): HexBlob {
    const writer = new CborWriter();

    if (this.#originalBytes) return this.#originalBytes;

    // pool_registration = (3, pool_params)
    // pool_params is a basic group which means its fields will flatten into pool_registration
    // rather that inserted as a subgroup.
    writer.writeStartArray(EMBEDDED_GROUP_SIZE);

    writer.writeInt(CertificateKind.PoolRegistration);

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
    writer.writeByteString(Buffer.from(this.#params.operator(), 'hex'));
    writer.writeByteString(Buffer.from(this.#params.vrfKeyHash(), 'hex'));
    writer.writeInt(this.#params.pledge());
    writer.writeInt(this.#params.cost());
    writer.writeEncodedValue(Buffer.from(this.#params.margin().toCbor(), 'hex'));
    writer.writeByteString(Buffer.from(this.#params.rewardAccount().toAddress().toBytes(), 'hex'));

    writer.writeStartArray(this.#params.poolOwners().length);
    for (const owner of this.#params.poolOwners()) writer.writeByteString(Buffer.from(owner, 'hex'));

    writer.writeStartArray(this.#params.relays().length);
    for (const relay of this.#params.relays()) writer.writeEncodedValue(Buffer.from(relay.toCbor(), 'hex'));

    if (this.#params.poolMetadata()) {
      writer.writeEncodedValue(Buffer.from(this.#params.poolMetadata()!.toCbor(), 'hex'));
    } else {
      writer.writeNull();
    }

    return writer.encodeAsHex();
  }

  /**
   * Deserializes the PoolRegistration from a CBOR byte array.
   *
   * @param cbor The CBOR encoded PoolRegistration object.
   * @returns The new PoolRegistration instance.
   */
  static fromCbor(cbor: HexBlob): PoolRegistration {
    const reader = new CborReader(cbor);

    const length = reader.readStartArray();

    if (length !== EMBEDDED_GROUP_SIZE)
      throw new InvalidArgumentError(
        'cbor',
        `Expected an array of ${EMBEDDED_GROUP_SIZE} elements, but got an array of ${length} elements`
      );

    const kind = Number(reader.readInt());

    if (kind !== CertificateKind.PoolRegistration)
      throw new InvalidArgumentError(
        'cbor',
        `Expected certificate kind ${CertificateKind.PoolRegistration}, but got ${kind}`
      );

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

    const params = new PoolParams(
      operator,
      vrfKeyHash,
      pledge,
      cost,
      margin,
      rewardAccount,
      poolOwner,
      relays,
      poolMetadata
    );

    reader.readEndArray();

    const cert = new PoolRegistration(params);
    cert.#originalBytes = cbor;

    return cert;
  }

  /**
   * Creates a Core PoolRegistrationCertificate object from the current PoolRegistration object.
   *
   * @returns The Core PoolRegistrationCertificate object.
   */
  toCore(): Cardano.PoolRegistrationCertificate {
    return {
      __typename: Cardano.CertificateType.PoolRegistration,
      poolParameters: this.#params.toCore()
    };
  }

  /**
   * Creates a PoolRegistration object from the given Core PoolRegistrationCertificate object.
   *
   * @param cert core PoolRegistrationCertificate object.
   */
  static fromCore(cert: Cardano.PoolRegistrationCertificate) {
    return new PoolRegistration(PoolParams.fromCore(cert.poolParameters));
  }

  /**
   * Gets the pool parameters from this certificate.
   *
   * @returns The pool parameters.
   */
  poolParameters(): PoolParams {
    return this.#params;
  }

  /**
   * Sets the pool parameters from this certificate.
   *
   * @param parameters The pool parameters.
   */
  setPoolParameters(parameters: PoolParams): void {
    this.#params = parameters;
    this.#originalBytes = undefined;
  }
}
