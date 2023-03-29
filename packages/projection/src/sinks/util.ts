import { AllProjections } from '../projections';
import { GranularSink, SinkObservable } from './types';

export const applySinksSerially =
  <ExtraContext>() =>
  <Projections extends {}>(
    projections: Projections,
    sinks: Array<{
      id: keyof Projections;
      sink: GranularSink<keyof AllProjections, ExtraContext>;
    }>
  ) =>
  (evt$: SinkObservable<Projections, ExtraContext>) => {
    const selectedSinks = sinks.filter(({ id }) => id in projections).map(({ sink }) => sink);
    // eslint-disable-next-line prefer-spread, @typescript-eslint/no-explicit-any
    return evt$.pipe.apply(evt$, selectedSinks as any) as SinkObservable<Projections, ExtraContext>;
  };
