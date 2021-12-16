import { ProviderError, ProviderFailure, WalletProvider } from '@cardano-sdk/core';
import { WalletProviderFnProps } from './WalletProviderFnProps';

export const networkInfoProvider =
  ({ getExactlyOneObject, sdk }: WalletProviderFnProps): WalletProvider['networkInfo'] =>
  async () => {
    const { queryAda, queryBlock, queryTimeSettings } = await sdk.NetworkInfo();
    const { supply } = getExactlyOneObject(queryAda, 'Ada');
    const {
      totalLiveStake,
      epoch: {
        number: currentEpochNumber,
        startedAt: { date: epochStartedAt },
        activeStakeAggregate
      }
    } = getExactlyOneObject(queryBlock, 'Block');
    const { epochLength, slotLength } = getExactlyOneObject(queryTimeSettings, 'TimeSettings');
    const activeStake = activeStakeAggregate?.quantitySum;
    if (!activeStake) {
      throw new ProviderError(
        ProviderFailure.InvalidResponse,
        null,
        'No active stake on epoch. Chain sync in progress?'
      );
    }
    const epochStartedAtDate = new Date(epochStartedAt);
    const epochEndDate = new Date(epochStartedAtDate.getTime() + epochLength * slotLength * 1000);
    return {
      currentEpoch: {
        end: { date: epochEndDate },
        number: currentEpochNumber,
        start: { date: epochStartedAtDate }
      },
      lovelaceSupply: {
        circulating: BigInt(supply.circulating),
        max: BigInt(supply.max),
        total: BigInt(supply.total)
      },
      stake: {
        active: activeStake,
        live: totalLiveStake
      }
    };
  };
