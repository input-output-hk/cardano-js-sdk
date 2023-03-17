import { createProjection } from './utils';
import { withCertificates, withStakePools } from '../operators';

export const stakePools = createProjection((evt$) => evt$.pipe(withCertificates(), withStakePools()));

export type StakePoolsProjection = typeof stakePools;
