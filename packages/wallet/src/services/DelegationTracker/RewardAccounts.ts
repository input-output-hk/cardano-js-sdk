/* eslint-disable unicorn/no-nested-ternary */
import { Cardano, DRepInfo, RewardAccountInfoProvider } from '@cardano-sdk/core';
import {
  EMPTY,
  Observable,
  combineLatest,
  concat,
  distinctUntilChanged,
  filter,
  firstValueFrom,
  map,
  merge,
  mergeMap,
  of,
  startWith,
  switchMap,
  tap
} from 'rxjs';
import { Logger } from 'ts-log';
import { RetryBackoffConfig } from 'backoff-rxjs';
import { TxInFlight } from '../types';
import { WalletStores } from '../../persistence';
import { blockingWithLatestFrom } from '@cardano-sdk/util-rxjs';
import { pollProvider } from '../util';
import isEqual from 'lodash/isEqual.js';

export type ObservableDrepInfoProvider = (drepIds: Cardano.DRepID[]) => Observable<DRepInfo[]>;

const affectsRewardAccount =
  (rewardAccount: Cardano.RewardAccount) =>
  (tx: Cardano.OnChainTx): boolean => {
    const stakeCredentialHash = Cardano.RewardAccount.toHash(rewardAccount);
    const hasRelevantStakeKeyCertificate = Cardano.stakeKeyCertificates(tx.body.certificates).some(
      (cert) => cert.stakeCredential.hash === stakeCredentialHash
    );
    const hasRelevantCertificate =
      hasRelevantStakeKeyCertificate ||
      tx.body.certificates?.some(
        // eslint-disable-next-line complexity
        (cert) =>
          ((cert.__typename === Cardano.CertificateType.MIR ||
            cert.__typename === Cardano.CertificateType.StakeDelegation ||
            cert.__typename === Cardano.CertificateType.StakeVoteDelegation ||
            cert.__typename === Cardano.CertificateType.VoteDelegation) &&
            cert.stakeCredential?.hash === stakeCredentialHash) ||
          (cert.__typename === Cardano.CertificateType.PoolRegistration &&
            cert.poolParameters.rewardAccount === rewardAccount) ||
          cert.__typename === Cardano.CertificateType.PoolRetirement ||
          ((cert.__typename === Cardano.CertificateType.RegisterDelegateRepresentative ||
            cert.__typename === Cardano.CertificateType.UnregisterDelegateRepresentative) &&
            cert.dRepCredential.hash === stakeCredentialHash) ||
          (cert.__typename === Cardano.CertificateType.StakeVoteDelegation &&
            cert.stakeCredential.hash === stakeCredentialHash)
      );
    return (
      hasRelevantCertificate ||
      tx.body.withdrawals?.some((withdrawal) => withdrawal.stakeAddress === rewardAccount) ||
      false
    );
  };

export const createRewardAccountInfoProvider =
  ({
    epoch$,
    externalTrigger$,
    rewardAccountInfoProvider,
    retryBackoffConfig,
    logger
  }: {
    rewardAccountInfoProvider: RewardAccountInfoProvider;
    epoch$: Observable<Cardano.EpochNo>;
    externalTrigger$: Observable<void>;
    retryBackoffConfig: RetryBackoffConfig;
    logger: Logger;
  }) =>
  (rewardAccount: Cardano.RewardAccount): Observable<Cardano.RewardAccountInfo> =>
    pollProvider({
      equals: isEqual,
      logger,
      retryBackoffConfig,
      sample: async () => rewardAccountInfoProvider.rewardAccountInfo(rewardAccount, await firstValueFrom(epoch$)),
      trigger$: merge(epoch$, externalTrigger$)
    });

export type ObservableRewardAccountInfoProvider = ReturnType<typeof createRewardAccountInfoProvider>;

const nextRewardBalance = (rewardAccount: Cardano.RewardAccount, txsInFlight: TxInFlight[]): bigint | null => {
  const hasWithdrawal = txsInFlight.some((tx) =>
    tx.body.withdrawals?.some((withdrawal) => withdrawal.stakeAddress === rewardAccount)
  );
  // rewards must be spent in full, or not at all
  return hasWithdrawal ? 0n : null;
};

