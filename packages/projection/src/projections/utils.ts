import { Projection } from './types';
import { ProjectorObservable, UnifiedProjectorObservable } from '../types';
import { WithNetworkInfo } from '../operators';

export const createProjection = <ExtraPropsOut>(
  projection: (evt$: UnifiedProjectorObservable<WithNetworkInfo>) => ProjectorObservable<ExtraPropsOut>
) => {
  let operators: Projection<ExtraPropsOut>;
  const operatorCollector = {
    pipe: (...args: Projection<ExtraPropsOut>) => (operators = args)
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
  } as any;
  projection(operatorCollector);
  return operators!;
};

export type CreateProjection = ReturnType<typeof createProjection>;
