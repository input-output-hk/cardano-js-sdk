import { createProjection } from './utils';
import { withAdaHandle, withCertificates, withEpochNo } from '../operators';

export const adaHandles = createProjection((evt$) => evt$.pipe(withEpochNo(), withCertificates(), withAdaHandle()));

export type AdaHandleProjection = typeof adaHandles;
