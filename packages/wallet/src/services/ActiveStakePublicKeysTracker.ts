import { AsyncKeyAgent, GroupedAddress } from '@cardano-sdk/key-management';
import { Cardano } from '@cardano-sdk/core';
import {
  Observable,
  OperatorFunction,
  distinctUntilChanged,
  filter,
  from,
  map,
  mergeMap,
  switchMap,
  toArray
} from 'rxjs';
import { TrackerSubject } from '@cardano-sdk/util-rxjs';
import { deepEquals, isNotNil } from '@cardano-sdk/util';

export interface ActivePubStakeKeysProps {
  addresses$: Observable<GroupedAddress[]>;
  rewardAccounts$: Observable<Cardano.RewardAccountInfo[]>;
  keyAgent: AsyncKeyAgent;
}

const registeredRewardAccounts: OperatorFunction<Cardano.RewardAccountInfo[], Cardano.RewardAccount[]> = (
  source$: Observable<Cardano.RewardAccountInfo[]>
) =>
  source$.pipe(
    map((accts: Cardano.RewardAccountInfo[]) =>
      accts
        .filter(
          (acct) =>
            acct.keyStatus === Cardano.StakeKeyStatus.Registered ||
            acct.keyStatus === Cardano.StakeKeyStatus.Registering
        )
        .map(({ address }) => address)
    )
  );

const stakeKeyDerivationPaths =
  (addresses$: Observable<GroupedAddress[]>) => (source$: Observable<Cardano.RewardAccount[]>) =>
    source$.pipe(
      switchMap((rewardAcctAddresses) =>
        addresses$.pipe(
          // Get stakeKeyDerivationPath of each reward account
          map((groupedAddresses) =>
            rewardAcctAddresses.map(
              (rewardAddr) =>
                groupedAddresses.find((groupedAddr) => groupedAddr.rewardAccount === rewardAddr)?.stakeKeyDerivationPath
            )
          ),
          mergeMap((derivationPaths) => from(derivationPaths).pipe(filter(isNotNil), toArray()))
        )
      )
    );

export const createActivePublicStakeKeysTracker = ({
  addresses$,
  rewardAccounts$,
  keyAgent
}: ActivePubStakeKeysProps) =>
  new TrackerSubject(
    rewardAccounts$.pipe(
      registeredRewardAccounts,
      stakeKeyDerivationPaths(addresses$),
      map((derivationPaths) => derivationPaths.map((derivationPath) => keyAgent.derivePublicKey(derivationPath))),
      mergeMap((publicKeyPromises) => from(Promise.all(publicKeyPromises))),
      distinctUntilChanged(deepEquals)
    )
  );
