import * as Trezor from 'trezor-connect';
import { BIP32Path } from '@cardano-sdk/crypto';
import { Cardano } from '@cardano-sdk/core';
import { InvalidArgumentError /* , Transform*/ } from '@cardano-sdk/util';
import { TrezorTxTransformerContext } from '../types';
import { stakeKeyPathFromGroupedAddress } from './keyPaths';

type StakeKeyCertificateType =
  | Trezor.CardanoCertificateType.STAKE_REGISTRATION
  | Trezor.CardanoCertificateType.STAKE_DEREGISTRATION;

type TrezorStakeKeyCertificate = {
  type: StakeKeyCertificateType;
  path?: BIP32Path;
  scriptHash?: string;
  keyHash?: string;
};

type TrezorDelegationCertificate = {
  type: Trezor.CardanoCertificateType.STAKE_DELEGATION;
  path?: BIP32Path;
  scriptHash?: string;
  pool: string;
};

type TrezorPoolRegistrationCertificate = {
  poolParameters: Trezor.CardanoPoolParameters;
  type: Trezor.CardanoCertificateType.STAKE_POOL_REGISTRATION;
};

const getStakeAddressCertificate = (
  certificate: Cardano.StakeAddressCertificate,
  context: TrezorTxTransformerContext,
  type: StakeKeyCertificateType
): TrezorStakeKeyCertificate => {
  const knownAddress = context?.knownAddresses.find(
    (address) => Cardano.RewardAccount.toHash(address.rewardAccount) === certificate.stakeKeyHash
  );
  const rewardAddress = knownAddress ? Cardano.Address.fromBech32(knownAddress.rewardAccount)?.asReward() : null;

  let credentials;
  if (rewardAddress?.getPaymentCredential().type === Cardano.CredentialType.KeyHash) {
    const path = stakeKeyPathFromGroupedAddress(knownAddress);
    credentials = path ? { path } : { keyHash: certificate.stakeKeyHash };
  } else {
    credentials = { scriptHash: certificate.stakeKeyHash };
  }

  return {
    ...credentials,
    type
  };
};

const getStakeDelegationCertificate = (
  certificate: Cardano.StakeDelegationCertificate,
  context: TrezorTxTransformerContext
): TrezorDelegationCertificate => {
  const poolIdKeyHash = Cardano.PoolId.toKeyHash(certificate.poolId);
  const knownAddress = context?.knownAddresses.find(
    (address) => Cardano.RewardAccount.toHash(address.rewardAccount) === certificate.stakeKeyHash
  );
  const rewardAddress = knownAddress ? Cardano.Address.fromBech32(knownAddress.rewardAccount)?.asReward() : null;

  let credentials;
  if (rewardAddress?.getPaymentCredential().type === Cardano.CredentialType.KeyHash) {
    const path = stakeKeyPathFromGroupedAddress(knownAddress);
    credentials = path ? { path } : { keyHash: certificate.stakeKeyHash };
  } else {
    credentials = { scriptHash: certificate.stakeKeyHash };
  }

  return {
    ...credentials,
    pool: poolIdKeyHash,
    type: Trezor.CardanoCertificateType.STAKE_DELEGATION
  };
};

const toPoolMetadata = (metadataJson: Cardano.PoolMetadataJson): Trezor.CardanoPoolMetadata => ({
  hash: metadataJson.hash,
  url: metadataJson.url
});

const getPoolOperatorKeyPath = (
  operator: Cardano.RewardAccount,
  context: TrezorTxTransformerContext
): BIP32Path | null => {
  const knownAddress = context?.knownAddresses.find((address) => address.rewardAccount === operator);
  return stakeKeyPathFromGroupedAddress(knownAddress);
};

export const getPoolRegistrationCertificate = (
  certificate: Cardano.PoolRegistrationCertificate,
  context: TrezorTxTransformerContext
): TrezorPoolRegistrationCertificate => {
  if (!certificate.poolParameters.metadataJson)
    throw new InvalidArgumentError('certificate', 'Missing pool registration pool metadata.');
  return {
    poolParameters: {
      cost: certificate.poolParameters.cost.toString(),
      margin: {
        denominator: certificate.poolParameters.margin.denominator.toString(),
        numerator: certificate.poolParameters.margin.numerator.toString()
      },
      metadata: toPoolMetadata(certificate.poolParameters.metadataJson),
      owners: certificate.poolParameters.owners.map((owner) => {
        const poolOwnerKeyPath = getPoolOperatorKeyPath(owner, context!);
        const poolOwnerKeyHash = Cardano.RewardAccount.toHash(owner);
        return poolOwnerKeyPath ? { stakingKeyPath: poolOwnerKeyPath } : { stakingKeyHash: poolOwnerKeyHash };
      }),
      pledge: certificate.poolParameters.pledge.toString(),
      poolId: Cardano.PoolId.toKeyHash(certificate.poolParameters.id),
      relays: certificate.poolParameters.relays.map((relay) => {
        switch (relay.__typename) {
          case 'RelayByAddress':
            return {
              ipv4Address: relay.ipv4,
              ipv6Address: relay.ipv6,
              port: relay.port,
              type: Trezor.CardanoPoolRelayType.SINGLE_HOST_IP
            };
          case 'RelayByName':
            return {
              hostName: relay.hostname,
              port: relay.port,
              type: Trezor.CardanoPoolRelayType.SINGLE_HOST_NAME
            };
          case 'RelayByNameMultihost':
            return {
              hostName: relay.dnsName,
              type: Trezor.CardanoPoolRelayType.MULTIPLE_HOST_NAME
            };
        }
      }),
      rewardAccount: certificate.poolParameters.rewardAccount,
      vrfKeyHash: certificate.poolParameters.vrf
    },
    type: Trezor.CardanoCertificateType.STAKE_POOL_REGISTRATION
  };
};

const toCert = (cert: Cardano.Certificate, context: TrezorTxTransformerContext) => {
  switch (cert.__typename) {
    case Cardano.CertificateType.StakeKeyRegistration:
      return getStakeAddressCertificate(cert, context, Trezor.CardanoCertificateType.STAKE_REGISTRATION);
    case Cardano.CertificateType.StakeKeyDeregistration:
      return getStakeAddressCertificate(cert, context, Trezor.CardanoCertificateType.STAKE_DEREGISTRATION);
    case Cardano.CertificateType.StakeDelegation:
      return getStakeDelegationCertificate(cert, context);
    case Cardano.CertificateType.PoolRegistration:
      return getPoolRegistrationCertificate(cert, context);
    default:
      throw new InvalidArgumentError('cert', `Certificate ${cert.__typename} not supported.`);
  }
};

export const mapCerts = (
  certs: Cardano.Certificate[],
  context: TrezorTxTransformerContext
): Trezor.CardanoCertificate[] => certs.map((coreCert) => toCert(coreCert, context));
