import { CborReader, CborWriter } from '../../CBOR/index.js';
import { CredentialType, VoterType } from '../../../Cardano/index.js';
import { HexBlob, InvalidArgumentError, InvalidStateError } from '@cardano-sdk/util';
import { VoterKind } from './VoterKind.js';
import type * as Cardano from '../../../Cardano/index.js';
import type { Ed25519KeyHashHex, Hash28ByteBase16 } from '@cardano-sdk/crypto';

const EMBEDDED_GROUP_SIZE = 2;

/**
 * A voter is any participant with an eligible role who either has a direct stake or has delegated their stake,
 * and they exercise their rights by casting votes on governance actions. The weight or influence of their vote
 * is determined by the amount of their active stake or the stake that's been delegated to them.
 *
 * Various roles in the Cardano ecosystem can participate in voting. This includes constitutional committee members,
 * DReps (Delegation Representatives), and SPOs (Stake Pool Operators).
 */
export class Voter {
  #kind: VoterKind;
  #credential: Cardano.Credential;
  #originalBytes: HexBlob | undefined = undefined;

  /**
   * Initializes a new instance of the Voter class.
   *
   * @param kind The kind of voter.
   * @param credential The voter credential.
   */
  constructor(kind: VoterKind, credential: Cardano.Credential) {
    this.#kind = kind;
    this.#credential = credential;
  }

