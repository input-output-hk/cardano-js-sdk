import { AllProjections } from '../../projections';
import { CommonSinkProps, GranularSink } from '../types';
import { UnifiedProjectorEvent } from '../../types';
import { WithInMemoryStore } from './types';
import { tap } from 'rxjs';

/**
 * Synchronous sink
 */
export const inMemorySink =
  <ProjectionId extends keyof AllProjections>(
    sink: (evt: UnifiedProjectorEvent<CommonSinkProps<Pick<AllProjections, ProjectionId>> & WithInMemoryStore>) => void
  ): GranularSink<ProjectionId, WithInMemoryStore> =>
  (evt$) =>
    evt$.pipe(tap(sink));
