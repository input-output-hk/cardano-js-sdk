/* eslint-disable sonarjs/cognitive-complexity */
import * as Crypto from '@cardano-sdk/crypto';
import { Cardano } from '@cardano-sdk/core';
import { Observable, distinctUntilChanged, map, switchMap } from 'rxjs';
import { TrackerSubject } from '@cardano-sdk/util-rxjs';

interface CreateDRepRegistrationTrackerProps {
  historyTransactions$: Observable<Cardano.HydratedTx[]>;
  pubDRepKeyHash$: Observable<Crypto.Ed25519KeyHashHex | undefined>;
}

interface IsOwnDRepCredentialProps {
  certificate: Cardano.Certificate;
  dRepKeyHash: Crypto.Ed25519KeyHashHex;
}

const hasOwnDRepCredential = ({ certificate, dRepKeyHash }: IsOwnDRepCredentialProps) =>
  'dRepCredential' in certificate &&
  certificate.dRepCredential.type === Cardano.CredentialType.KeyHash &&
  certificate.dRepCredential.hash === Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(dRepKeyHash);

export const createDRepRegistrationTracker = ({
  historyTransactions$,
  pubDRepKeyHash$
}: CreateDRepRegistrationTrackerProps): TrackerSubject<boolean> =>
  new TrackerSubject(
    pubDRepKeyHash$.pipe(
      switchMap((dRepKeyHash) =>
        historyTransactions$.pipe(
          map((txs) => {
            if (!dRepKeyHash) return false;
            const reverseTxs = [...txs].reverse();

            for (const {
              body: { certificates }
            } of reverseTxs) {
              if (certificates) {
                for (const certificate of certificates) {
                  if (!hasOwnDRepCredential({ certificate, dRepKeyHash })) continue;
                  if (certificate.__typename === Cardano.CertificateType.UnregisterDelegateRepresentative) return false;
                  if (certificate.__typename === Cardano.CertificateType.RegisterDelegateRepresentative) return true;
                }
              }
            }

            return false;
          })
        )
      ),
      distinctUntilChanged()
    )
  );
