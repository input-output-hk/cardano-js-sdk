import { createProjection } from './utils';
import { withCertificates, withStakePools } from '../operators';

export const stakePools = createProjection((evt$) => evt$.pipe(withCertificates(), withStakePools()));
export const stakePoolMetadata = stakePools;
export const stakePoolMetrics = stakePools;

export type StakePoolsProjection = typeof stakePools;
