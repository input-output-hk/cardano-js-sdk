import { distinctUntilChanged, map } from 'rxjs';
import { eraSummariesEquals } from './equals.js';
import type { Cardano, EraSummary } from '@cardano-sdk/core';
import type { Observable } from 'rxjs';

export const distinctBlock = (tip$: Observable<Cardano.Tip>) =>
  tip$.pipe(
    map(({ blockNo }) => blockNo),
    distinctUntilChanged()
  );

export const distinctEraSummaries = (eraSummaries$: Observable<EraSummary[]>) =>
  eraSummaries$.pipe(
    map((eraSummaries) => eraSummaries),
    distinctUntilChanged(eraSummariesEquals)
  );
