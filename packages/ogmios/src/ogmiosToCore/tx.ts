import { Cardano, NotImplementedError, addressNetworkId, createRewardAccount } from '@cardano-sdk/core';
import { CommonBlock } from './types';
import { Schema } from '@cardano-ogmios/client';
import Fraction from 'fraction.js';
import omit from 'lodash/omit';

// TODO: implement byron block body mapping
export const mapByronBlockBody = (_: Schema.BlockByron): Cardano.Block['body'] => [];

const mapMargin = (margin: string): Cardano.Fraction => {
  const { n: numerator, d: denominator } = new Fraction(margin);
  return { denominator, numerator };
};

const mapRelay = (relay: Schema.Relay): Cardano.Relay => {
  const port = relay.port || undefined;
  if ('hostname' in relay)
    return {
      // TODO: enum for typename
      __typename: 'RelayByName',
      hostname: relay.hostname,
      port
    };
  return {
    __typename: 'RelayByAddress',
    ipv4: relay.ipv4 || undefined,
    ipv6: relay.ipv6 || undefined,
    port
  };
};

const mapPoolParameters = (poolParameters: Schema.PoolParameters): Cardano.PoolParameters => {
  const rewardAccount = Cardano.RewardAccount(poolParameters.rewardAccount);
  return {
    ...omit(poolParameters, 'metadata'),
    // TODO: consider just casting without validation for better performance
    id: Cardano.PoolId(poolParameters.id),
    margin: mapMargin(poolParameters.margin),
    metadataJson: poolParameters.metadata
      ? {
          hash: Cardano.util.Hash32ByteBase16(poolParameters.metadata.hash),
          url: poolParameters.metadata.url
        }
      : undefined,
    owners: poolParameters.owners.map((ownerKeyHash) =>
      createRewardAccount(Cardano.Ed25519KeyHash(ownerKeyHash), addressNetworkId(rewardAccount))
    ),
    relays: poolParameters.relays.map(mapRelay),
    rewardAccount,
    vrf: Cardano.VrfVkHex(poolParameters.vrf)
  };
};

const mapCertificate = (certificate: Schema.Certificate): Cardano.Certificate => {
  if ('stakeDelegation' in certificate) {
    return {
      __typename: Cardano.CertificateType.StakeDelegation,
      poolId: Cardano.PoolId(certificate.stakeDelegation.delegatee),
      stakeKeyHash: Cardano.Ed25519KeyHash(certificate.stakeDelegation.delegator)
    };
  }
  if ('stakeKeyRegistration' in certificate) {
    return {
      __typename: Cardano.CertificateType.StakeKeyRegistration,
      stakeKeyHash: Cardano.Ed25519KeyHash(certificate.stakeKeyRegistration)
    };
  }
  if ('stakeKeyDeregistration' in certificate) {
    return {
      __typename: Cardano.CertificateType.StakeKeyDeregistration,
      stakeKeyHash: Cardano.Ed25519KeyHash(certificate.stakeKeyDeregistration)
    };
  }
  if ('poolRegistration' in certificate) {
    return {
      __typename: Cardano.CertificateType.PoolRegistration,
      poolParameters: mapPoolParameters(certificate.poolRegistration)
    } as Cardano.PoolRegistrationCertificate;
  }
  if ('poolRetirement' in certificate) {
    return {
      __typename: Cardano.CertificateType.PoolRetirement,
      epoch: certificate.poolRetirement.retirementEpoch,
      poolId: Cardano.PoolId(certificate.poolRetirement.poolId)
    };
  }
  if ('genesisDelegation' in certificate) {
    return {
      __typename: Cardano.CertificateType.GenesisKeyDelegation,
      genesisDelegateHash: Cardano.util.Hash28ByteBase16(certificate.genesisDelegation.delegateKeyHash),
      genesisHash: Cardano.util.Hash28ByteBase16(certificate.genesisDelegation.verificationKeyHash),
      vrfKeyHash: Cardano.util.Hash32ByteBase16(certificate.genesisDelegation.vrfVerificationKeyHash)
    };
  }
  if ('moveInstantaneousRewards' in certificate) {
    return {
      __typename: Cardano.CertificateType.MIR,
      pot:
        certificate.moveInstantaneousRewards.pot === 'reserves'
          ? Cardano.MirCertificatePot.Reserves
          : Cardano.MirCertificatePot.Treasury,
      quantity: certificate.moveInstantaneousRewards.value || 0n
      // TODO: update MIR certificate type to support 'rewards' (multiple reward acc map to coins)
      // This is currently not compatible with core type (missing 'rewardAccount' which doesnt exist in ogmios)
      // rewardAccount: certificate.moveInstantaneousRewards.rewards.
      // Add test for it too.
    } as Cardano.MirCertificate;
  }
  throw new NotImplementedError('Unknown certificate mapping');
};

// TODO: implement full block body mapping
const mapCommonTx = (tx: CommonBlock['body'][0]): Cardano.Tx =>
  ({
    body: {
      certificates: tx.body.certificates.map(mapCertificate)
    } as Cardano.TxBody
  } as Cardano.Tx);

export const mapCommonBlockBody = ({ body }: CommonBlock): Cardano.Block['body'] => body.map(mapCommonTx);
