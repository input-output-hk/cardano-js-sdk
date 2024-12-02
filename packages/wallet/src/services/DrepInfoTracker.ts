import { Cardano, DRepInfo, DRepProvider } from '@cardano-sdk/core';
import { Logger } from 'ts-log';
import { Observable, map, merge, of, withLatestFrom } from 'rxjs';
import { RetryBackoffConfig } from 'backoff-rxjs';
import { coldObservableProvider } from '@cardano-sdk/util-rxjs';
import { distinctBlock } from './util';
import { isNotNil } from '@cardano-sdk/util';

type DrepInfoObservableProps = {
  drepProvider: DRepProvider;
  logger: Logger;
  retryBackoffConfig: RetryBackoffConfig;
  refetchTrigger$: Observable<void>;
};

/** Use DRepProvider to fetch DRepInfos with retry backoff logic */
export const createDrepInfoColdObservable =
  ({ drepProvider, retryBackoffConfig, refetchTrigger$ }: DrepInfoObservableProps) =>
  (drepIds: Cardano.DRepID[]) =>
    coldObservableProvider<DRepInfo[]>({
      provider: () => drepProvider.getDRepsInfo({ ids: drepIds }),
      retryBackoffConfig,
      trigger$: merge(of(true), refetchTrigger$)
    });

/** Replaces drep credential entries with DrepInfo. Undefined if drep not found in drepInfo */
export const drepsToDelegatees =
  (dreps: (Cardano.DelegateRepresentative | undefined)[]) =>
  (drepInfos: DRepInfo[]): (Cardano.DRepDelegatee | undefined)[] =>
    dreps.map((drep) => {
      if (!drep) {
        return;
      }
      if (Cardano.isDRepCredential(drep)) {
        const drepInfo = drepInfos.find(
          (info) => Cardano.DRepID.toCip129DRepID(info.id) === Cardano.DRepID.cip129FromCredential(drep)
        );
        if (!drepInfo) {
          // DRep not found, assume it's inactive
          return;
        }
        return { delegateRepresentative: drepInfo };
      }
      return { delegateRepresentative: drep };
    });

/** Removes undefined, AlwaysAbstain and AlwaysNoConfidence, removes duplicates and maps to DRepID[] */
export const drepsToDrepIds = (dreps: Array<Cardano.DelegateRepresentative | undefined>): Cardano.DRepID[] => [
  ...new Set<Cardano.DRepID>(
    dreps
      .filter(isNotNil)
      .filter(Cardano.isDRepCredential)
      .map((drepCredential) => Cardano.DRepID.cip129FromCredential(drepCredential))
  )
];

export const onlyDistinctBlockRefetch = (
  refetchTrigger$: Observable<void>,
  tip$: Observable<Pick<Cardano.PartialBlockHeader, 'blockNo'>>
): Observable<void> =>
  distinctBlock(
    refetchTrigger$.pipe(
      withLatestFrom(tip$),
      map(([, tip]) => tip)
    )
  ).pipe(map(() => void 0));
