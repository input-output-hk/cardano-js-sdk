import * as Ledger from '@cardano-foundation/ledgerjs-hw-app-cardano';
import { Cardano } from '@cardano-sdk/core';
import { GroupedAddress, util } from '@cardano-sdk/key-management';
import { InvalidArgumentError, Transform, areStringsEqualInConstantTime } from '@cardano-sdk/util';
import { LedgerTxTransformerContext } from '../types';

type StakeKeyCertificateType = Ledger.CertificateType.STAKE_REGISTRATION | Ledger.CertificateType.STAKE_DEREGISTRATION;

type StakeKeyCertificate = {
  params: {
    stakeCredential: Ledger.StakeCredentialParams;
  };
  type: StakeKeyCertificateType;
};

// Type guard for certificates with stakeCredential
const hasStakeCredential = (
  certificate: Cardano.StakeAddressCertificate | Cardano.StakeDelegationCertificate | Cardano.PoolRetirementCertificate
): certificate is Cardano.StakeAddressCertificate | Cardano.StakeDelegationCertificate =>
  'stakeCredential' in certificate;

/**
 * This function checks if the provided certificate contains a stake credential and if so, attempts to
 * find a corresponding known address within the provided context based on a constant-time string comparison
 * of the hashed reward account and the stake credential hash.
 *
 * @param {Cardano.StakeAddressCertificate | Cardano.StakeDelegationCertificate | Cardano.PoolRetirementCertificate} certificate - The certificate containing a stake credential.
 * @param {LedgerTxTransformerContext} [context] - The context containing known addresses to search within. Optional; if not provided, the function returns undefined.
 * @returns {GroupedAddress | undefined} The matching grouped address if found, or undefined if no match is found or if context is not provided.
 */
export const getKnownAddress = (
  certificate: Cardano.StakeAddressCertificate | Cardano.StakeDelegationCertificate | Cardano.PoolRetirementCertificate,
  context?: LedgerTxTransformerContext
): GroupedAddress | undefined =>
  !!context && hasStakeCredential(certificate)
    ? context?.knownAddresses.find((address) =>
        areStringsEqualInConstantTime(
          Cardano.RewardAccount.toHash(address.rewardAccount) as unknown as string,
          certificate.stakeCredential.hash as unknown as string
        )
      )
    : undefined;

const getStakeAddressCertificate = (
  certificate: Cardano.StakeAddressCertificate,
  context: LedgerTxTransformerContext,
  type: StakeKeyCertificateType
): StakeKeyCertificate => {
  const knownAddress = getKnownAddress(certificate, context);

  const rewardAddress = knownAddress ? Cardano.Address.fromBech32(knownAddress.rewardAccount)?.asReward() : null;
  const path = util.stakeKeyPathFromGroupedAddress(knownAddress);
  const credentialType = rewardAddress
    ? rewardAddress.getPaymentCredential().type
    : Ledger.StakeCredentialParamsType.SCRIPT_HASH;

  let credential: Ledger.StakeCredentialParams;

  switch (credentialType) {
    case Cardano.CredentialType.KeyHash: {
      credential = path
        ? {
            keyPath: path,
            type: Ledger.StakeCredentialParamsType.KEY_PATH
          }
        : {
            keyHashHex: certificate.stakeCredential.hash,
            type: Ledger.StakeCredentialParamsType.KEY_HASH
          };
      break;
    }
    case Cardano.CredentialType.ScriptHash:
    default: {
      credential = {
        scriptHashHex: certificate.stakeCredential.hash,
        type: Ledger.StakeCredentialParamsType.SCRIPT_HASH
      };
    }
  }

  return {
    params: {
      stakeCredential: credential
    },
    type
  };
};

export const stakeDelegationCertificate: Transform<
  Cardano.StakeDelegationCertificate,
  Ledger.Certificate,
  LedgerTxTransformerContext
> = (certificate, context): Ledger.Certificate => {
  const poolIdKeyHash = Cardano.PoolId.toKeyHash(certificate.poolId);
  const knownAddress = getKnownAddress(certificate, context);

  const rewardAddress = knownAddress ? Cardano.Address.fromBech32(knownAddress.rewardAccount)?.asReward() : null;

  const credentialType = rewardAddress
    ? rewardAddress.getPaymentCredential().type
    : Ledger.StakeCredentialParamsType.SCRIPT_HASH;

  const path = util.stakeKeyPathFromGroupedAddress(knownAddress);

  let credential: Ledger.StakeCredentialParams;

  switch (credentialType) {
    case Cardano.CredentialType.KeyHash: {
      credential = path
        ? {
            keyPath: path,
            type: Ledger.StakeCredentialParamsType.KEY_PATH
          }
        : {
            keyHashHex: certificate.stakeCredential.hash,
            type: Ledger.StakeCredentialParamsType.KEY_HASH
          };
      break;
    }
    case Cardano.CredentialType.ScriptHash:
    default: {
      credential = {
        scriptHashHex: certificate.stakeCredential.hash,
        type: Ledger.StakeCredentialParamsType.SCRIPT_HASH
      };
    }
  }

  return {
    params: {
      poolKeyHashHex: poolIdKeyHash,
      stakeCredential: credential
    },
    type: Ledger.CertificateType.STAKE_DELEGATION
  };
};

const toPoolMetadata: Transform<Cardano.PoolMetadataJson, Ledger.PoolMetadataParams> = (metadataJson) => ({
  metadataHashHex: metadataJson.hash,
  metadataUrl: metadataJson.url
});