  /**
   * Serializes a Voter into CBOR format.
   *
   * @returns The Voter in CBOR format.
   */
  toCbor(): HexBlob {
    if (this.#originalBytes) return this.#originalBytes;

    const writer = new CborWriter();

    // CDDL
    // ; Constitutional Committee Hot KeyHash: 0
    // ; Constitutional Committee Hot ScriptHash: 1
    // ; DRep KeyHash: 2
    // ; DRep ScriptHash: 3
    // ; StakingPool KeyHash: 4
    // voter =
    //   [ 0, addr_keyhash
    //   // 1, scripthash
    //   // 2, addr_keyhash
    //   // 3, scripthash
    //   // 4, addr_keyhash
    //   ]
    writer.writeStartArray(EMBEDDED_GROUP_SIZE);
    writer.writeInt(this.#kind);
    writer.writeByteString(Buffer.from(this.#credential.hash, 'hex'));

    return writer.encodeAsHex();
  }

  /**
   * Deserializes the Voter from a CBOR byte array.
   *
   * @param cbor The CBOR encoded Voter object.
   * @returns The new Voter instance.
   */
  static fromCbor(cbor: HexBlob): Voter {
    let credential: Cardano.Credential;

    const reader = new CborReader(cbor);

    const length = reader.readStartArray();

    if (length !== EMBEDDED_GROUP_SIZE)
      throw new InvalidArgumentError(
        'cbor',
        `Expected an array of ${EMBEDDED_GROUP_SIZE} elements, but got an array of ${length} elements`
      );

    const kind = Number(reader.readInt());
    const hash = HexBlob.fromBytes(reader.readByteString()) as unknown as Hash28ByteBase16;

    switch (kind) {
      case VoterKind.ConstitutionalCommitteeKeyHash:
      case VoterKind.DrepKeyHash:
      case VoterKind.StakePoolKeyHash:
        credential = { hash, type: CredentialType.KeyHash };
        break;
      case VoterKind.ConstitutionalCommitteeScriptHash:
      case VoterKind.DRepScriptHash:
        credential = { hash, type: CredentialType.ScriptHash };
        break;
      default:
        throw new InvalidStateError(`Unexpected kind value: ${kind}`);
    }

    const voter = new Voter(kind, credential);
    voter.#originalBytes = cbor;

    return voter;
  }

  /**
   * Creates a Core Voter object from the current Voter object.
   *
   * @returns The Core Voter object.
   */
  toCore(): Cardano.Voter {
    switch (this.#kind) {
      case VoterKind.ConstitutionalCommitteeKeyHash:
        return {
          __typename: VoterType.ccHotKeyHash,
          credential: {
            hash: this.#credential.hash,
            type: CredentialType.KeyHash
          }
        };
      case VoterKind.ConstitutionalCommitteeScriptHash:
        return {
          __typename: VoterType.ccHotScriptHash,
          credential: {
            hash: this.#credential.hash,
            type: CredentialType.ScriptHash
          }
        };
      case VoterKind.DrepKeyHash:
        return {
          __typename: VoterType.dRepKeyHash,
          credential: {
            hash: this.#credential.hash,
            type: CredentialType.KeyHash
          }
        };
      case VoterKind.DRepScriptHash:
        return {
          __typename: VoterType.dRepScriptHash,
          credential: {
            hash: this.#credential.hash,
            type: CredentialType.ScriptHash
          }
        };
      case VoterKind.StakePoolKeyHash:
        return {
          __typename: VoterType.stakePoolKeyHash,
          credential: {
            hash: this.#credential.hash,
            type: CredentialType.KeyHash
          }
        };
      default:
        throw new InvalidStateError(`Unexpected kind value: ${this.#kind}`);
    }
  }

  /**
   * Creates a Voter object from the given Core Voter object.
   *
   * @param coreVoter The core Voter object.
   */
  static fromCore(coreVoter: Cardano.Voter): Voter {
    let voter;

    switch (coreVoter.__typename) {
      case VoterType.ccHotKeyHash:
      case VoterType.ccHotScriptHash:
        voter = Voter.newConstitutionalCommitteeHotKey(coreVoter.credential);
        break;
      case VoterType.dRepKeyHash:
      case VoterType.dRepScriptHash:
        voter = Voter.newDrep(coreVoter.credential);
        break;
      case VoterType.stakePoolKeyHash:
        voter = Voter.newStakingPool(coreVoter.credential.hash as unknown as Ed25519KeyHashHex);
        break;
      default:
        throw new InvalidStateError('Unexpected Voter type');
    }

    return voter;
  }

  /**
   * Gets a constitutional committee voter instance from a given credential.
   *
   * @param credential The constitutional committee credential.
   */
  static newConstitutionalCommitteeHotKey(credential: Cardano.Credential): Voter {
    const kind =
      credential.type === CredentialType.KeyHash
        ? VoterKind.ConstitutionalCommitteeKeyHash
        : VoterKind.ConstitutionalCommitteeScriptHash;

    return new Voter(kind, credential);
  }

  /**
   * Gets a delegation representative voter instance from a given credential.
   *
   * @param credential The delegation Representative credential.
   */
  static newDrep(credential: Cardano.Credential): Voter {
    const kind = credential.type === CredentialType.KeyHash ? VoterKind.DrepKeyHash : VoterKind.DRepScriptHash;

    return new Voter(kind, credential);
  }

  /**
   * Gets a staking pool voter instance from a given key hash.
   *
   * @param keyHash The staking pool key hash.
   */
  static newStakingPool(keyHash: Ed25519KeyHashHex): Voter {
    return new Voter(VoterKind.StakePoolKeyHash, {
      hash: keyHash as unknown as Hash28ByteBase16,
      type: CredentialType.KeyHash
    });
  }

  /** Gets the voter kind. */
  kind(): VoterKind {
    return this.#kind;
  }

  /**
   * If this voter is a constitutional committee, gets its credential, otherwise, undefined.
   *
   * @returns The constitutional committee credential, or undefined.
   */
  toConstitutionalCommitteeHotCred(): Cardano.Credential | undefined {
    if (
      this.#kind === VoterKind.ConstitutionalCommitteeKeyHash ||
      this.#kind === VoterKind.ConstitutionalCommitteeScriptHash
    )
      return this.#credential;

    return undefined;
  }

  /**
   * If this voter is a delegation representative, gets its credential, otherwise, undefined.
   *
   * @returns The delegation representative credential, or undefined.
   */
  toDrepCred(): Cardano.Credential | undefined {
    if (this.#kind === VoterKind.DrepKeyHash || this.#kind === VoterKind.DRepScriptHash) return this.#credential;

    return undefined;
  }

  /**
   * If this voter is a stake pool, gets its key hash, otherwise, undefined.
   *
   * @returns The stake pool key hash.
   */
  toStakingPoolKeyHash(): Ed25519KeyHashHex | undefined {
    if (this.#kind === VoterKind.StakePoolKeyHash) return this.#credential.hash as unknown as Ed25519KeyHashHex;

    return undefined;
  }

  /**
   * Indicates whether some other Voter is "equal to" this one.
   *
   * @param other The other object to be compared.
   * @returns true if objects are equals; otherwise false.
   */
  equals(other: Voter): boolean {
    return (
      this.#kind === other.#kind &&
      this.#credential.type === other.#credential.type &&
      this.#credential.hash === other.#credential.hash
    );
  }
}
