/* eslint-disable complexity */
import * as Crypto from '@cardano-sdk/crypto';
import * as Ledger from '@cardano-foundation/ledgerjs-hw-app-cardano';
import { Cardano } from '@cardano-sdk/core';
import { GroupedAddress, util } from '@cardano-sdk/key-management';
import { InvalidArgumentError, Transform, areStringsEqualInConstantTime } from '@cardano-sdk/util';
import { LedgerTxTransformerContext } from '../types';

const mapAnchorToParams = (certificate: Cardano.Certificate) => ({
  ...('anchor' in certificate &&
    certificate?.anchor && { anchor: { hashHex: certificate.anchor.dataHash, url: certificate.anchor.url } })
});

const credentialMapper = (
  credential: Cardano.Credential,
  credentialType: Cardano.CredentialType | Ledger.CredentialParamsType.SCRIPT_HASH,
  path: Crypto.BIP32Path | null
): Ledger.CredentialParams => {
  let credentialParams: Ledger.CredentialParams;

  switch (credentialType) {
    case Cardano.CredentialType.KeyHash: {
      credentialParams = path
        ? {
            keyPath: path,
            type: Ledger.CredentialParamsType.KEY_PATH
          }
        : {
            keyHashHex: credential.hash,
            type: Ledger.CredentialParamsType.KEY_HASH
          };
      break;
    }
    case Cardano.CredentialType.ScriptHash:
    default: {
      credentialParams = {
        scriptHashHex: credential.hash,
        type: Ledger.CredentialParamsType.SCRIPT_HASH
      };
    }
  }

  return credentialParams;
};

const drepParamsMapper = (
  drep: Cardano.Credential,
  credentialType: Cardano.CredentialType | Ledger.CredentialParamsType.SCRIPT_HASH
): Ledger.KeyPathDRepParams | Ledger.KeyHashDRepParams | Ledger.ScriptHashDRepParams => {
  let dRepParams: Ledger.DRepParams;

  switch (credentialType) {
    case Cardano.CredentialType.KeyHash: {
      dRepParams = {
        keyHashHex: drep.hash,
        type: Ledger.DRepParamsType.KEY_HASH
      };
      break;
    }
    case Cardano.CredentialType.ScriptHash:
    default: {
      dRepParams = {
        scriptHashHex: drep.hash,
        type: Ledger.DRepParamsType.SCRIPT_HASH
      };
    }
  }

  return dRepParams;
};

/**
 * This function attempts to find a corresponding known address within the provided context based
 * on a constant-time string comparison of the hashed reward account and the stake credential hash.
 *
 * @param {Cardano.Credential} credential - Stake credential.
 * @param {LedgerTxTransformerContext} [context] - The context containing known addresses to search within. Optional; if not provided, the function returns undefined.
 * @returns {GroupedAddress | undefined} The matching grouped address if found, or undefined if no match is found or if context is not provided.
 */
export const getKnownAddress = (
  credential: Cardano.Credential,
  context?: LedgerTxTransformerContext
): GroupedAddress | undefined =>
  context
    ? context?.knownAddresses.find((address) =>
        areStringsEqualInConstantTime(
          Cardano.RewardAccount.toHash(address.rewardAccount) as unknown as string,
          credential.hash as unknown as string
        )
      )
    : undefined;

const getCredentialType = (knownAddress: GroupedAddress | undefined) => {
  const rewardAddress = knownAddress ? Cardano.Address.fromBech32(knownAddress.rewardAccount)?.asReward() : null;
  return rewardAddress ? rewardAddress.getPaymentCredential().type : Ledger.CredentialParamsType.SCRIPT_HASH;
};

const stakeCredentialMapper = (credential: Cardano.Credential, context: LedgerTxTransformerContext) => {
  const knownAddress = getKnownAddress(credential, context);
  const credentialType = getCredentialType(knownAddress);
  const path = util.stakeKeyPathFromGroupedAddress(knownAddress);

  return credentialMapper(credential, credentialType, path);
};

const getStakeAddressCertificate: Transform<
  Cardano.StakeAddressCertificate,
  Ledger.Certificate,
  LedgerTxTransformerContext
> = (certificate, context): Ledger.Certificate => ({
  params: {
    stakeCredential: stakeCredentialMapper(certificate.stakeCredential, context!)
  },
  type:
    certificate.__typename === Cardano.CertificateType.StakeRegistration
      ? Ledger.CertificateType.STAKE_REGISTRATION
      : Ledger.CertificateType.STAKE_DEREGISTRATION
});

const getNewStakeAddressCertificate: Transform<
  Cardano.NewStakeAddressCertificate,
  Ledger.Certificate,
  LedgerTxTransformerContext
> = (certificate, context): Ledger.Certificate => ({
  params: {
    deposit: certificate.deposit,
    stakeCredential: stakeCredentialMapper(certificate.stakeCredential, context!)
  },
  type:
    certificate.__typename === Cardano.CertificateType.Registration
      ? Ledger.CertificateType.STAKE_REGISTRATION_CONWAY
      : Ledger.CertificateType.STAKE_DEREGISTRATION_CONWAY
});

export const stakeDelegationCertificate: Transform<
  Cardano.StakeDelegationCertificate,
  Ledger.Certificate,
  LedgerTxTransformerContext
