import * as Crypto from '@cardano-sdk/crypto';
import * as Trezor from '@trezor/connect';
import { BIP32Path } from '@cardano-sdk/crypto';
import { Cardano } from '@cardano-sdk/core';
import { GroupedAddress, util } from '@cardano-sdk/key-management';
import {
  InvalidArgumentError,
  Transform,
  areNumbersEqualInConstantTime,
  areStringsEqualInConstantTime
} from '@cardano-sdk/util';
import { TrezorTxTransformerContext } from '../types';

type CertCredentialsType = {
  scriptHash?: Crypto.Ed25519KeyHashHex;
  keyHash?: Crypto.Ed25519KeyHashHex;
  path?: BIP32Path;
};

const getCertCredentials = (
  stakeKeyHash: Crypto.Ed25519KeyHashHex,
  knownAddresses: GroupedAddress[] | undefined
): CertCredentialsType => {
  const knownAddress = knownAddresses?.find((address) =>
    areStringsEqualInConstantTime(Cardano.RewardAccount.toHash(address.rewardAccount), stakeKeyHash)
  );
  const rewardAddress = knownAddress ? Cardano.Address.fromBech32(knownAddress.rewardAccount)?.asReward() : null;

  if (
    !!rewardAddress &&
    areNumbersEqualInConstantTime(rewardAddress?.getPaymentCredential().type, Cardano.CredentialType.KeyHash)
  ) {
    const path = util.stakeKeyPathFromGroupedAddress({ address: knownAddress });
    return path ? { path } : { keyHash: stakeKeyHash };
  }
  return {
    scriptHash: stakeKeyHash
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
  return util.stakeKeyPathFromGroupedAddress({ address: knownAddress });
};

export const getStakeAddressCertificate: Transform<
  Cardano.StakeAddressCertificate,
  Trezor.CardanoCertificate,
  TrezorTxTransformerContext
> = (certificate, context) => {
  const credentials = getCertCredentials(
    certificate.stakeCredential.hash as unknown as Crypto.Ed25519KeyHashHex,
    context?.knownAddresses
  );
  const certificateType =
    certificate.__typename === Cardano.CertificateType.StakeRegistration
      ? Trezor.PROTO.CardanoCertificateType.STAKE_REGISTRATION
      : Trezor.PROTO.CardanoCertificateType.STAKE_DEREGISTRATION;
  return {
    keyHash: credentials.keyHash,
    path: credentials.path,
    pool: undefined,
    poolParameters: undefined,
    scriptHash: credentials.scriptHash,
    type: certificateType
  };
};

export const getStakeDelegationCertificate: Transform<
  Cardano.StakeDelegationCertificate,
  Trezor.CardanoCertificate,
  TrezorTxTransformerContext
> = (certificate, context) => {
  const poolIdKeyHash = Cardano.PoolId.toKeyHash(certificate.poolId);
  const credentials = getCertCredentials(
    certificate.stakeCredential.hash as unknown as Crypto.Ed25519KeyHashHex,
    context?.knownAddresses
  );
  return {
    keyHash: credentials.keyHash,
    path: credentials.path,
    pool: poolIdKeyHash,
    poolParameters: undefined,
    scriptHash: credentials.scriptHash,
    type: Trezor.PROTO.CardanoCertificateType.STAKE_DELEGATION
  };
};

export const getPoolRegistrationCertificate: Transform<
  Cardano.PoolRegistrationCertificate,
  Trezor.CardanoCertificate,
  TrezorTxTransformerContext
> = (certificate, context) => {
  if (!certificate.poolParameters.metadataJson)
    throw new InvalidArgumentError('certificate', 'Missing pool registration pool metadata.');
  return {
    keyHash: undefined,
    path: undefined,
    pool: undefined,
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
              type: Trezor.PROTO.CardanoPoolRelayType.SINGLE_HOST_IP
            };
          case 'RelayByName':
            return {
              hostName: relay.hostname,
              port: relay.port,
              type: Trezor.PROTO.CardanoPoolRelayType.SINGLE_HOST_NAME
            };
          case 'RelayByNameMultihost':
            return {
              hostName: relay.dnsName,
              type: Trezor.PROTO.CardanoPoolRelayType.MULTIPLE_HOST_NAME
            };
          default:
            throw new InvalidArgumentError('certificate', 'Unknown relay type.');
        }
      }),
      rewardAccount: certificate.poolParameters.rewardAccount,
      vrfKeyHash: certificate.poolParameters.vrf
    },
    scriptHash: undefined,
    type: Trezor.PROTO.CardanoCertificateType.STAKE_POOL_REGISTRATION
  };
};

const toCert = (cert: Cardano.Certificate, context: TrezorTxTransformerContext) => {
  switch (cert.__typename) {
    case Cardano.CertificateType.StakeRegistration:
      return getStakeAddressCertificate(cert, context);
    case Cardano.CertificateType.StakeDeregistration:
      return getStakeAddressCertificate(cert, context);
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
