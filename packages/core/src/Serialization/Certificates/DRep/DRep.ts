import * as Cardano from '../../../Cardano/index.js';
import * as Crypto from '@cardano-sdk/crypto';
import { CborReader, CborWriter } from '../../CBOR/index.js';
import { DRepKind } from './DRepKind.js';
import { HexBlob } from '@cardano-sdk/util';

/**
 * In Voltaire, existing stake credentials will be able to delegate their stake to DReps
 * for voting purposes, in addition to the current delegation to stake pools for block production.
 *
 * Just as the number of blocks that a pool mint depends on the total stake, the amount of decision-making
 * power will depend on the number of coins delegated to a DRep.
 *
 * Registered DReps are identified by a credential that can be either:
 *
 * - A verification key (Ed25519)
 * - A native or Plutus script
 */
export class DRep {
  #credential: Cardano.Credential | undefined;
  #kind: DRepKind;
  #originalBytes: HexBlob | undefined = undefined;

  /**
   * Initializes a new instance of the DRep class.
   *
   * @param kind The kind of DRep.
   * @param credential The DRep credential.
   */
  constructor(kind: DRepKind, credential?: Cardano.Credential) {
    this.#credential = credential;
    this.#kind = kind;
  }

  /**
   * Serializes a DRep into CBOR format.
   *
   * @returns The DRep in CBOR format.
   */
  toCbor(): HexBlob {
    const writer = new CborWriter();

    if (this.#originalBytes) return this.#originalBytes;

    // CDDL
    // drep =
    //   [ 0, addr_keyhash
    //   // 1, scripthash
    //   // 2  ; always abstain
    //   // 3  ; always no confidence
    //   ]
    if (this.#kind === DRepKind.KeyHash || this.#kind === DRepKind.ScriptHash) {
      writer.writeStartArray(2);
      writer.writeInt(this.#credential!.type);
      writer.writeByteString(Buffer.from(this.#credential!.hash, 'hex'));

      return writer.encodeAsHex();
    }

    writer.writeStartArray(1);
    writer.writeInt(this.#kind);

    return writer.encodeAsHex();
  }

  /**
   * Deserializes the DRep from a CBOR byte array.
   *
   * @param cbor The CBOR encoded DRep object.
   * @returns The new DRep instance.
   */
  static fromCbor(cbor: HexBlob): DRep {
    const reader = new CborReader(cbor);

    reader.readStartArray();

    const kind = Number(reader.readInt());

    if (kind === DRepKind.KeyHash || kind === DRepKind.ScriptHash) {
      const hash = Crypto.Hash28ByteBase16(HexBlob.fromBytes(reader.readByteString()));

      if (kind === DRepKind.KeyHash) {
        return DRep.newKeyHash(hash as unknown as Crypto.Ed25519KeyHashHex);
      }

      return DRep.newScriptHash(hash);
    }

    reader.readEndArray();

    if (kind === DRepKind.Abstain) return DRep.newAlwaysAbstain();

    return DRep.newAlwaysNoConfidence();
  }

  /**
   * Creates a Core DelegateRepresentative object from the current DRep object.
   *
   * @returns The Core DelegateRepresentative object.
   */
  toCore(): Cardano.DelegateRepresentative {
    if (this.#kind === DRepKind.KeyHash || this.#kind === DRepKind.ScriptHash) return this.#credential!;

    if (this.#kind === DRepKind.Abstain)
      return {
        __typename: 'AlwaysAbstain'
      };

    return {
      __typename: 'AlwaysNoConfidence'
    };
  }

  /**
   * Creates a DRep object from the given Core DelegateRepresentative object.
   *
   * @param deleg core DelegateRepresentative object.
   */
  static fromCore(deleg: Cardano.DelegateRepresentative) {
    if (Cardano.isDRepAlwaysAbstain(deleg)) return DRep.newAlwaysAbstain();
    if (Cardano.isDRepAlwaysNoConfidence(deleg)) return DRep.newAlwaysNoConfidence();

    if (deleg.type === Cardano.CredentialType.KeyHash)
      return DRep.newKeyHash(deleg.hash as unknown as Crypto.Ed25519KeyHashHex);

    return DRep.newScriptHash(deleg.hash);
  }

  /**
   * Creates a new DRep from an Ed25519 verification key hash.
   *
   * @param keyHash The hash of the Ed25519 verification key.
   * @returns The DRep instance.
   */
  static newKeyHash(keyHash: Crypto.Ed25519KeyHashHex): DRep {
    return new DRep(DRepKind.KeyHash, {
      hash: keyHash as unknown as Crypto.Hash28ByteBase16,
      type: Cardano.CredentialType.KeyHash
    });
  }

  /**
   * Creates a new DRep from a native or Plutus script hash.
   *
   * @param scriptHash The script hash.
   * @returns The DRep instance.
   */
  static newScriptHash(scriptHash: Crypto.Hash28ByteBase16): DRep {
    return new DRep(DRepKind.ScriptHash, {
      hash: scriptHash as unknown as Crypto.Hash28ByteBase16,
      type: Cardano.CredentialType.ScriptHash
    });
  }

  /**
   * Creates an Always Abstain DRep.
   *
   * @returns The DRep instance.
   */
  static newAlwaysAbstain(): DRep {
    return new DRep(DRepKind.Abstain, undefined);
  }

  /**
   * Creates an Always No Confidence DRep.
   *
   * @returns The DRep instance.
   */
  static newAlwaysNoConfidence(): DRep {
    return new DRep(DRepKind.NoConfidence, undefined);
  }

  /**
   * Gets the DRep kind.
   *
   * @returns The DRep kind.
   */
  kind(): DRepKind {
    return this.#kind;
  }

  /**
   * Gets the verification key hash of the DRep if any, otherwise, returns undefined.
   *
   * @returns The verification key hash or undefined.
   */
  toKeyHash(): Crypto.Ed25519KeyHashHex | undefined {
    if (this.#kind !== DRepKind.KeyHash) return undefined;

    return this.#credential?.hash as unknown as Crypto.Ed25519KeyHashHex;
  }

  /**
   * Gets the script hash of the DRep if any, otherwise, returns undefined.
   *
   * @returns The script hash or undefined.
   */
  toScriptHash(): Crypto.Hash28ByteBase16 | undefined {
    if (this.#kind !== DRepKind.ScriptHash) return undefined;

    return this.#credential?.hash;
  }
}
