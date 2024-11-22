import { Cardano, EraSummary } from '@cardano-sdk/core';
import { Observable, distinctUntilChanged, map } from 'rxjs';
import { eraSummariesEquals } from './equals';

export const distinctBlock = (tip$: Observable<Pick<Cardano.Tip, 'blockNo'>>) =>
  tip$.pipe(
    map(({ blockNo }) => blockNo),
    distinctUntilChanged()
  );

export const distinctEraSummaries = (eraSummaries$: Observable<EraSummary[]>) =>
  eraSummaries$.pipe(
    map((eraSummaries) => eraSummaries),
    distinctUntilChanged(eraSummariesEquals)
  );
