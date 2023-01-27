import { ProjectorOperator } from './types';
import uniq from 'lodash/uniq';

// eslint-disable-next-line @typescript-eslint/no-explicit-any
export const combineProjections = <P extends object>(projections: P): ProjectorOperator<any, any, any, any>[] =>
  uniq(Object.values(projections).flat());
