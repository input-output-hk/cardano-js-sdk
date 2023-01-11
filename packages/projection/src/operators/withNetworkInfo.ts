import { Cardano, EraSummary } from '@cardano-sdk/core';
import { withStaticContext } from './withStaticContext';

export type WithNetworkInfo = {
  eraSummaries: EraSummary[];
  genesisParameters: Cardano.CompactGenesis;
};

export const withNetworkInfo = <RollForwardPropsIn, RollBackwardPropsIn>(networkInfo: WithNetworkInfo) =>
  withStaticContext<WithNetworkInfo, RollForwardPropsIn, RollBackwardPropsIn>({
    eraSummaries: networkInfo.eraSummaries,
    genesisParameters: networkInfo.genesisParameters
  });
