import { Intersection, createSlotEpochCalc } from '@cardano-sdk/core';
import { ProjectorOperator } from '../types';
import { WithEpochNo } from './withEpochNo';
import { WithNetworkInfo } from './withNetworkInfo';
import { map, pairwise, startWith } from 'rxjs';

export type WithEpochBoundary = { crossEpochBoundary: boolean };
type PropsIn = WithEpochNo & WithNetworkInfo;

/**
 * Adds an `crossEpochBoundary` boolean to each event.
 * `true` if it's the
 * - 1st block of new epoch on RollForward (exception: 0th epoch)
 * - last block of previous epoch on RollBackward
 */
export const withEpochBoundary =
  <ExtraRollForwardPropsIn extends PropsIn, ExtraRollBackwardPropsIn extends PropsIn>(
    intersection: Pick<Intersection, 'point'>
  ): ProjectorOperator<ExtraRollForwardPropsIn, ExtraRollBackwardPropsIn, WithEpochBoundary, WithEpochBoundary> =>
  (evt$) =>
    evt$.pipe(
      startWith(null),
      pairwise(),
      map(([prevEvt, evt]) => {
        const prevEpoch =
          prevEvt?.epochNo ||
          (intersection.point === 'origin' ? 0 : createSlotEpochCalc(evt!.eraSummaries)(intersection.point.slot));
        return {
          ...evt!,
          crossEpochBoundary: prevEpoch !== evt?.epochNo
        };
      })
    );
