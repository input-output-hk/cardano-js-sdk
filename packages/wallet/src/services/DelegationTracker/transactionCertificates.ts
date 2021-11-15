import { Cardano, util } from '@cardano-sdk/core';
import { Transactions } from '../types';
import { TxBodyAlonzo } from '@cardano-sdk/core/src/Cardano';
import { distinctUntilChanged, map } from 'rxjs';
import { last } from 'lodash-es';
import { transactionsEquals } from '../util/equals';

export const RegAndDeregCertificateTypes = [
  Cardano.CertificateType.StakeRegistration,
  Cardano.CertificateType.StakeDeregistration
];

export const transactionStakeKeyCertficates = (body: TxBodyAlonzo) =>
  (body.certificates || []).filter((certificate): certificate is Cardano.StakeAddressCertificate =>
    RegAndDeregCertificateTypes.includes(certificate.__typename)
  );

export const transactionHasAnyCertificate = (
  { body: { certificates } }: Cardano.TxAlonzo,
  certificateTypes: Cardano.CertificateType[]
) => certificates?.some(({ __typename }) => certificateTypes.includes(__typename)) || false;

export const isLastStakeKeyCertOfType = (
  transactions: { body: TxBodyAlonzo }[],
  certType: Cardano.CertificateType.StakeRegistration | Cardano.CertificateType.StakeDeregistration,
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
  transactionsTracker: Transactions,
  certificateTypes: Cardano.CertificateType[]
) =>
  transactionsTracker.history.outgoing$.pipe(
    map((transactions) => transactions.filter((tx) => transactionHasAnyCertificate(tx, certificateTypes))),
    distinctUntilChanged(transactionsEquals)
  );
