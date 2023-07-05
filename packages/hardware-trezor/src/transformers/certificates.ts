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

const stakeDelegationCertificate = (
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

const toCert = (cert: Cardano.Certificate, context: TrezorTxTransformerContext) => {
  switch (cert.__typename) {
    case Cardano.CertificateType.StakeKeyRegistration:
      return getStakeAddressCertificate(cert, context, Trezor.CardanoCertificateType.STAKE_REGISTRATION);
    case Cardano.CertificateType.StakeKeyDeregistration:
      return getStakeAddressCertificate(cert, context, Trezor.CardanoCertificateType.STAKE_DEREGISTRATION);
    case Cardano.CertificateType.StakeDelegation:
      return stakeDelegationCertificate(cert, context);
    default:
      throw new InvalidArgumentError('cert', `Certificate ${cert.__typename} not supported.`);
  }
};

export const mapCerts = (
  certs: Cardano.Certificate[],
  context: TrezorTxTransformerContext
): Trezor.CardanoCertificate[] => certs.map((coreCert) => toCert(coreCert, context));
