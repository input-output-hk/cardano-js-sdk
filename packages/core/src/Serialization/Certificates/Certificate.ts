/* eslint-disable complexity */
import * as Cardano from '../../Cardano/index.js';
import { AuthCommitteeHot } from './AuthCommitteeHot.js';
import { CborReader } from '../CBOR/index.js';
import { CertificateKind } from './CertificateKind.js';
import { GenesisKeyDelegation } from './GenesisKeyDelegation.js';
import { InvalidStateError } from '@cardano-sdk/util';
import { MoveInstantaneousReward } from './MoveInstantaneousReward/index.js';
import { PoolRegistration } from './PoolRegistration.js';
import { PoolRetirement } from './PoolRetirement.js';
import { RegisterDelegateRepresentative } from './RegisterDelegateRepresentative.js';
import { Registration } from './Registration.js';
import { ResignCommitteeCold } from './ResignCommitteeCold.js';
import { StakeDelegation } from './StakeDelegation.js';
import { StakeDeregistration } from './StakeDeregistration.js';
import { StakeRegistration } from './StakeRegistration.js';
import { StakeRegistrationDelegation } from './StakeRegistrationDelegation.js';
import { StakeVoteDelegation } from './StakeVoteDelegation.js';
import { StakeVoteRegistrationDelegation } from './StakeVoteRegistrationDelegation.js';
import { UnregisterDelegateRepresentative } from './UnregisterDelegateRepresentative.js';
import { Unregistration } from './Unregistration.js';
import { UpdateDelegateRepresentative } from './UpdateDelegateRepresentative.js';
import { VoteDelegation } from './VoteDelegation.js';
import { VoteRegistrationDelegation } from './VoteRegistrationDelegation.js';
import type { HexBlob } from '@cardano-sdk/util';

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
  #registration: Registration;
  #unregistration: Unregistration;
  #voteDelegation: VoteDelegation;
  #stakeVoteDelegation: StakeVoteDelegation;
  #stakeRegistrationDelegation: StakeRegistrationDelegation;
  #voteRegistrationDelegation: VoteRegistrationDelegation;
  #stakeVoteRegistrationDelegation: StakeVoteRegistrationDelegation;
  #authCommitteeHot: AuthCommitteeHot;
  #resignCommitteeCold: ResignCommitteeCold;
  #drepRegistration: RegisterDelegateRepresentative;
  #drepUnregistration: UnregisterDelegateRepresentative;
  #updateDrep: UpdateDelegateRepresentative;

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
      case CertificateKind.Registration:
        cbor = this.#registration!.toCbor();
        break;
      case CertificateKind.Unregistration:
        cbor = this.#unregistration!.toCbor();
        break;
      case CertificateKind.VoteDelegation:
        cbor = this.#voteDelegation!.toCbor();
        break;
      case CertificateKind.StakeVoteDelegation:
        cbor = this.#stakeVoteDelegation!.toCbor();
        break;
      case CertificateKind.StakeRegistrationDelegation:
        cbor = this.#stakeRegistrationDelegation!.toCbor();
        break;
      case CertificateKind.VoteRegistrationDelegation:
        cbor = this.#voteRegistrationDelegation!.toCbor();
        break;
      case CertificateKind.StakeVoteRegistrationDelegation:
        cbor = this.#stakeVoteRegistrationDelegation!.toCbor();
        break;
      case CertificateKind.AuthCommitteeHot:
        cbor = this.#authCommitteeHot!.toCbor();
        break;
      case CertificateKind.ResignCommitteeCold:
        cbor = this.#resignCommitteeCold!.toCbor();
        break;
      case CertificateKind.DrepRegistration:
        cbor = this.#drepRegistration!.toCbor();
        break;
      case CertificateKind.DrepUnregistration:
        cbor = this.#drepUnregistration!.toCbor();
        break;
      case CertificateKind.UpdateDrep:
        cbor = this.#updateDrep!.toCbor();
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
      case CertificateKind.Registration:
        certificate = Certificate.newRegistrationCert(Registration.fromCbor(cbor));
        break;
      case CertificateKind.Unregistration:
        certificate = Certificate.newUnregistrationCert(Unregistration.fromCbor(cbor));
        break;
      case CertificateKind.VoteDelegation:
        certificate = Certificate.newVoteDelegationCert(VoteDelegation.fromCbor(cbor));
        break;
      case CertificateKind.StakeVoteDelegation:
        certificate = Certificate.newStakeVoteDelegationCert(StakeVoteDelegation.fromCbor(cbor));
        break;
      case CertificateKind.StakeRegistrationDelegation:
        certificate = Certificate.newStakeRegistrationDelegationCert(StakeRegistrationDelegation.fromCbor(cbor));
        break;
      case CertificateKind.VoteRegistrationDelegation:
        certificate = Certificate.newVoteRegistrationDelegationCert(VoteRegistrationDelegation.fromCbor(cbor));
        break;
      case CertificateKind.StakeVoteRegistrationDelegation:
        certificate = Certificate.newStakeVoteRegistrationDelegationCert(
          StakeVoteRegistrationDelegation.fromCbor(cbor)
        );
        break;
      case CertificateKind.AuthCommitteeHot:
        certificate = Certificate.newAuthCommitteeHotCert(AuthCommitteeHot.fromCbor(cbor));
        break;
      case CertificateKind.ResignCommitteeCold:
        certificate = Certificate.newResignCommitteeColdCert(ResignCommitteeCold.fromCbor(cbor));
        break;
      case CertificateKind.DrepRegistration:
        certificate = Certificate.newRegisterDelegateRepresentativeCert(RegisterDelegateRepresentative.fromCbor(cbor));
        break;
      case CertificateKind.DrepUnregistration:
        certificate = Certificate.newUnregisterDelegateRepresentativeCert(
          UnregisterDelegateRepresentative.fromCbor(cbor)
        );
        break;
      case CertificateKind.UpdateDrep:
        certificate = Certificate.newUpdateDelegateRepresentativeCert(UpdateDelegateRepresentative.fromCbor(cbor));
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
      case CertificateKind.Registration:
        core = this.#registration!.toCore();
        break;
      case CertificateKind.Unregistration:
        core = this.#unregistration!.toCore();
        break;
      case CertificateKind.VoteDelegation:
        core = this.#voteDelegation!.toCore();
        break;
      case CertificateKind.StakeVoteDelegation:
        core = this.#stakeVoteDelegation!.toCore();
        break;
      case CertificateKind.StakeRegistrationDelegation:
        core = this.#stakeRegistrationDelegation!.toCore();
        break;
      case CertificateKind.VoteRegistrationDelegation:
        core = this.#voteRegistrationDelegation!.toCore();
        break;
      case CertificateKind.StakeVoteRegistrationDelegation:
        core = this.#stakeVoteRegistrationDelegation!.toCore();
        break;
      case CertificateKind.AuthCommitteeHot:
        core = this.#authCommitteeHot!.toCore();
        break;
      case CertificateKind.ResignCommitteeCold:
        core = this.#resignCommitteeCold!.toCore();
        break;
      case CertificateKind.DrepRegistration:
        core = this.#drepRegistration!.toCore();
        break;
      case CertificateKind.DrepUnregistration:
        core = this.#drepUnregistration!.toCore();
        break;
      case CertificateKind.UpdateDrep:
        core = this.#updateDrep!.toCore();
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
      case Cardano.CertificateType.StakeRegistration:
        cert = Certificate.newStakeRegistration(StakeRegistration.fromCore(certificate));
        break;
      case Cardano.CertificateType.StakeDeregistration:
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
      case Cardano.CertificateType.Registration:
        cert = Certificate.newRegistrationCert(Registration.fromCore(certificate));
        break;
      case Cardano.CertificateType.Unregistration:
        cert = Certificate.newUnregistrationCert(Unregistration.fromCore(certificate));
        break;
      case Cardano.CertificateType.VoteDelegation:
        cert = Certificate.newVoteDelegationCert(VoteDelegation.fromCore(certificate));
        break;
      case Cardano.CertificateType.StakeVoteDelegation:
        cert = Certificate.newStakeVoteDelegationCert(StakeVoteDelegation.fromCore(certificate));
        break;
      case Cardano.CertificateType.StakeRegistrationDelegation:
        cert = Certificate.newStakeRegistrationDelegationCert(StakeRegistrationDelegation.fromCore(certificate));
        break;
      case Cardano.CertificateType.VoteRegistrationDelegation:
        cert = Certificate.newVoteRegistrationDelegationCert(VoteRegistrationDelegation.fromCore(certificate));
        break;
      case Cardano.CertificateType.StakeVoteRegistrationDelegation:
        cert = Certificate.newStakeVoteRegistrationDelegationCert(
          StakeVoteRegistrationDelegation.fromCore(certificate)
        );
        break;
      case Cardano.CertificateType.AuthorizeCommitteeHot:
        cert = Certificate.newAuthCommitteeHotCert(AuthCommitteeHot.fromCore(certificate));
        break;
      case Cardano.CertificateType.ResignCommitteeCold:
        cert = Certificate.newResignCommitteeColdCert(ResignCommitteeCold.fromCore(certificate));
        break;
      case Cardano.CertificateType.RegisterDelegateRepresentative:
        cert = Certificate.newRegisterDelegateRepresentativeCert(RegisterDelegateRepresentative.fromCore(certificate));
        break;
      case Cardano.CertificateType.UnregisterDelegateRepresentative:
        cert = Certificate.newUnregisterDelegateRepresentativeCert(
          UnregisterDelegateRepresentative.fromCore(certificate)
        );
        break;
      case Cardano.CertificateType.UpdateDelegateRepresentative:
        cert = Certificate.newUpdateDelegateRepresentativeCert(UpdateDelegateRepresentative.fromCore(certificate));
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
   * Gets a Certificate from a Registration instance.
   *
   * @param registration The Registration instance to 'cast' to Certificate.
   */
  static newRegistrationCert(registration: Registration): Certificate {
    const cert = new Certificate();
    cert.#registration = registration;
    cert.#kind = CertificateKind.Registration;

    return cert;
  }

  /**
   * Gets a Certificate from a Unregistration instance.
   *
   * @param unregistration The Unregistration instance to 'cast' to Certificate.
   */
  static newUnregistrationCert(unregistration: Unregistration): Certificate {
    const cert = new Certificate();
    cert.#unregistration = unregistration;
    cert.#kind = CertificateKind.Unregistration;

    return cert;
  }

  /**
   * Gets a Certificate from a VoteDelegation instance.
   *
   * @param voteDelegation The VoteDelegation instance to 'cast' to Certificate.
   */
  static newVoteDelegationCert(voteDelegation: VoteDelegation): Certificate {
    const cert = new Certificate();
    cert.#voteDelegation = voteDelegation;
    cert.#kind = CertificateKind.VoteDelegation;

    return cert;
  }

  /**
   * Gets a Certificate from a StakeVoteDelegation instance.
   *
   * @param stakeVoteDelegation The StakeVoteDelegation instance to 'cast' to Certificate.
   */
  static newStakeVoteDelegationCert(stakeVoteDelegation: StakeVoteDelegation): Certificate {
    const cert = new Certificate();
    cert.#stakeVoteDelegation = stakeVoteDelegation;
    cert.#kind = CertificateKind.StakeVoteDelegation;

    return cert;
  }

  /**
   * Gets a Certificate from a StakeRegistrationDelegation instance.
   *
   * @param stakeRegistrationDelegation The StakeRegistrationDelegation instance to 'cast' to Certificate.
   */
  static newStakeRegistrationDelegationCert(stakeRegistrationDelegation: StakeRegistrationDelegation): Certificate {
    const cert = new Certificate();
    cert.#stakeRegistrationDelegation = stakeRegistrationDelegation;
    cert.#kind = CertificateKind.StakeRegistrationDelegation;

    return cert;
  }

  /**
   * Gets a Certificate from a VoteRegistrationDelegation instance.
   *
   * @param voteRegistrationDelegation The VoteRegistrationDelegation instance to 'cast' to Certificate.
   */
  static newVoteRegistrationDelegationCert(voteRegistrationDelegation: VoteRegistrationDelegation): Certificate {
    const cert = new Certificate();
    cert.#voteRegistrationDelegation = voteRegistrationDelegation;
    cert.#kind = CertificateKind.VoteRegistrationDelegation;

    return cert;
  }

  /**
   * Gets a Certificate from a StakeVoteRegistrationDelegation instance.
   *
   * @param stakeVoteRegistrationDelegation The StakeVoteRegistrationDelegation instance to 'cast' to Certificate.
   */
  static newStakeVoteRegistrationDelegationCert(
    stakeVoteRegistrationDelegation: StakeVoteRegistrationDelegation
  ): Certificate {
    const cert = new Certificate();
    cert.#stakeVoteRegistrationDelegation = stakeVoteRegistrationDelegation;
    cert.#kind = CertificateKind.StakeVoteRegistrationDelegation;

    return cert;
  }

  /**
   * Gets a Certificate from a AuthCommitteeHot instance.
   *
   * @param authCommitteeHot The AuthCommitteeHot instance to 'cast' to Certificate.
   */
  static newAuthCommitteeHotCert(authCommitteeHot: AuthCommitteeHot): Certificate {
    const cert = new Certificate();
    cert.#authCommitteeHot = authCommitteeHot;
    cert.#kind = CertificateKind.AuthCommitteeHot;

    return cert;
  }

  /**
   * Gets a Certificate from a ResignCommitteeCold instance.
   *
   * @param resignCommitteeCold The ResignCommitteeCold instance to 'cast' to Certificate.
   */
  static newResignCommitteeColdCert(resignCommitteeCold: ResignCommitteeCold): Certificate {
    const cert = new Certificate();
    cert.#resignCommitteeCold = resignCommitteeCold;
    cert.#kind = CertificateKind.ResignCommitteeCold;

    return cert;
  }

  /**
   * Gets a Certificate from a RegisterDelegateRepresentative instance.
   *
   * @param drepRegistration The RegisterDelegateRepresentative instance to 'cast' to Certificate.
   */
  static newRegisterDelegateRepresentativeCert(drepRegistration: RegisterDelegateRepresentative): Certificate {
    const cert = new Certificate();
    cert.#drepRegistration = drepRegistration;
    cert.#kind = CertificateKind.DrepRegistration;

    return cert;
  }

  /**
   * Gets a Certificate from a UnregisterDelegateRepresentative instance.
   *
   * @param drepUnregistration The UnregisterDelegateRepresentative instance to 'cast' to Certificate.
   */
  static newUnregisterDelegateRepresentativeCert(drepUnregistration: UnregisterDelegateRepresentative): Certificate {
    const cert = new Certificate();
    cert.#drepUnregistration = drepUnregistration;
    cert.#kind = CertificateKind.DrepUnregistration;

    return cert;
  }

  /**
   * Gets a Certificate from a UpdateDelegateRepresentative instance.
   *
   * @param updateDrep The UpdateDelegateRepresentative instance to 'cast' to Certificate.
   */
  static newUpdateDelegateRepresentativeCert(updateDrep: UpdateDelegateRepresentative): Certificate {
    const cert = new Certificate();
    cert.#updateDrep = updateDrep;
    cert.#kind = CertificateKind.UpdateDrep;

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

  /**
   * Gets a Registration from a Certificate instance.
   *
   * @returns a Registration if the certificate can be down cast, otherwise, undefined.
   */
  asRegistrationCert(): Registration | undefined {
    return this.#registration;
  }

  /**
   * Gets a Unregistration from a Certificate instance.
   *
   * @returns a Unregistration if the certificate can be down cast, otherwise, undefined.
   */
  asUnregistrationCert(): Unregistration | undefined {
    return this.#unregistration;
  }

  /**
   * Gets a VoteDelegation from a Certificate instance.
   *
   * @returns a VoteDelegation if the certificate can be down cast, otherwise, undefined.
   */
  asVoteDelegationCert(): VoteDelegation | undefined {
    return this.#voteDelegation;
  }

  /**
   * Gets a StakeVoteDelegation from a Certificate instance.
   *
   * @returns a StakeVoteDelegation if the certificate can be down cast, otherwise, undefined.
   */
  asStakeVoteDelegationCert(): StakeVoteDelegation | undefined {
    return this.#stakeVoteDelegation;
  }

  /**
   * Gets a StakeRegistrationDelegation from a Certificate instance.
   *
   * @returns a StakeRegistrationDelegation if the certificate can be down cast, otherwise, undefined.
   */
  asStakeRegistrationDelegationCert(): StakeRegistrationDelegation | undefined {
    return this.#stakeRegistrationDelegation;
  }

  /**
   * Gets a VoteRegistrationDelegation from a Certificate instance.
   *
   * @returns a VoteRegistrationDelegation if the certificate can be down cast, otherwise, undefined.
   */
  asVoteRegistrationDelegationCert(): VoteRegistrationDelegation | undefined {
    return this.#voteRegistrationDelegation;
  }

  /**
   * Gets a StakeVoteRegistrationDelegation from a Certificate instance.
   *
   * @returns a StakeVoteRegistrationDelegation if the certificate can be down cast, otherwise, undefined.
   */
  asStakeVoteRegistrationDelegationCert(): StakeVoteRegistrationDelegation | undefined {
    return this.#stakeVoteRegistrationDelegation;
  }

  /**
   * Gets a AuthCommitteeHot from a Certificate instance.
   *
   * @returns a AuthCommitteeHot if the certificate can be down cast, otherwise, undefined.
   */
  asAuthCommitteeHotCert(): AuthCommitteeHot | undefined {
    return this.#authCommitteeHot;
  }

  /**
   * Gets a ResignCommitteeCold from a Certificate instance.
   *
   * @returns a ResignCommitteeCold if the certificate can be down cast, otherwise, undefined.
   */
  asResignCommitteeColdCert(): ResignCommitteeCold | undefined {
    return this.#resignCommitteeCold;
  }

  /**
   * Gets a RegisterDelegateRepresentative from a Certificate instance.
   *
   * @returns a RegisterDelegateRepresentative if the certificate can be down cast, otherwise, undefined.
   */
  asRegisterDelegateRepresentativeCert(): RegisterDelegateRepresentative | undefined {
    return this.#drepRegistration;
  }

  /**
   * Gets a UnregisterDelegateRepresentative from a Certificate instance.
   *
   * @returns a UnregisterDelegateRepresentative if the certificate can be down cast, otherwise, undefined.
   */
  asUnregisterDelegateRepresentativeCert(): UnregisterDelegateRepresentative | undefined {
    return this.#drepUnregistration;
  }

  /**
   * Gets a UpdateDelegateRepresentative from a Certificate instance.
   *
   * @returns a UpdateDelegateRepresentative if the certificate can be down cast, otherwise, undefined.
   */
  asUpdateDelegateRepresentativeCert(): UpdateDelegateRepresentative | undefined {
    return this.#updateDrep;
  }
}
