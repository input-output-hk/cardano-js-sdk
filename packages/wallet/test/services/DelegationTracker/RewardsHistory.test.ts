/* eslint-disable unicorn/no-useless-undefined */
import * as Crypto from '@cardano-sdk/crypto';
import { Cardano } from '@cardano-sdk/core';
import { InMemoryRewardsHistoryStore } from '../../../src/persistence';
import {
  RewardsHistory,
  RewardsHistoryProvider,
  TrackedRewardsProvider,
  calcFirstDelegationEpoch,
  createRewardsHistoryProvider,
  createRewardsHistoryTracker
} from '../../../src/services';
import { createStubTxWithCertificates } from './stub-tx';
import { createTestScheduler, mockProviders } from '@cardano-sdk/util-dev';
import { dummyLogger } from 'ts-log';
import { firstValueFrom, of } from 'rxjs';

const { mockRewardsProvider, rewardAccount, rewardsHistory } = mockProviders;

describe('RewardsHistory', () => {
  const rewardAccounts = [rewardAccount];
  const logger = dummyLogger;

  describe('createRewardsHistoryProvider', () => {
    let rewardsProvider: TrackedRewardsProvider;
    let provider: RewardsHistoryProvider;

    beforeEach(() => {
      rewardsProvider = new TrackedRewardsProvider(mockRewardsProvider());
      provider = createRewardsHistoryProvider(rewardsProvider, {
        initialInterval: 1
      });
    });

    it('when lower bound is specified: queries underlying provider', async () => {
      expect(await firstValueFrom(provider(rewardAccounts, Cardano.EpochNo(1)))).toBe(rewardsHistory);
    });

    it('when lower bound is not specified: sets rewardsHistory as initialized and returns empty array', async () => {
      expect(await firstValueFrom(provider(rewardAccounts, null))).toEqual(new Map());
      expect(rewardsProvider.stats.rewardsHistory$.value.initialized).toBe(true);
    });
  });

  describe('createRewardsHistoryTracker', () => {
    it.each(Cardano.StakeDelegationCertificateTypes)(
      'queries and maps reward history starting from first delegation epoch+2 with %s',
      (delegationCertificateType) => {
        createTestScheduler().run(({ cold, expectObservable, flush }) => {
          const accountRewardsHistory = rewardsHistory.get(rewardAccount)!;
          const epoch = accountRewardsHistory[0].epoch;
          const getRewardsHistory = jest.fn().mockReturnValue(cold('-a', { a: rewardsHistory }));
          const target$ = createRewardsHistoryTracker(
            cold('aa', {
              a: [
                {
                  epoch: Cardano.EpochNo(0),
                  tx: createStubTxWithCertificates([
                    { __typename: Cardano.CertificateType.StakeDeregistration } as Cardano.Certificate
                  ])
                },
                {
                  epoch,
                  tx: createStubTxWithCertificates([{ __typename: delegationCertificateType } as Cardano.Certificate], {
                    stakeCredential: {
                      hash: Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(Cardano.RewardAccount.toHash(rewardAccount)),
                      type: Cardano.CredentialType.KeyHash
                    }
                  })
                }
              ]
            }),
            of(rewardAccounts),
            getRewardsHistory,
            new InMemoryRewardsHistoryStore(),
            logger
          );
          expectObservable(target$).toBe('-a', {
            a: {
              all: accountRewardsHistory,
              avgReward: 10_500n,
              lastReward: accountRewardsHistory[1],
              lifetimeRewards: 21_000n
            } as RewardsHistory
          });
          flush();
          expect(getRewardsHistory).toBeCalledTimes(1);
          expect(getRewardsHistory).toBeCalledWith(
            rewardAccounts,
            Cardano.EpochNo(calcFirstDelegationEpoch(epoch)),
            undefined
          );
        });
      }
    );

    it.each(Cardano.StakeDelegationCertificateTypes)(
      'considers only first delegation signed by the reward account with %s',
      (delegationCertificateType) => {
        createTestScheduler().run(({ cold, expectObservable, flush }) => {
          const accountRewardsHistory = rewardsHistory.get(rewardAccount)!;
          const epoch = accountRewardsHistory[0].epoch;
          const getRewardsHistory = jest.fn().mockReturnValue(cold('-a', { a: rewardsHistory }));
          const target$ = createRewardsHistoryTracker(
            cold('aa', {
              a: [
                {
                  epoch: Cardano.EpochNo(0),
                  tx: createStubTxWithCertificates([{ __typename: delegationCertificateType } as Cardano.Certificate], {
                    stakeCredential: {
                      hash: Crypto.Hash28ByteBase16('00000000000000000000000000000000000000000000000000000000'),
                      type: Cardano.CredentialType.KeyHash
                    }
                  })
                },
                {
                  epoch,
                  tx: createStubTxWithCertificates([{ __typename: delegationCertificateType } as Cardano.Certificate], {
                    stakeCredential: {
                      hash: Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(Cardano.RewardAccount.toHash(rewardAccount)),
                      type: Cardano.CredentialType.KeyHash
                    }
                  })
                }
              ]
            }),
            of(rewardAccounts),
            getRewardsHistory,
            new InMemoryRewardsHistoryStore(),
            logger
          );
          expectObservable(target$).toBe('-a', {
            a: {
              all: accountRewardsHistory,
              avgReward: 10_500n,
              lastReward: accountRewardsHistory[1],
              lifetimeRewards: 21_000n
            } as RewardsHistory
          });
          flush();
          expect(getRewardsHistory).toBeCalledTimes(1);
          expect(getRewardsHistory).toBeCalledWith(
            rewardAccounts,
            Cardano.EpochNo(calcFirstDelegationEpoch(epoch)),
            undefined
          );
        });
      }
    );

    it.todo('emits value from store if it exists and updates store after provider response');
  });
});
