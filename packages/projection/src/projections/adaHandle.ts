import { createProjection } from './utils';
import { withAdaHandle, withCertificates } from '../operators';

export const adaHandles = createProjection((evt$) => evt$.pipe(withCertificates(), withAdaHandle()));

export type AdaHandleProjection = typeof adaHandles;
