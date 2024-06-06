import * as Cardano from '../../Cardano/index.js';
import * as Crypto from '@cardano-sdk/crypto';
import { CborReader, CborWriter } from '../CBOR/index.js';
import { CertificateKind } from './CertificateKind.js';
import { HexBlob, InvalidArgumentError } from '@cardano-sdk/util';

const EMBEDDED_GROUP_SIZE = 4;

/**
 * This certificate is used to delegate from a Genesis key to a set of keys. This was primarily used in the early
 * phases of the Cardano network's existence during the transition from the Byron to the Shelley era.
 */
export class GenesisKeyDelegation {
  #genesisHash: Crypto.Hash28ByteBase16;
  #genesisDelegateHash: Crypto.Hash28ByteBase16;
  #vrfKeyHash: Crypto.Hash32ByteBase16;
  #originalBytes: HexBlob | undefined = undefined;

  /**
   * Initializes a new instance of the GenesisKeyDelegation class.
   *
   * @param genesisHash The genesis block of the particular blockchain network, which is
   * a unique identifier for that chain. This is used to confirm that the delegation is
   * occurring on the intended blockchain.
   * @param genesisDelegateHash This is the public key hash of the delegate to whom the
   * power of the genesis key is being delegated. In the transitional phase from the Byron
   * era to the Shelley era, the holders of the genesis keys used a GenesisKeyDelegation
   * certificate to delegate their rights to produce blocks to a specific set of new keys (genesis delegates).
   * @param vrfKeyHash This is the hash of the Verifiable Random Function (VRF) key of the delegate.
   */
  constructor(
    genesisHash: Crypto.Hash28ByteBase16,
    genesisDelegateHash: Crypto.Hash28ByteBase16,
    vrfKeyHash: Crypto.Hash32ByteBase16
  ) {
    this.#genesisHash = genesisHash;
    this.#genesisDelegateHash = genesisDelegateHash;
    this.#vrfKeyHash = vrfKeyHash;
  }

  /**
   * Serializes a GenesisKeyDelegation into CBOR format.
   *
   * @returns The GenesisKeyDelegation in CBOR format.
   */
  toCbor(): HexBlob {
    const writer = new CborWriter();

    if (this.#originalBytes) return this.#originalBytes;

    // CDDL
    // genesis_key_delegation = (5, genesishash, genesis_delegate_hash, vrf_keyhash)
    writer.writeStartArray(EMBEDDED_GROUP_SIZE);

    writer.writeInt(CertificateKind.GenesisKeyDelegation);

    writer.writeByteString(Buffer.from(this.#genesisHash, 'hex'));
    writer.writeByteString(Buffer.from(this.#genesisDelegateHash, 'hex'));
    writer.writeByteString(Buffer.from(this.#vrfKeyHash, 'hex'));

    return writer.encodeAsHex();
  }

  /**
   * Deserializes the GenesisKeyDelegation from a CBOR byte array.
   *
   * @param cbor The CBOR encoded GenesisKeyDelegation object.
   * @returns The new GenesisKeyDelegation instance.
   */
  static fromCbor(cbor: HexBlob): GenesisKeyDelegation {
    const reader = new CborReader(cbor);

    const length = reader.readStartArray();

    if (length !== EMBEDDED_GROUP_SIZE)
      throw new InvalidArgumentError(
        'cbor',
        `Expected an array of ${EMBEDDED_GROUP_SIZE} elements, but got an array of ${length} elements`
      );

    const kind = Number(reader.readInt());

    if (kind !== CertificateKind.GenesisKeyDelegation)
      throw new InvalidArgumentError(
        'cbor',
        `Expected certificate kind ${CertificateKind.GenesisKeyDelegation}, but got ${kind}`
      );

    const genesisHash = Crypto.Hash28ByteBase16(HexBlob.fromBytes(reader.readByteString()));
    const genesisDelegateHash = Crypto.Hash28ByteBase16(HexBlob.fromBytes(reader.readByteString()));
    const vrfKeyHash = Crypto.Hash32ByteBase16(HexBlob.fromBytes(reader.readByteString()));

    reader.readEndArray();

    const cert = new GenesisKeyDelegation(genesisHash, genesisDelegateHash, vrfKeyHash);
    cert.#originalBytes = cbor;

    return cert;
  }

  /**
   * Creates a Core GenesisKeyDelegationCertificate object from the current GenesisKeyDelegation object.
   *
   * @returns The Core GenesisKeyDelegationCertificate object.
   */
  toCore(): Cardano.GenesisKeyDelegationCertificate {
    return {
      __typename: Cardano.CertificateType.GenesisKeyDelegation,
      genesisDelegateHash: this.#genesisDelegateHash,
      genesisHash: this.#genesisHash,
      vrfKeyHash: this.#vrfKeyHash
    };
  }

  /**
   * Creates a GenesisKeyDelegation object from the given Core GenesisKeyDelegationCertificate object.
   *
   * @param cert core GenesisKeyDelegationCertificate object.
   */
  static fromCore(cert: Cardano.GenesisKeyDelegationCertificate) {
    return new GenesisKeyDelegation(cert.genesisHash, cert.genesisDelegateHash, cert.vrfKeyHash);
  }

  /**
   * Gets the genesis block of the particular blockchain network, which is
   * a unique identifier for that chain. This is used to confirm that the delegation is
   * occurring on the intended blockchain.
   *
   * @returns The genesis hash.
   */
  genesisHash(): Crypto.Hash28ByteBase16 {
    return this.#genesisHash;
  }

  /**
   * Sets the genesis block of the particular blockchain network.
   *
   * @param genesisHash The genesis hash.
   */
  setGenesisHash(genesisHash: Crypto.Hash28ByteBase16): void {
    this.#genesisHash = genesisHash;
    this.#originalBytes = undefined;
  }

  /**
   * Gets the public key hash of the delegate to whom the power of the genesis key is being delegated.
   * In the transitional phase from the Byron era to the Shelley era, the holders of the genesis keys
   * used a GenesisKeyDelegation certificate to delegate their rights to produce blocks to a specific
   * set of new keys (genesis delegates).
   *
   * @returns The public key hash of the delegate.
   */
  genesisDelegateHash(): Crypto.Hash28ByteBase16 {
    return this.#genesisDelegateHash;
  }

  /**
   * Sets the public key hash of the delegate to whom the power of the genesis key is being delegated.
   *
   * @param genesisDelegateHash The public key hash of the delegate.
   */
  setGenesisDelegateHash(genesisDelegateHash: Crypto.Hash28ByteBase16): void {
    this.#genesisDelegateHash = genesisDelegateHash;
    this.#originalBytes = undefined;
  }

  /**
   * Gets the hash of the Verifiable Random Function (VRF) key of the delegate.
   *
   * @returns The hash of the Verifiable Random Function (VRF) key.
   */
  vrfKeyHash(): Crypto.Hash32ByteBase16 {
    return this.#vrfKeyHash;
  }

  /**
   * Sets the hash of the Verifiable Random Function (VRF) key of the delegate.
   *
   * @param vrfKeyHash The hash of the Verifiable Random Function (VRF) key.
   */
  setVrfKeyHash(vrfKeyHash: Crypto.Hash32ByteBase16): void {
    this.#vrfKeyHash = vrfKeyHash;
    this.#originalBytes = undefined;
  }
}
