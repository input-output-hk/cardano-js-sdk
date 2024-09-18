import {
  AuthorizeCommitteeHotCertModel,
  CertificateModel,
  DelegationCertModel,
  DrepCertModel,
  MirCertModel,
  PoolRegisterCertModel,
  PoolRetireCertModel,
  ResignCommitteeColdCertModel,
  StakeCertModel,
  StakeRegistrationDelegationCertModel,
  StakeVoteDelegationCertModel,
  StakeVoteRegistrationDelegationCertModel,
  VoteDelegationCertModel,
  VoteRegistrationDelegationCertModel,
  WithCertType
} from './types';
import { Cardano, PaginationArgs } from '@cardano-sdk/core';

export const isPoolRetireCertModel = (
  value: WithCertType<CertificateModel>
): value is WithCertType<PoolRetireCertModel> => value.type === 'retire';

export const isPoolRegisterCertModel = (
  value: WithCertType<CertificateModel>
): value is WithCertType<PoolRegisterCertModel> => value.type === 'register';

export const isMirCertModel = (value: WithCertType<CertificateModel>): value is WithCertType<MirCertModel> =>
  value.type === 'mir';

export const isStakeCertModel = (value: WithCertType<CertificateModel>): value is WithCertType<StakeCertModel> =>
  value.type === 'stake';

export const isDelegationCertModel = (
  value: WithCertType<CertificateModel>
): value is WithCertType<DelegationCertModel> => value.type === 'delegation';

export const isDrepRegistrationCertModel = (
  value: WithCertType<CertificateModel>
): value is WithCertType<DrepCertModel> => value.type === 'registerDrep';

export const isDrepUnregistrationCertModel = (
  value: WithCertType<CertificateModel>
): value is WithCertType<DrepCertModel> => value.type === 'unregisterDrep';

export const isUpdateDrepCertModel = (value: WithCertType<CertificateModel>): value is WithCertType<DrepCertModel> =>
  value.type === 'updateDrep';

export const isVoteDelegationCertModel = (
  value: WithCertType<CertificateModel>
): value is WithCertType<VoteDelegationCertModel> => value.type === 'voteDelegation';

export const isVoteRegistrationDelegationCertModel = (
  value: WithCertType<CertificateModel>
): value is WithCertType<VoteRegistrationDelegationCertModel> => value.type === 'voteRegistrationDelegation';

export const isStakeVoteDelegationCertModel = (
  value: WithCertType<CertificateModel>
): value is WithCertType<StakeVoteDelegationCertModel> => value.type === 'stakeVoteDelegation';

export const isStakeRegistrationDelegationCertModel = (
  value: WithCertType<CertificateModel>
): value is WithCertType<StakeRegistrationDelegationCertModel> => value.type === 'stakeRegistrationDelegation';

export const isStakeVoteRegistrationDelegationCertModel = (
  value: WithCertType<CertificateModel>
): value is WithCertType<StakeVoteRegistrationDelegationCertModel> => value.type === 'stakeVoteRegistrationDelegation';

export const isAuthorizeCommitteeHotCertModel = (
  value: WithCertType<CertificateModel>
): value is WithCertType<AuthorizeCommitteeHotCertModel> => value.type === 'authorizeCommitteeHot';

export const isResignCommitteeColdCertModel = (
  value: WithCertType<CertificateModel>
): value is WithCertType<ResignCommitteeColdCertModel> => value.type === 'resignCommitteeCold';

export const applyPagination = (ids: Cardano.TransactionId[], { startAt, limit }: PaginationArgs) =>
  ids.slice(startAt).slice(0, limit);

/**
 * Extracts the array of _compound certificates_ given two arrays of _base certificates_.
 *
 * Since **db-sync** projects _compound certificates_ as the result of the _split_ of relevant certificate properties
 * in the tables dedicated to _base certificates_, in order to reduce the number and the complexity of SQL queries
 * performed by `queryCertificatesByIds`, we perform only simple direct queries in the tables dedicated to _base
 * certificates_.
 *
 * Example: given an array of `reg_cert` and an array of `vote_deleg_cert`, the result is an array of:
 * - all input `reg_cert` which can be neither `vote_reg_deleg_cert` nor `stake_vote_reg_deleg_cert`,
 * - all input `vote_deleg_cert` which can be neither `vote_reg_deleg_cert` nor `stake_vote_reg_deleg_cert`,
 * - the array of `vote_reg_deleg_cert` (it includes also the partials `stake_vote_reg_deleg_cert`)
 *
 * @param certs1 the first certificates array
 * @param certs2 the second certificates array
 * @returns the array of: first certificates array, second certificates array, compound certificates array
 */
export const extractCompoundCertificates = <T1 extends CertificateModel, T2 extends CertificateModel>(
  certs1: T1[],
  certs2: T2[]
) => {
  const result1: T1[] = [];
  const result: (T1 & T2)[] = [];
  const foundIndexes2: number[] = [];

  for (const c1 of certs1) {
    const c2index = certs2.findIndex(
      (c2) => c1.cert_index === c2.cert_index && c1.tx_id.toString() === c2.tx_id.toString()
    );

    if (c2index === -1) result1.push(c1);
    else {
      foundIndexes2.push(c2index);
      result.push({ ...c1, ...certs2[c2index] });
    }
  }

  const result2 = certs2.filter((_, c2index) => !foundIndexes2.includes(c2index));

  return [result1, result2, result] as const;
};
