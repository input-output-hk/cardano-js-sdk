import * as Crypto from '@cardano-sdk/crypto';
import { CborReader, CborReaderState, CborTag } from '../CBOR';
import { CborSet, Credential, Hash } from '../Common';
import { HexBlob, InvalidArgumentError, InvalidStateError } from '@cardano-sdk/util';
import type { Cardano } from '../..';

/** The wire representation used by a {@link Guards} instance. */
export enum GuardsKind {
  KeyHashes = 0,
  Credentials = 1
}

type KeyHashSet = CborSet<Crypto.Ed25519KeyHashHex, Hash<Crypto.Ed25519KeyHashHex>>;
type CredentialSet = CborSet<Cardano.Credential, Credential>;

/**
 * Guards are credentials (key hashes or script hashes) that must approve the transaction.
 *
 * On the wire this is an alternation: a non-empty set of bare key hashes (byte-identical to the
 * legacy required_signers field) or a non-empty ordered set of full credentials. A single
 * instance always uses exactly one of the two forms for all of its elements.
 */
export class Guards {
  #keyHashes: KeyHashSet | undefined;
  #credentials: CredentialSet | undefined;

  // Prevent users from directly creating an instance. Only allow creating via the static factories.
  private constructor(keyHashes?: KeyHashSet, credentials?: CredentialSet) {
    this.#keyHashes = keyHashes;
    this.#credentials = credentials;
  }

  /**
   * Serializes the guards into CBOR format.
   *
   * @returns The guards in CBOR format.
   */
  toCbor(): HexBlob {
    if (this.#keyHashes) return this.#keyHashes.toCbor();
    if (this.#credentials) return this.#credentials.toCbor();

    throw new InvalidStateError('Guards instance has no values');
  }

  /**
   * Deserializes guards from a CBOR byte array represented as either an array or a `258` tag.
   *
   * Disambiguation mirrors decodeGuards in the ledger Dijkstra TxBody.hs: if the first element
   * is a CBOR array, every element is decoded as a full credential; otherwise every element is
   * decoded as a bare key hash. An empty set decodes as key hash form: the Dijkstra guards rule
   * is non-empty, but pre-Conway required_signers was a plain set and empty sets exist on chain.
   *
   * @param cbor The CBOR encoded guards.
   * @returns The new Guards instance.
   */
  static fromCbor(cbor: HexBlob): Guards {
    const reader = new CborReader(cbor);

    if (reader.peekState() === CborReaderState.Tag && reader.peekTag() === CborTag.Set) reader.readTag();

    reader.readStartArray();

    if (reader.peekState() === CborReaderState.StartArray)
      return new Guards(undefined, CborSet.fromCbor(cbor, Credential.fromCbor));

    return new Guards(CborSet.fromCbor<Crypto.Ed25519KeyHashHex, Hash<Crypto.Ed25519KeyHashHex>>(cbor, Hash.fromCbor));
  }

  /**
   * Creates key hash form guards from the given core key hashes. Element order is preserved.
   *
   * @param keyHashes The key hashes of the guards.
   * @returns The new Guards instance.
   */
  static fromKeyHashes(keyHashes: Crypto.Ed25519KeyHashHex[]): Guards {
    return new Guards(
      CborSet.fromCore<Crypto.Ed25519KeyHashHex, Hash<Crypto.Ed25519KeyHashHex>>(keyHashes, Hash.fromCore)
    );
  }

  /**
   * Creates credential form guards from the given core credentials. Element order is preserved.
   *
   * @param credentials The credentials of the guards.
   * @returns The new Guards instance.
   */
  static fromCredentials(credentials: Cardano.Credential[]): Guards {
    if (credentials.length === 0)
      throw new InvalidArgumentError('credentials', 'Credential form guards must contain at least one element');

    return new Guards(undefined, CborSet.fromCore(credentials, Credential.fromCore));
  }

  /**
   * Gets the wire representation this instance encodes to.
   *
   * @returns The guards kind.
   */
  kind(): GuardsKind {
    return this.#keyHashes ? GuardsKind.KeyHashes : GuardsKind.Credentials;
  }

  /**
   * Gets the guards as core key hashes if this instance uses the key hash form.
   *
   * @returns The key hashes, or undefined for credential form guards.
   */
  keyHashes(): Crypto.Ed25519KeyHashHex[] | undefined {
    return this.#keyHashes?.toCore();
  }

  /**
   * Gets the guards as core credentials if this instance uses the credential form.
   *
   * @returns The credentials, or undefined for key hash form guards.
   */
  credentials(): Cardano.Credential[] | undefined {
    return this.#credentials?.toCore();
  }

  /**
   * Gets the number of guards.
   *
   * @returns The element count.
   */
  size(): number {
    return this.#keyHashes ? this.#keyHashes.size() : this.#credentials ? this.#credentials.size() : 0;
  }
}
