import * as Cardano from '../../Cardano';
import { CborReader } from '../CBOR';
import { CertificateKind } from './CertificateKind';
import { GenesisKeyDelegation } from './GenesisKeyDelegation';
import { HexBlob, InvalidStateError } from '@cardano-sdk/util';
import { MoveInstantaneousReward } from './MoveInstantaneousReward';
import { PoolRegistration } from './PoolRegistration';
import { PoolRetirement } from './PoolRetirement';
import { StakeDelegation } from './StakeDelegation';
import { StakeDeregistration } from './StakeDeregistration';
import { StakeRegistration } from './StakeRegistration';

/**
 * Certificates are a means to encode various essential operations related to stake
 * delegation and stake pool management. Certificates are embedded in transactions and
 * included in blocks. They're a vital aspect of Cardano's proof-of-stake mechanism,
 * ensuring that stakeholders can participate in the protocol and its governance.
 */
export class Certificate {
  #kind: CertificateKind;
  #genesisKeyDelegation: GenesisKeyDelegation;
  #moveInstantaneousReward: MoveInstantaneousReward;
  #poolRegistration: PoolRegistration;
  #poolRetirement: PoolRetirement;
  #stakeDelegation: StakeDelegation;
  #stakeDeregistration: StakeDeregistration;
  #stakeRegistration: StakeRegistration;
  #originalBytes: HexBlob | undefined = undefined;

