import {
  GenesisKeyDelegationCertificate,
  MirCertificate,
  PoolRegistrationCertificate,
  PoolRetirementCertificate,
  StakeDelegationCertificate,
  StakeKeyDeregistrationCertificate,
  StakeKeyRegistrationCertificate
} from './Certificate';
import { createUnionType } from 'type-graphql';

export const Certificate = createUnionType({
  name: 'Certificate',
  types: () =>
    [
      MirCertificate,
      GenesisKeyDelegationCertificate,
      PoolRegistrationCertificate,
      PoolRetirementCertificate,
      StakeDelegationCertificate,
      StakeKeyDeregistrationCertificate,
      StakeKeyRegistrationCertificate
    ] as const
});
