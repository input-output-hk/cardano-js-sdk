import { ProjectionsEvent } from '../projections';
import { UnifiedProjectorObservable } from '../types';

export type ProjectionSource = UnifiedProjectorObservable<ProjectionsEvent<{}>>;
