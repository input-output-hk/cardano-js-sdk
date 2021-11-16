import { Cardano, util } from '@cardano-sdk/core';
import { TransactionsTracker } from '../types';
import { distinctUntilChanged, map } from 'rxjs';
import { last } from 'lodash-es';
import { transactionsEquals } from '../util/equals';

export const RegAndDeregCertificateTypes = [
  Cardano.CertificateType.StakeKeyRegistration,
  Cardano.CertificateType.StakeKeyDeregistration
];

export const transactionStakeKeyCertficates = (body: Cardano.TxBodyAlonzo) =>
  (body.certificates || []).filter((certificate): certificate is Cardano.StakeAddressCertificate =>
    RegAndDeregCertificateTypes.includes(certificate.__typename)
  );

export const transactionHasAnyCertificate = (
  { body: { certificates } }: Cardano.TxAlonzo,
  certificateTypes: Cardano.CertificateType[]
) => certificates?.some(({ __typename }) => certificateTypes.includes(__typename)) || false;

export const isLastStakeKeyCertOfType = (
  transactions: { body: Cardano.TxBodyAlonzo }[],
  certType: Cardano.CertificateType.StakeKeyRegistration | Cardano.CertificateType.StakeKeyDeregistration,
  rewardAccount?: Cardano.Address
) => {
  const lastRegOrDereg = last(
    transactions
      .map(({ body }) => {
        const allStakeKeyCertificates = transactionStakeKeyCertficates(body);
        const addressStakeKeyCertificates = rewardAccount
          ? allStakeKeyCertificates.filter(({ address }) => rewardAccount === address)
          : allStakeKeyCertificates;
        return last(addressStakeKeyCertificates);
      })
      .filter(util.isNotNil)
  );
  return lastRegOrDereg?.__typename === certType;
};

export const outgoingTransactionsWithCertificates = (
  transactionsTracker: TransactionsTracker,
  certificateTypes: Cardano.CertificateType[]
) =>
  transactionsTracker.history.outgoing$.pipe(
    map((transactions) => transactions.filter((tx) => transactionHasAnyCertificate(tx, certificateTypes))),
    distinctUntilChanged(transactionsEquals)
  );
