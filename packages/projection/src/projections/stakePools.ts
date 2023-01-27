import { createProjection } from './utils';
import { withCertificates, withEpochNo, withStakePools } from '../operators';

export const stakePools = createProjection((evt$) => evt$.pipe(withEpochNo(), withCertificates(), withStakePools()));

export type StakePoolsProjection = typeof stakePools;
