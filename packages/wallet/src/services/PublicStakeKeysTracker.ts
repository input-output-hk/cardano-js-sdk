import { AccountKeyDerivationPath, GroupedAddress, util } from '@cardano-sdk/key-management';
import { Cardano } from '@cardano-sdk/core';
import { Ed25519PublicKeyHex } from '@cardano-sdk/crypto';
import { Observable, defaultIfEmpty, distinctUntilChanged, forkJoin, from, map, mergeMap, switchMap } from 'rxjs';
import { TrackerSubject } from '@cardano-sdk/util-rxjs';
import { deepEquals } from '@cardano-sdk/util';

export interface CreatePubStakeKeysTrackerProps {
  addresses$: Observable<GroupedAddress[]>;
  rewardAccounts$: Observable<Cardano.RewardAccountInfo[]>;
  addressManager: util.Bip32Ed25519AddressManager;
}

export interface PubStakeKeyAndStatus {
  keyStatus: Cardano.StakeKeyStatus;
  publicStakeKey: Ed25519PublicKeyHex;
}

type StakeKeyDerivationPathAndStatus = {
  keyStatus: Cardano.StakeKeyStatus;
  stakeKeyDerivationPath: AccountKeyDerivationPath;
};

const withStakeKeyDerivationPaths =
  (addresses$: Observable<GroupedAddress[]>) => (source$: Observable<Cardano.RewardAccountInfo[]>) =>
    source$.pipe(
      switchMap((rewardAccounts) =>
        addresses$.pipe(
          // Get stakeKeyDerivationPath of each reward account
          map((groupedAddresses) =>
            rewardAccounts
              .map(({ keyStatus, address }) => ({
                keyStatus,
                stakeKeyDerivationPath: groupedAddresses.find((groupedAddr) => groupedAddr.rewardAccount === address)
                  ?.stakeKeyDerivationPath
              }))
              .filter((v): v is StakeKeyDerivationPathAndStatus => !!v.stakeKeyDerivationPath)
          )
        )
      )
    );

export const createPublicStakeKeysTracker = ({
  addresses$,
  rewardAccounts$,
  addressManager
}: CreatePubStakeKeysTrackerProps) =>
  new TrackerSubject(
    rewardAccounts$.pipe(
      withStakeKeyDerivationPaths(addresses$),
      mergeMap((derivationPathsAndStatus) =>
        forkJoin(
          derivationPathsAndStatus.map(({ stakeKeyDerivationPath, keyStatus }) =>
            from(addressManager.derivePublicKey(stakeKeyDerivationPath)).pipe(
              map((publicStakeKey) => ({ keyStatus, publicStakeKey }))
            )
          )
        ).pipe(defaultIfEmpty([]))
      ),
      distinctUntilChanged(deepEquals)
    )
  );
