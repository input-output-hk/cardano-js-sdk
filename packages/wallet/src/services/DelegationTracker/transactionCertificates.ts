import { Cardano, util } from '@cardano-sdk/core';
import { Observable, distinctUntilChanged, map } from 'rxjs';
import { last } from 'lodash-es';
import { transactionsEquals } from '../util/equals';

export const RegAndDeregCertificateTypes = [
  Cardano.CertificateType.StakeKeyRegistration,
  Cardano.CertificateType.StakeKeyDeregistration
];

export const stakeKeyCertficates = (certificates?: Cardano.Certificate[]) =>
  certificates?.filter((certificate): certificate is Cardano.StakeAddressCertificate =>
    RegAndDeregCertificateTypes.includes(certificate.__typename)
  ) || [];

export const includesAnyCertificate = (haystack: Cardano.Certificate[], needle: Cardano.CertificateType[]) =>
  haystack.some(({ __typename }) => needle.includes(__typename)) || false;

export const transactionHasAnyCertificate = (
  { body: { certificates } }: Cardano.TxAlonzo,
  certificateTypes: Cardano.CertificateType[]
) => includesAnyCertificate(certificates || [], certificateTypes);

export const isLastStakeKeyCertOfType = (
  transactionsCertificates: Cardano.Certificate[][],
  certType: Cardano.CertificateType.StakeKeyRegistration | Cardano.CertificateType.StakeKeyDeregistration,
  rewardAccount?: Cardano.RewardAccount
) => {
  const lastRegOrDereg = last(
    transactionsCertificates
      .map((certificates) => {
        const allStakeKeyCertificates = stakeKeyCertficates(certificates);
        const addressStakeKeyCertificates = rewardAccount
          ? allStakeKeyCertificates.filter(({ rewardAccount: address }) => rewardAccount === address)
          : allStakeKeyCertificates;
        return last(addressStakeKeyCertificates);
      })
      .filter(util.isNotNil)
  );
  return lastRegOrDereg?.__typename === certType;
};

export const transactionsWithCertificates = (
  transactions$: Observable<Cardano.TxAlonzo[]>,
  certificateTypes: Cardano.CertificateType[]
) =>
  transactions$.pipe(
    map((transactions) => transactions.filter((tx) => transactionHasAnyCertificate(tx, certificateTypes))),
    distinctUntilChanged(transactionsEquals)
  );
