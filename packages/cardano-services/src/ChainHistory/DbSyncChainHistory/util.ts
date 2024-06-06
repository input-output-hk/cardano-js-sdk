import type { Cardano, PaginationArgs } from '@cardano-sdk/core';
import type {
  CertificateModel,
  DelegationCertModel,
  MirCertModel,
  PoolRegisterCertModel,
  PoolRetireCertModel,
  StakeCertModel,
  WithCertType
} from './types.js';

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

export const applyPagination = (ids: Cardano.TransactionId[], { startAt, limit }: PaginationArgs) =>
  ids.slice(startAt).slice(0, limit);
