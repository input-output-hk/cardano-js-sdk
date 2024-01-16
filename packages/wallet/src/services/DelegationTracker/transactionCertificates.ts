import * as Crypto from '@cardano-sdk/crypto';
import { Cardano, getCertificatesByType } from '@cardano-sdk/core';
import { Observable, combineLatest, distinctUntilChanged, map } from 'rxjs';
import { isNotNil } from '@cardano-sdk/util';
import { transactionsEquals } from '../util/equals';
import last from 'lodash/last';

export const RegAndDeregCertificateTypes = [
  Cardano.CertificateType.StakeRegistration,
  Cardano.CertificateType.StakeDeregistration
];

export const stakeKeyCertficates = (certificates?: Cardano.Certificate[]) =>
  certificates?.filter((certificate): certificate is Cardano.StakeAddressCertificate =>
    RegAndDeregCertificateTypes.includes(certificate.__typename)
  ) || [];

export const includesAnyCertificate = (haystack: Cardano.Certificate[], needle: Cardano.CertificateType[]) =>
  haystack.some(({ __typename }) => needle.includes(__typename)) || false;

export const isLastStakeKeyCertOfType = (
  transactionsCertificates: Cardano.Certificate[][],
  certType: Cardano.CertificateType.StakeRegistration | Cardano.CertificateType.StakeDeregistration,
  rewardAccount?: Cardano.RewardAccount
) => {
  const stakeKeyHash = rewardAccount
    ? Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(Cardano.RewardAccount.toHash(rewardAccount))
    : null;
  const lastRegOrDereg = last(
    transactionsCertificates
      .map((certificates) => {
        const allStakeKeyCertificates = stakeKeyCertficates(certificates);
        const addressStakeKeyCertificates = stakeKeyHash
          ? allStakeKeyCertificates.filter(({ stakeCredential: certStakeCred }) => stakeKeyHash === certStakeCred.hash)
          : allStakeKeyCertificates;
        return last(addressStakeKeyCertificates);
      })
      .filter(isNotNil)
  );
  return lastRegOrDereg?.__typename === certType;
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
