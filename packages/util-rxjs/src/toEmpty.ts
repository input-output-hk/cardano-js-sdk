import { EMPTY, mergeMap } from 'rxjs';

export const toEmpty = mergeMap(() => EMPTY);
