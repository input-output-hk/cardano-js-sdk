import * as Crypto from '@cardano-sdk/crypto';
import { CML, Cardano, coreToCml, util } from '@cardano-sdk/core';
import { HexBlob, usingAutoFree } from '@cardano-sdk/util';
import blake2b from 'blake2b';

/**
 * CIP-36 metadata label
 */
export enum MetadataLabel {
  DATA = 61_284,
  SIG = 61_285
}

/**
 * CIP-36 signature metadatum map key
 */
export const SIG_MAP_KEY = 1n;

/**
 * CIP-36 vote key derivation path constants
 */
export enum CIP36VoteKeyDerivationPath {
  PURPOSE = 1694,
  COIN_TYPE = 1815
}

/**
 * Voting power delegation to a specified vote key
 */
export interface VoteKeyDelegation {
  cip36VoteKey: Crypto.Ed25519PublicKeyHex;
  /**
   * Integer >0
   */
  weight: number;
}

/**
 * Part of the CIP-36 transaction metadata (NOT key derivation path's `purpose`).
 */
export enum VotingPurpose {
  CATALYST = 0
}

export interface BuildVotingRegistrationProps {
  delegations: VoteKeyDelegation[];
  stakeKey: Crypto.Ed25519PublicKeyHex;
  paymentAddress: Cardano.Address;
  purpose: VotingPurpose;
  nonce?: number;
}

/*
 * Sign blob with some key
 */
export interface BlobSigner {
  /**
   * Sign blob with some key
   */
  signBlob(blob: HexBlob): Promise<Crypto.Ed25519SignatureHex>;
}

export const metadataBuilder = {
  /**
   * Build partial CIP-36 transaction metadata (without signature).
   */
  buildVotingRegistration({
    delegations,
    stakeKey,
    purpose,
    paymentAddress,
    nonce = Date.now()
  }: BuildVotingRegistrationProps): Cardano.TxMetadata {
    const cmlPaymentAddress = CML.Address.from_bech32(paymentAddress);
    const votingRegistration = new Map<bigint, Cardano.Metadatum>([
      [1n, delegations.map(({ cip36VoteKey, weight }) => [Buffer.from(cip36VoteKey, 'hex'), BigInt(weight)])],
      [2n, Buffer.from(stakeKey, 'hex')],
      [3n, Buffer.from(cmlPaymentAddress.to_bytes())],
      [4n, BigInt(nonce)],
      [5n, BigInt(purpose)]
    ]);

    return new Map([[BigInt(MetadataLabel.DATA), votingRegistration]]);
  },

  /**
   * Sign metadata built with `buildVotingRegistration`
   *
   * @returns Signed CIP-36 transaction metadata
   */
  async signVotingRegistration(
    votingRegistrationMetadata: Cardano.TxMetadata,
    stakeKeyBlobSigner: BlobSigner
  ): Promise<Cardano.TxMetadata> {
    const votingRegistrationMetadataBytes = usingAutoFree((scope) =>
      coreToCml.txMetadata(scope, votingRegistrationMetadata).to_bytes()
    );
    const hashedMetadata = blake2b(256 / 8)
      .update(votingRegistrationMetadataBytes)
      .digest('binary');
    const signature = await stakeKeyBlobSigner.signBlob(util.bytesToHex(hashedMetadata));
    return new Map([
      ...votingRegistrationMetadata.entries(),
      [BigInt(MetadataLabel.SIG), new Map([[SIG_MAP_KEY, Buffer.from(signature, 'hex')]])]
    ]);
  }
};

export type MetadataBuilder = typeof metadataBuilder;
