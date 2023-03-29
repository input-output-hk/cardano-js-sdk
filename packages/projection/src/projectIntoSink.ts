import { NoExtraProperties } from '@cardano-sdk/util';
import { ProjectionSource } from './bootstrap';
import { Sink } from './sinks';
import { applyProjections } from './applyProjections';
import { tap } from 'rxjs';

export interface ProjectIntoSinkProps<S extends {}, P extends Partial<S>> {
  projections: NoExtraProperties<S, P>;
  sink: Sink<S>;
}

/**
 * Applies projection and sink operators.
 * Ensures declared sink compatibility with projections.
 * Calls `evt.requestNext` after each event is applied to sink.
 */
export const projectIntoSink =
  <S extends {}, P extends Partial<S>>({ projections, sink }: ProjectIntoSinkProps<S, P>) =>
  (evt$: ProjectionSource) =>
    evt$.pipe(
      applyProjections(projections),
      sink(projections),
      tap((evt) => evt.requestNext())
    );