const nextDeposit = (
  rewardAccount: Cardano.RewardAccount,
  txsInFlight: TxInFlight[],
  depositAmount: Cardano.Lovelace
): Cardano.Lovelace | null => {
  const stakeCredentialHash = Cardano.RewardAccount.toHash(rewardAccount);
  // try to find the last relevant certificate to take effect
  for (let txIndex = txsInFlight.length - 1; txIndex >= 0; txIndex--) {
    const certificates = txsInFlight[txIndex].body.certificates || [];
    for (let certIndex = certificates.length - 1; certIndex >= 0; certIndex--) {
      const certificate = certificates[certIndex];
      if (
        certificate.__typename === Cardano.CertificateType.StakeDeregistration &&
        certificate.stakeCredential.hash === stakeCredentialHash
      ) {
        return 0n;
      }
      if (
        (certificate.__typename === Cardano.CertificateType.StakeRegistration ||
          certificate.__typename === Cardano.CertificateType.StakeRegistrationDelegation ||
          certificate.__typename === Cardano.CertificateType.StakeVoteRegistrationDelegation) &&
        certificate.stakeCredential.hash === stakeCredentialHash
      ) {
        return depositAmount;
      }
    }
  }
  return null;
};

export const createRewardAccountsTracker = ({
  rewardAccountAddresses$,
  rewardAccountInfoProvider,
  store,
  newTransaction$,
  protocolParameters$,
  transactionsInFlight$
}: {
  rewardAccountAddresses$: Observable<Cardano.RewardAccount[]>;
  store: WalletStores['rewardAccountInfo'];
  rewardAccountInfoProvider: ObservableRewardAccountInfoProvider;
  newTransaction$: Observable<Cardano.OnChainTx>;
  protocolParameters$: Observable<Pick<Cardano.ProtocolParameters, 'stakeKeyDeposit'>>;
  transactionsInFlight$: Observable<TxInFlight[]>;
}) =>
  rewardAccountAddresses$.pipe(
    // TODO:
    // eslint-disable-next-line sonarjs/cognitive-complexity
    switchMap((rewardAccounts) =>
      combineLatest(
        rewardAccounts.map((rewardAccount) =>
          concat(
            store.getValues([rewardAccount]).pipe(mergeMap((values) => (values.length > 0 ? of(values[0]) : EMPTY))),
            newTransaction$.pipe(filter(affectsRewardAccount(rewardAccount)), startWith(null)).pipe(
              switchMap(() =>
                rewardAccountInfoProvider(rewardAccount).pipe(
                  tap((rewardAccountInfo) => store.setValue(rewardAccount, rewardAccountInfo).subscribe()),
                  blockingWithLatestFrom(protocolParameters$),
                  switchMap(([rewardAccountInfo, { stakeKeyDeposit }]) =>
                    transactionsInFlight$.pipe(
                      map((txsInFlight): Cardano.RewardAccountInfo => {
                        if (txsInFlight.length === 0) return rewardAccountInfo;
                        const nextDepositValue = nextDeposit(rewardAccount, txsInFlight, BigInt(stakeKeyDeposit));
                        return {
                          ...rewardAccountInfo,
                          credentialStatus:
                            typeof nextDepositValue === 'bigint'
                              ? nextDepositValue > 0n
                                ? Cardano.StakeCredentialStatus.Registering
                                : Cardano.StakeCredentialStatus.Unregistering
                              : rewardAccountInfo.credentialStatus,
                          // this ensures that rewards and deposit are not being spent twice if chaining transactions
                          // as well as updates balance with deposit while transaction is in flight
                          deposit: nextDepositValue ?? rewardAccountInfo.deposit,
                          rewardBalance:
                            nextRewardBalance(rewardAccount, txsInFlight) ?? rewardAccountInfo.rewardBalance
                          // this may be extended to update dRepDelegatee and delegatee
                          // based on pending transaction rather than waiting for tx confirmation
                        };
                      })
                      // do not emit when transaction is removed from transactionsInFlight$ due to seeing this tx on chain;
                      // this will be unsubscribed due to outer switchMap that looks for onChain$ tx that affects this reward account
                      // TODO: test how this behaves when inFlight$ emits at the same time as newTransaction$
                      // delay(1)
                    )
                  )
                )
              )
            )
          ).pipe(distinctUntilChanged<Cardano.RewardAccountInfo>(isEqual))
        )
      )
    )
  );