  /**
   * Serializes a Certificate into CBOR format.
   *
   * @returns The Certificate in CBOR format.
   */
  toCbor(): HexBlob {
    if (this.#originalBytes) return this.#originalBytes;

    let cbor;

    switch (this.#kind) {
      case CertificateKind.StakeRegistration:
        cbor = this.#stakeRegistration!.toCbor();
        break;
      case CertificateKind.StakeDeregistration:
        cbor = this.#stakeDeregistration!.toCbor();
        break;
      case CertificateKind.StakeDelegation:
        cbor = this.#stakeDelegation!.toCbor();
        break;
      case CertificateKind.PoolRetirement:
        cbor = this.#poolRetirement!.toCbor();
        break;
      case CertificateKind.PoolRegistration:
        cbor = this.#poolRegistration!.toCbor();
        break;
      case CertificateKind.MoveInstantaneousRewards:
        cbor = this.#moveInstantaneousReward!.toCbor();
        break;
      case CertificateKind.GenesisKeyDelegation:
        cbor = this.#genesisKeyDelegation!.toCbor();
        break;
      default:
        throw new InvalidStateError(`Unexpected kind value: ${this.#kind}`);
    }

    return cbor;
  }

  /**
   * Deserializes the Certificate from a CBOR byte array.
   *
   * @param cbor The CBOR encoded Certificate object.
   * @returns The new Certificate instance.
   */
  static fromCbor(cbor: HexBlob): Certificate {
    let certificate: Certificate;

    const reader = new CborReader(cbor);

    reader.readStartArray();
    const kind = Number(reader.readInt());

    switch (kind) {
      case CertificateKind.StakeRegistration:
        certificate = Certificate.newStakeRegistration(StakeRegistration.fromCbor(cbor));
        break;
      case CertificateKind.StakeDeregistration:
        certificate = Certificate.newStakeDeregistration(StakeDeregistration.fromCbor(cbor));
        break;
      case CertificateKind.StakeDelegation:
        certificate = Certificate.newStakeDelegation(StakeDelegation.fromCbor(cbor));
        break;
      case CertificateKind.PoolRetirement:
        certificate = Certificate.newPoolRetirement(PoolRetirement.fromCbor(cbor));
        break;
      case CertificateKind.PoolRegistration:
        certificate = Certificate.newPoolRegistration(PoolRegistration.fromCbor(cbor));
        break;
      case CertificateKind.MoveInstantaneousRewards:
        certificate = Certificate.newMoveInstantaneousRewardsCert(MoveInstantaneousReward.fromCbor(cbor));
        break;
      case CertificateKind.GenesisKeyDelegation:
        certificate = Certificate.newGenesisKeyDelegation(GenesisKeyDelegation.fromCbor(cbor));
        break;
      default:
        throw new InvalidStateError(`Unexpected kind value: ${kind}`);
    }

    certificate.#originalBytes = cbor;

    return certificate;
  }

  /**
   * Creates a Core Certificate object from the current Certificate object.
   *
   * @returns The Core Certificate object.
   */
  toCore(): Cardano.Certificate {
    let core;

    switch (this.#kind) {
      case CertificateKind.StakeRegistration:
        core = this.#stakeRegistration!.toCore();
        break;
      case CertificateKind.StakeDeregistration:
        core = this.#stakeDeregistration!.toCore();
        break;
      case CertificateKind.StakeDelegation:
        core = this.#stakeDelegation!.toCore();
        break;
      case CertificateKind.PoolRetirement:
        core = this.#poolRetirement!.toCore();
        break;
      case CertificateKind.PoolRegistration:
        core = this.#poolRegistration!.toCore();
        break;
      case CertificateKind.MoveInstantaneousRewards:
        core = this.#moveInstantaneousReward!.toCore();
        break;
      case CertificateKind.GenesisKeyDelegation:
        core = this.#genesisKeyDelegation!.toCore();
        break;
      default:
        throw new InvalidStateError(`Unexpected kind value: ${this.#kind}`);
    }

    return core;
  }

  /**
   * Creates a Certificate object from the given Core Certificate object.
   *
   * @param certificate The core Certificate object.
   */
  static fromCore(certificate: Cardano.Certificate): Certificate {
    let cert: Certificate;

    switch (certificate.__typename) {
      case Cardano.CertificateType.StakeKeyRegistration:
        cert = Certificate.newStakeRegistration(StakeRegistration.fromCore(certificate));
        break;
      case Cardano.CertificateType.StakeKeyDeregistration:
        cert = Certificate.newStakeDeregistration(StakeDeregistration.fromCore(certificate));
        break;
      case Cardano.CertificateType.StakeDelegation:
        cert = Certificate.newStakeDelegation(StakeDelegation.fromCore(certificate));
        break;
      case Cardano.CertificateType.PoolRetirement:
        cert = Certificate.newPoolRetirement(PoolRetirement.fromCore(certificate));
        break;
      case Cardano.CertificateType.PoolRegistration:
        cert = Certificate.newPoolRegistration(PoolRegistration.fromCore(certificate));
        break;
      case Cardano.CertificateType.MIR:
        cert = Certificate.newMoveInstantaneousRewardsCert(MoveInstantaneousReward.fromCore(certificate));
        break;
      case Cardano.CertificateType.GenesisKeyDelegation:
        cert = Certificate.newGenesisKeyDelegation(GenesisKeyDelegation.fromCore(certificate));
        break;
      default:
        throw new InvalidStateError('Unexpected certificate type');
    }

    return cert;
  }

  /**
   * Gets a Certificate from a StakeRegistration instance.
   *
   * @param stakeRegistration The StakeRegistration instance to 'cast' to Certificate.
   */
  static newStakeRegistration(stakeRegistration: StakeRegistration): Certificate {
    const cert = new Certificate();
    cert.#stakeRegistration = stakeRegistration;
    cert.#kind = CertificateKind.StakeRegistration;

    return cert;
  }

  /**
   * Gets a Certificate from a StakeDeregistration instance.
   *
   * @param stakeDeregistration The StakeDeregistration instance to 'cast' to Certificate.
   */
  static newStakeDeregistration(stakeDeregistration: StakeDeregistration): Certificate {
    const cert = new Certificate();
    cert.#stakeDeregistration = stakeDeregistration;
    cert.#kind = CertificateKind.StakeDeregistration;

    return cert;
  }

  /**
   * Gets a Certificate from a StakeDelegation instance.
   *
   * @param stakeDelegation The StakeDelegation instance to 'cast' to Certificate.
   */
  static newStakeDelegation(stakeDelegation: StakeDelegation): Certificate {
    const cert = new Certificate();
    cert.#stakeDelegation = stakeDelegation;
    cert.#kind = CertificateKind.StakeDelegation;

    return cert;
  }

  /**
   * Gets a Certificate from a PoolRegistration instance.
   *
   * @param poolRegistration The PoolRegistration instance to 'cast' to Certificate.
   */
  static newPoolRegistration(poolRegistration: PoolRegistration): Certificate {
    const cert = new Certificate();
    cert.#poolRegistration = poolRegistration;
    cert.#kind = CertificateKind.PoolRegistration;

    return cert;
  }

  /**
   * Gets a Certificate from a PoolRetirement instance.
   *
   * @param poolRetirement The PoolRetirement instance to 'cast' to Certificate.
   */
  static newPoolRetirement(poolRetirement: PoolRetirement): Certificate {
    const cert = new Certificate();
    cert.#poolRetirement = poolRetirement;
    cert.#kind = CertificateKind.PoolRetirement;

    return cert;
  }

  /**
   * Gets a Certificate from a GenesisKeyDelegation instance.
   *
   * @param genesisKeyDelegation The GenesisKeyDelegation instance to 'cast' to Certificate.
   */
  static newGenesisKeyDelegation(genesisKeyDelegation: GenesisKeyDelegation): Certificate {
    const cert = new Certificate();
    cert.#genesisKeyDelegation = genesisKeyDelegation;
    cert.#kind = CertificateKind.GenesisKeyDelegation;

    return cert;
  }

  /**
   * Gets a Certificate from a MoveInstantaneousReward instance.
   *
   * @param moveInstantaneousRewards The MoveInstantaneousReward instance to 'cast' to Certificate.
   */
  static newMoveInstantaneousRewardsCert(moveInstantaneousRewards: MoveInstantaneousReward): Certificate {
    const cert = new Certificate();
    cert.#moveInstantaneousReward = moveInstantaneousRewards;
    cert.#kind = CertificateKind.MoveInstantaneousRewards;

    return cert;
  }

  /**
   * Gets the certificate kind.
   *
   * @returns The certificate kind.
   */
  kind(): CertificateKind {
    return this.#kind;
  }

  /**
   * Gets a StakeRegistration from a Certificate instance.
   *
   * @returns a StakeRegistration if the certificate can be down cast, otherwise, undefined.
   */
  asStakeRegistration(): StakeRegistration | undefined {
    return this.#stakeRegistration;
  }

  /**
   * Gets a StakeDeregistration from a Certificate instance.
   *
   * @returns a StakeDeregistration if the certificate can be down cast, otherwise, undefined.
   */
  asStakeDeregistration(): StakeDeregistration | undefined {
    return this.#stakeDeregistration;
  }

  /**
   * Gets a StakeDelegation from a Certificate instance.
   *
   * @returns a StakeDelegation if the certificate can be down cast, otherwise, undefined.
   */
  asStakeDelegation(): StakeDelegation | undefined {
    return this.#stakeDelegation;
  }

  /**
   * Gets a PoolRegistration from a Certificate instance.
   *
   * @returns a PoolRegistration if the certificate can be down cast, otherwise, undefined.
   */
  asPoolRegistration(): PoolRegistration | undefined {
    return this.#poolRegistration;
  }

  /**
   * Gets a PoolRetirement from a Certificate instance.
   *
   * @returns a PoolRetirement if the certificate can be down cast, otherwise, undefined.
   */
  asPoolRetirement(): PoolRetirement | undefined {
    return this.#poolRetirement;
  }

  /**
   * Gets a GenesisKeyDelegation from a Certificate instance.
   *
   * @returns a GenesisKeyDelegation if the certificate can be down cast, otherwise, undefined.
   */
  asGenesisKeyDelegation(): GenesisKeyDelegation | undefined {
    return this.#genesisKeyDelegation;
  }

  /**
   * Gets a MoveInstantaneousReward from a Certificate instance.
   *
   * @returns a MoveInstantaneousReward if the certificate can be down cast, otherwise, undefined.
   */
  asMoveInstantaneousRewardsCert(): MoveInstantaneousReward | undefined {
    return this.#moveInstantaneousReward;
  }
}