const getPoolOperatorKeyPath = (
  operator: Cardano.RewardAccount,
  context: LedgerTxTransformerContext
): Ledger.BIP32Path | null => {
  const knownAddress = context?.knownAddresses.find((address) => address.rewardAccount === operator);
  return util.stakeKeyPathFromGroupedAddress(knownAddress);
};

export const poolRegistrationCertificate: Transform<
  Cardano.PoolRegistrationCertificate,
  Ledger.Certificate,
  LedgerTxTransformerContext
> = (certificate, context): Ledger.Certificate => {
  const poolOperatorKeyPath = getPoolOperatorKeyPath(certificate.poolParameters.rewardAccount, context!);
  const poolOperatorKeyHash = Cardano.RewardAccount.toHash(certificate.poolParameters.rewardAccount);

  return {
    params: {
      cost: certificate.poolParameters.cost,
      margin: certificate.poolParameters.margin,
      metadata: certificate.poolParameters.metadataJson
        ? toPoolMetadata(certificate.poolParameters.metadataJson)
        : undefined,
      pledge: certificate.poolParameters.pledge,
      poolKey: poolOperatorKeyPath
        ? {
            params: {
              path: poolOperatorKeyPath
            },
            type: Ledger.PoolKeyType.DEVICE_OWNED
          }
        : {
            params: {
              keyHashHex: poolOperatorKeyHash
            },
            type: Ledger.PoolKeyType.THIRD_PARTY
          },
      poolOwners: certificate.poolParameters.owners.map((owner) => {
        const poolOwnerKeyPath = getPoolOperatorKeyPath(owner, context!);
        const poolOwnerKeyHash = Cardano.RewardAccount.toHash(owner);
        return poolOwnerKeyPath
          ? {
              params: {
                stakingPath: poolOwnerKeyPath
              },
              type: Ledger.PoolOwnerType.DEVICE_OWNED
            }
          : {
              params: {
                stakingKeyHashHex: poolOwnerKeyHash
              },
              type: Ledger.PoolOwnerType.THIRD_PARTY
            };
      }),
      relays: certificate.poolParameters.relays.map((relay) => {
        switch (relay.__typename) {
          case 'RelayByAddress':
            return {
              params: {
                ipv4: relay.ipv4,
                ipv6: relay.ipv6,
                portNumber: relay.port
              },
              type: Ledger.RelayType.SINGLE_HOST_IP_ADDR
            };
          case 'RelayByName':
            return {
              params: {
                dnsName: relay.hostname,
                portNumber: relay.port
              },
              type: Ledger.RelayType.SINGLE_HOST_HOSTNAME
            };
          case 'RelayByNameMultihost':
            return {
              params: {
                dnsName: relay.dnsName
              },
              type: Ledger.RelayType.SINGLE_HOST_HOSTNAME
            };
        }
      }),
      rewardAccount: poolOperatorKeyPath
        ? {
            params: {
              path: poolOperatorKeyPath
            },
            type: Ledger.PoolRewardAccountType.DEVICE_OWNED
          }
        : {
            params: {
              rewardAccountHex: Cardano.Address.fromBech32(certificate.poolParameters.rewardAccount).toBytes()
            },
            type: Ledger.PoolRewardAccountType.THIRD_PARTY
          },
      vrfKeyHashHex: certificate.poolParameters.vrf
    },
    type: Ledger.CertificateType.STAKE_POOL_REGISTRATION
  };
};

const poolRetirementCertificate: Transform<
  Cardano.PoolRetirementCertificate,
  Ledger.Certificate,
  LedgerTxTransformerContext
> = (certificate, context): Ledger.Certificate => {
  const poolIdKeyHash = Cardano.PoolId.toKeyHash(certificate.poolId);

  const knownAddress = context?.knownAddresses.find((address) =>
    areStringsEqualInConstantTime(
      Cardano.RewardAccount.toHash(address.rewardAccount) as unknown as string,
      poolIdKeyHash as unknown as string
    )
  );

  const poolKeyPath = util.stakeKeyPathFromGroupedAddress(knownAddress);

  if (!poolKeyPath) throw new InvalidArgumentError('certificate', 'Missing key matching pool retirement certificate.');

  return {
    params: {
      poolKeyPath,
      retirementEpoch: certificate.epoch
    },
    type: Ledger.CertificateType.STAKE_POOL_RETIREMENT
  };
};

const toCert = (cert: Cardano.Certificate, context: LedgerTxTransformerContext) => {
  switch (cert.__typename) {
    case Cardano.CertificateType.StakeRegistration:
      return getStakeAddressCertificate(cert, context, Ledger.CertificateType.STAKE_REGISTRATION);
    case Cardano.CertificateType.StakeDeregistration:
      return getStakeAddressCertificate(cert, context, Ledger.CertificateType.STAKE_DEREGISTRATION);
    case Cardano.CertificateType.StakeDelegation:
      return stakeDelegationCertificate(cert, context);
    case Cardano.CertificateType.PoolRegistration:
      return poolRegistrationCertificate(cert, context);
    case Cardano.CertificateType.PoolRetirement:
      return poolRetirementCertificate(cert, context);
    default:
      throw new InvalidArgumentError('cert', `Certificate ${cert.__typename} not supported.`);
  }
};

export const mapCerts = (
  certs: Cardano.Certificate[] | undefined,
  context: LedgerTxTransformerContext
): Ledger.Certificate[] | null => {
  if (!certs) return null;

  return certs.map((coreCert) => toCert(coreCert, context));
};
