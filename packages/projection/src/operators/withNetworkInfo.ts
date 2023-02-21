import { Cardano, EraSummary, ObservableCardanoNode } from '@cardano-sdk/core';
import { combineLatest, map, take } from 'rxjs';
import { withStaticContext } from './withStaticContext';

export type WithNetworkInfo = {
  eraSummaries: EraSummary[];
  genesisParameters: Cardano.CompactGenesis;
};

export const withNetworkInfo = <RollForwardPropsIn, RollBackwardPropsIn>(
  cardanoNode: Pick<ObservableCardanoNode, 'eraSummaries$' | 'genesisParameters$'>
) =>
  withStaticContext<WithNetworkInfo, RollForwardPropsIn, RollBackwardPropsIn>(
    combineLatest([cardanoNode.genesisParameters$, cardanoNode.eraSummaries$]).pipe(
      map(([genesisParameters, eraSummaries]) => ({ eraSummaries, genesisParameters })),
      take(1)
    )
  );
