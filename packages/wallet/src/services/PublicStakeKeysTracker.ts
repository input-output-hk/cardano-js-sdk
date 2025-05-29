import { AccountKeyDerivationPath, Bip32Account, GroupedAddress } from '@cardano-sdk/key-management';
import { Cardano } from '@cardano-sdk/core';
import { Ed25519PublicKeyHex } from '@cardano-sdk/crypto';
import { Observable, defaultIfEmpty, distinctUntilChanged, forkJoin, from, map, mergeMap, switchMap } from 'rxjs';
import { TrackerSubject } from '@cardano-sdk/util-rxjs';
import { deepEquals } from '@cardano-sdk/util';

export interface CreatePubStakeKeysTrackerProps {
  addresses$: Observable<GroupedAddress[]>;
  rewardAccounts$: Observable<Cardano.RewardAccountInfo[]>;
  bip32Account: Bip32Account;
}

export interface PubStakeKeyAndStatus {
  credentialStatus: Cardano.StakeCredentialStatus;
  publicStakeKey: Ed25519PublicKeyHex;
}

type StakeKeyDerivationPathAndStatus = {
  credentialStatus: Cardano.StakeCredentialStatus;
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
              .map(({ credentialStatus, address }) => ({
                credentialStatus,
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
  bip32Account: addressManager
}: CreatePubStakeKeysTrackerProps) =>
  new TrackerSubject(
    rewardAccounts$.pipe(
      withStakeKeyDerivationPaths(addresses$),
      mergeMap((derivationPathsAndStatus) =>
        forkJoin(
          derivationPathsAndStatus.map(({ stakeKeyDerivationPath, credentialStatus }) =>
            from(addressManager.derivePublicKey(stakeKeyDerivationPath)).pipe(
              map((publicStakeKey) => ({ credentialStatus, publicStakeKey }))
            )
          )
        ).pipe(defaultIfEmpty([]))
      ),
      distinctUntilChanged(deepEquals)
    )
  );
