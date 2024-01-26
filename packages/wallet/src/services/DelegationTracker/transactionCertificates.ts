import * as Crypto from '@cardano-sdk/crypto';
import { Cardano, getCertificatesByType } from '@cardano-sdk/core';
import { Observable, combineLatest, distinctUntilChanged, map } from 'rxjs';
import { isNotNil } from '@cardano-sdk/util';
import { transactionsEquals } from '../util/equals';
import last from 'lodash/last';

export const StakeRegistrationCertificateTypes = [
  Cardano.CertificateType.StakeRegistration,
  Cardano.CertificateType.Registration,
  Cardano.CertificateType.VoteRegistrationDelegation,
  Cardano.CertificateType.StakeRegistrationDelegation,
  Cardano.CertificateType.StakeVoteRegistrationDelegation
] as const;

export type StakeRegistrationCertificateTypes = typeof StakeRegistrationCertificateTypes[number];

export type StakeDelegationCertificateUnion =
  | Cardano.StakeDelegationCertificate
  | Cardano.StakeVoteDelegationCertificate
  | Cardano.StakeRegistrationDelegationCertificate
  | Cardano.StakeVoteRegistrationDelegationCertificate;

export const StakeDelegationCertificateTypes = [
  Cardano.CertificateType.StakeDelegation,
  Cardano.CertificateType.StakeVoteDelegation,
  Cardano.CertificateType.StakeRegistrationDelegation,
  Cardano.CertificateType.StakeVoteRegistrationDelegation
] as const;

export type StakeDelegationCertificateTypes = typeof StakeDelegationCertificateTypes[number];

export type RegAndDeregCertificateUnion =
  | Cardano.StakeAddressCertificate
  | Cardano.NewStakeAddressCertificate
  | Cardano.VoteRegistrationDelegationCertificate
  | Cardano.StakeRegistrationDelegationCertificate
  | Cardano.StakeVoteRegistrationDelegationCertificate;

export const RegAndDeregCertificateTypes = [
  ...StakeRegistrationCertificateTypes,
  Cardano.CertificateType.Unregistration,
  Cardano.CertificateType.StakeDeregistration
] as const;

export type RegAndDeregCertificateTypes = typeof RegAndDeregCertificateTypes[number];

/** Filters certificates, returning only stake key register/deregister certificates */
export const stakeKeyCertificates = (certificates?: Cardano.Certificate[]) =>
  certificates?.filter((certificate): certificate is RegAndDeregCertificateUnion =>
    RegAndDeregCertificateTypes.includes(certificate.__typename as RegAndDeregCertificateTypes)
  ) || [];

export const includesAnyCertificate = (haystack: Cardano.Certificate[], needle: readonly Cardano.CertificateType[]) =>
  haystack.some(({ __typename }) => needle.includes(__typename)) || false;

export const isLastStakeKeyCertOfType = (
  transactionsCertificates: Cardano.Certificate[][],
  certTypes: readonly RegAndDeregCertificateTypes[],
  rewardAccount?: Cardano.RewardAccount
) => {
  const stakeKeyHash = rewardAccount
    ? Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(Cardano.RewardAccount.toHash(rewardAccount))
    : null;
  const lastRegOrDereg = last(
    transactionsCertificates
      .map((certificates) => {
        const allStakeKeyCertificates = stakeKeyCertificates(certificates);
        const addressStakeKeyCertificates = stakeKeyHash
          ? allStakeKeyCertificates.filter(({ stakeCredential: certStakeCred }) => stakeKeyHash === certStakeCred.hash)
          : allStakeKeyCertificates;
        return last(addressStakeKeyCertificates);
      })
      .filter(isNotNil)
  );
  return certTypes.includes(lastRegOrDereg?.__typename as RegAndDeregCertificateTypes);
};

export const transactionsWithCertificates = (
  transactions$: Observable<Cardano.HydratedTx[]>,
  rewardAccounts$: Observable<Cardano.RewardAccount[]>,
  certificateTypes: Cardano.CertificateType[]
) =>
  combineLatest([transactions$, rewardAccounts$]).pipe(
    map(([transactions, rewardAccounts]) =>
      transactions.filter((tx) => getCertificatesByType(tx, rewardAccounts, certificateTypes).length > 0)
    ),
    distinctUntilChanged(transactionsEquals)
  );
