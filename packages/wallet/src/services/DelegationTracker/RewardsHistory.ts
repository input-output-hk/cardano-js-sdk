import { BigIntMath, Cardano, EpochRewards, RewardHistoryProps, WalletProvider } from '@cardano-sdk/core';
import { KeyManagement, ProviderWithArg, Transactions } from '../..';
import { certificateTransactions } from './util';
import { filter, from, map, mergeMap, take } from 'rxjs';

interface RewardsHistoryProviderInternals {
  getRewardsHistory?: ProviderWithArg<EpochRewards[], RewardHistoryProps>;
}

export const getEpoch = (slotNo: number) => {
  // Review: we should probably be getting these constants from the provider?
  // Ogmios CompactGenesis only includes current epoch length,
  // and this code needs to know the ranges for all historical lengths
  const byronSlotLength = 21_600;
  const shelleyStartEpoch = 208;
  const shelleySlotStart = 4_492_800;
  const shelleySlotLength = 432_000;
  if (slotNo >= shelleySlotLength) {
    return Math.floor((slotNo - shelleySlotStart) / shelleySlotLength) + shelleyStartEpoch;
  }
  return shelleyStartEpoch - Math.ceil((shelleySlotStart - slotNo) / byronSlotLength);
};

export const createRewardsHistoryProvider = (
  walletProvider: WalletProvider,
  keyManager: KeyManagement.KeyManager,
  transactionsTracker: Transactions,
  { getRewardsHistory = (props) => from(walletProvider.rewardsHistory(props)) }: RewardsHistoryProviderInternals = {}
) => {
  const firstDelegationEpoch$ = certificateTransactions(transactionsTracker, [
    Cardano.CertificateType.StakeDelegation
  ]).pipe(
    map((transactions) => Math.min(...transactions.map(({ blockHeader: { slot } }) => slot))),
    map(getEpoch),
    take(1)
  );
  return () =>
    firstDelegationEpoch$.pipe(
      mergeMap((fromEpoch) =>
        getRewardsHistory({
          epochs: { lowerBound: fromEpoch },
          stakeAddresses: [keyManager.stakeKey.to_bech32()]
        })
      ),
      filter((rewards) => rewards.length > 0),
      map((all) => {
        const lifetimeRewards = BigIntMath.sum(all.map(({ rewards }) => rewards));
        return {
          all,
          avgReward: lifetimeRewards / BigInt(all.length),
          lastReward: all[all.length - 1],
          lifetimeRewards
        };
      })
    );
};
