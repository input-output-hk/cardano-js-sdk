import { createProjection } from './utils';
import { withCertificates, withStakeKeys } from '../operators';

export const stakeKeys = createProjection((evt$) => evt$.pipe(withCertificates(), withStakeKeys()));

export type StakeKeysProjection = typeof stakeKeys;