> = (certificate, context): Ledger.Certificate => ({
  params: {
    poolKeyHashHex: Cardano.PoolId.toKeyHash(certificate.poolId),
    stakeCredential: stakeCredentialMapper(certificate.stakeCredential, context!)
  },
  type: Ledger.CertificateType.STAKE_DELEGATION
});

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

const checkDrepPublicKeyAgainstCredential = (
  dRepKeyHashHex: Crypto.Ed25519KeyHashHex | undefined,
  hash: Crypto.Hash28ByteBase16
) => {
  if (!dRepKeyHashHex || dRepKeyHashHex !== Crypto.Ed25519KeyHashHex(hash)) {
    throw new InvalidArgumentError('certificate', 'dRepPublicKey does not match certificate drep credential.');
  }
};

const drepRegistrationCertificate: Transform<
  Cardano.RegisterDelegateRepresentativeCertificate | Cardano.UnRegisterDelegateRepresentativeCertificate,
  Ledger.Certificate,
  LedgerTxTransformerContext
> = (certificate, context): Ledger.Certificate => {
  if (!context) throw new InvalidArgumentError('LedgerTxTransformerContext', 'values was not provided');
  checkDrepPublicKeyAgainstCredential(context?.dRepKeyHashHex, certificate.dRepCredential.hash);

  const params: Ledger.DRepRegistrationParams = {
    ...mapAnchorToParams(certificate),
    dRepCredential: credentialMapper(
      certificate.dRepCredential,
      certificate.dRepCredential.type,
      util.accountKeyDerivationPathToBip32Path(context.accountIndex, util.DREP_KEY_DERIVATION_PATH)
    ),
    deposit: certificate.deposit
  };

  return {
    params,
    type:
      certificate.__typename === Cardano.CertificateType.RegisterDelegateRepresentative
        ? Ledger.CertificateType.DREP_REGISTRATION
        : Ledger.CertificateType.DREP_DEREGISTRATION
  };
};

const updateDRepCertificate: Transform<
  Cardano.UpdateDelegateRepresentativeCertificate,
  Ledger.Certificate,
  LedgerTxTransformerContext
> = (certificate, context): Ledger.Certificate => {
  if (!context) throw new InvalidArgumentError('LedgerTxTransformerContext', 'values was not provided');

  checkDrepPublicKeyAgainstCredential(context?.dRepKeyHashHex, certificate.dRepCredential.hash);

  const params: Ledger.DRepUpdateParams = {
    ...mapAnchorToParams(certificate),
    dRepCredential: credentialMapper(
      certificate.dRepCredential,
      certificate.dRepCredential.type,
      util.accountKeyDerivationPathToBip32Path(context.accountIndex, util.DREP_KEY_DERIVATION_PATH)
    )
  };

  return {
    params,
    type: Ledger.CertificateType.DREP_UPDATE
  };
};

const drepMapper = (drep: Cardano.DelegateRepresentative): Ledger.DRepParams => {
  if (Cardano.isDRepAlwaysAbstain(drep)) {
    return {
      type: Ledger.DRepParamsType.ABSTAIN
    };
  } else if (Cardano.isDRepAlwaysNoConfidence(drep)) {
    return {
      type: Ledger.DRepParamsType.NO_CONFIDENCE
    };
  } else if (Cardano.isDRepCredential(drep)) {
    return drepParamsMapper(drep, drep.type);
  }
  throw new Error('incorrect drep supplied');
};

export const voteDelegationCertificate: Transform<
  Cardano.VoteDelegationCertificate,
  Ledger.Certificate,
  LedgerTxTransformerContext
> = (certificate, context): Ledger.Certificate => ({
  params: {
    dRep: drepMapper(certificate.dRep),
    stakeCredential: stakeCredentialMapper(certificate.stakeCredential, context!)
  },
  type: Ledger.CertificateType.VOTE_DELEGATION
});

const toCert = (cert: Cardano.Certificate, context: LedgerTxTransformerContext): Ledger.Certificate => {
  switch (cert.__typename) {
    case Cardano.CertificateType.StakeRegistration:
      return getStakeAddressCertificate(cert, context);
    case Cardano.CertificateType.StakeDeregistration:
      return getStakeAddressCertificate(cert, context);
    case Cardano.CertificateType.StakeDelegation:
      return stakeDelegationCertificate(cert, context);
    case Cardano.CertificateType.PoolRegistration:
      return poolRegistrationCertificate(cert, context);
    case Cardano.CertificateType.PoolRetirement:
      return poolRetirementCertificate(cert, context);

    // Conway Era Certs
    case Cardano.CertificateType.Registration:
      return getNewStakeAddressCertificate(cert, context);
    case Cardano.CertificateType.Unregistration:
      return getNewStakeAddressCertificate(cert, context);
    case Cardano.CertificateType.VoteDelegation:
      return voteDelegationCertificate(cert, context);
    case Cardano.CertificateType.RegisterDelegateRepresentative:
      return drepRegistrationCertificate(cert, context);
    case Cardano.CertificateType.UnregisterDelegateRepresentative:
      return drepRegistrationCertificate(cert, context);
    case Cardano.CertificateType.UpdateDelegateRepresentative:
      return updateDRepCertificate(cert, context);
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
