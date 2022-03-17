import { Cardano, EpochRewards } from '@cardano-sdk/core';
import {
  // eslint-disable-next-line @typescript-eslint/ban-ts-comment
  // @ts-ignore
  WalletProviderStub,
  blocksByHashes,
  epochRewards,
  genesisParameters,
  ledgerTip,
  networkInfo,
  protocolParameters,
  queryTransactionsResult,
  rewardAccount,
  rewards,
  stakePoolStats,
  utxo
} from './mockWalletProvider';
import delay from 'delay';

export const protocolParameters2 = {
  ...protocolParameters,
  maxCollateralInputs: protocolParameters.maxCollateralInputs + 1
};

export const genesisParameters2 = {
  ...genesisParameters,
  maxLovelaceSupply: genesisParameters.maxLovelaceSupply + 1n
};

export const ledgerTip2 = {
  ...ledgerTip,
  blockNo: ledgerTip.blockNo + 1
};

export const currentEpochNo2 = networkInfo.currentEpoch.number + 1;
export const networkInfo2 = {
  ...networkInfo,
  currentEpoch: {
    ...networkInfo.currentEpoch,
    number: currentEpochNo2
  }
};

export const queryTransactionsResult2 = [
  ...queryTransactionsResult,
  {
    ...queryTransactionsResult[1],
    blockHeader: {
      blockNo: 10_150,
      slot: ledgerTip.slot - 50_000
    },
    id: Cardano.TransactionId('6804edf9712d2b619edb6ac86861fe93a730693183a262b165fcc1ba1bc99caa')
  }
];

export const rewardsHistory2 = new Map<Cardano.RewardAccount, EpochRewards[]>();
rewardsHistory2.set(rewardAccount, [
  {
    epoch: currentEpochNo2 - 5,
    rewards: 10_000n
  },
  ...epochRewards
]);

export const stakePoolStats2 = {
  ...stakePoolStats,
  qty: {
    ...stakePoolStats.qty,
    active: stakePoolStats.qty.active + 1
  }
};

export const utxo2 = utxo.slice(1);
export const delegate2 = 'pool167u07rzwu6dr40hx2pr4vh592vxp4zen9ct2p3h84wzqzv6fkgv';
export const rewards2 = rewards + 1n;
export const delegationAndRewards2 = { delegate: delegate2, rewards: rewards2 };

/**
 * A different provider stub for testing, supports delay to simulate network requests.
 *
 * @returns {WalletProviderStub} that returns data that is slightly different to mockWalletProvider.
 */
export const mockWalletProvider2 = (delayMs: number) => {
  const delayedJestFn = <T>(resolvedValue: T) =>
    jest.fn().mockImplementation(() => delay(delayMs).then(() => resolvedValue));

  return {
    currentWalletProtocolParameters: delayedJestFn(protocolParameters2),
    genesisParameters: delayedJestFn(genesisParameters2),
    ledgerTip: delayedJestFn(ledgerTip2),
    networkInfo: delayedJestFn(networkInfo2),
    queryBlocksByHashes: delayedJestFn(blocksByHashes),
    queryTransactionsByAddresses: delayedJestFn(queryTransactionsResult2),
    queryTransactionsByHashes: delayedJestFn(queryTransactionsResult2),
    rewardsHistory: delayedJestFn(rewardsHistory2),
    stakePoolStats: delayedJestFn(stakePoolStats2),
    utxoDelegationAndRewards: delayedJestFn({ delegationAndRewards: delegationAndRewards2, utxo: utxo2 })
  };
};
