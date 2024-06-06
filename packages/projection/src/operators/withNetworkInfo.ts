import { combineLatest, map, take } from 'rxjs';
import { withStaticContext } from './withStaticContext.js';
import type { ObservableCardanoNode } from '@cardano-sdk/core';
import type { WithNetworkInfo } from '../types.js';

export const withNetworkInfo = <RollForwardPropsIn, RollBackwardPropsIn>(
  cardanoNode: Pick<ObservableCardanoNode, 'eraSummaries$' | 'genesisParameters$'>
) =>
  withStaticContext<WithNetworkInfo, RollForwardPropsIn, RollBackwardPropsIn>(
    combineLatest([cardanoNode.genesisParameters$, cardanoNode.eraSummaries$]).pipe(
      map(([genesisParameters, eraSummaries]) => ({ eraSummaries, genesisParameters })),
      take(1)
    )
  );
