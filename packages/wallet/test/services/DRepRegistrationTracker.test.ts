/* eslint-disable no-console */
import * as Crypto from '@cardano-sdk/crypto';
import { Cardano } from '@cardano-sdk/core';
import { createDRepRegistrationTracker } from '../../src/index.js';
import { createTestScheduler } from '@cardano-sdk/util-dev';
import { of } from 'rxjs';

describe('createDRepRegistrationTracker', () => {
  let dRepPublicKey: Crypto.Ed25519PublicKeyHex;
  let dRepKeyHash: Crypto.Hash28ByteBase16;
  let dRepPublicKeyHash: Crypto.Ed25519KeyHashHex;
  const foreignDRepKeyHash = Crypto.Hash28ByteBase16('8293d319ef5b3ac72366dd28006bd315b715f7e7cfcbd3004129b80d');

  const unregisterDelegateRepresentativeCertificate = {
    __typename: Cardano.CertificateType.UnregisterDelegateRepresentative
  };

  const registerDelegateRepresentativeCertificate = {
    __typename: Cardano.CertificateType.RegisterDelegateRepresentative
  };

  const txWithOtherCertificate = {
    body: { certificates: [{ __typename: 'other_certificate' }] }
  } as unknown as Cardano.HydratedTx;

  beforeEach(async () => {
    dRepPublicKey = Crypto.Ed25519PublicKeyHex('deeb8f82f2af5836ebbc1b450b6dbf0b03c93afe5696f10d49e8a8304ebfac01');
    dRepKeyHash = Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(
      (await Crypto.Ed25519PublicKey.fromHex(dRepPublicKey).hash()).hex()
    );
    dRepPublicKeyHash = (await Crypto.Ed25519PublicKey.fromHex(dRepPublicKey).hash()).hex();
  });

  test('computes proper isRegisteredDrep value from historyTransactions$', () => {
    const txWithRegisterDelegateRepresentativeCertificate_ScriptHashDRepCredential = {
      body: {
        certificates: [
          {
            ...registerDelegateRepresentativeCertificate,
            dRepCredential: { hash: dRepKeyHash, type: Cardano.CredentialType.ScriptHash }
          }
        ]
      }
    } as unknown as Cardano.HydratedTx;

    const txWithUnregisterDelegateRepresentativeCertificate_ScriptHashDRepCredential = {
      body: {
        certificates: [
          {
            ...unregisterDelegateRepresentativeCertificate,
            dRepCredential: { hash: dRepKeyHash, type: Cardano.CredentialType.ScriptHash }
          }
        ]
      }
    } as unknown as Cardano.HydratedTx;

    const txWithOwnRegisterDelegateRepresentativeCertificate = {
      body: {
        certificates: [
          {
            ...registerDelegateRepresentativeCertificate,
            dRepCredential: { hash: dRepKeyHash, type: Cardano.CredentialType.KeyHash }
          }
        ]
      }
    } as unknown as Cardano.HydratedTx;

    const txWithOwnUnregisterDelegateRepresentativeCertificate = {
      body: {
        certificates: [
          {
            ...unregisterDelegateRepresentativeCertificate,
            dRepCredential: { hash: dRepKeyHash, type: Cardano.CredentialType.KeyHash }
          }
        ]
      }
    } as unknown as Cardano.HydratedTx;

    const txWithForeignRegisterDelegateRepresentativeCertificate = {
      body: {
        certificates: [
          {
            ...registerDelegateRepresentativeCertificate,
            dRepCredential: { hash: foreignDRepKeyHash, type: Cardano.CredentialType.KeyHash }
          }
        ]
      }
    } as unknown as Cardano.HydratedTx;

    const txWithForeignUnregisterDelegateRepresentativeCertificate = {
      body: {
        certificates: [
          {
            ...unregisterDelegateRepresentativeCertificate,
            dRepCredential: { hash: foreignDRepKeyHash, type: Cardano.CredentialType.KeyHash }
          }
        ]
      }
    } as unknown as Cardano.HydratedTx;

    createTestScheduler().run(({ cold, expectObservable, flush }) => {
      const target$ = createDRepRegistrationTracker({
        historyTransactions$: cold('a-b-c-d-e-f-g-h', {
          a: [],
          b: [txWithOtherCertificate],
          c: [txWithOtherCertificate, txWithRegisterDelegateRepresentativeCertificate_ScriptHashDRepCredential],
          d: [
            txWithOtherCertificate,
            txWithRegisterDelegateRepresentativeCertificate_ScriptHashDRepCredential,
            txWithForeignRegisterDelegateRepresentativeCertificate
          ],
          e: [
            txWithOtherCertificate,
            txWithRegisterDelegateRepresentativeCertificate_ScriptHashDRepCredential,
            txWithForeignRegisterDelegateRepresentativeCertificate,
            txWithOwnRegisterDelegateRepresentativeCertificate
          ],
          f: [
            txWithOtherCertificate,
            txWithRegisterDelegateRepresentativeCertificate_ScriptHashDRepCredential,
            txWithForeignRegisterDelegateRepresentativeCertificate,
            txWithOwnRegisterDelegateRepresentativeCertificate,
            txWithUnregisterDelegateRepresentativeCertificate_ScriptHashDRepCredential
          ],
          g: [
            txWithOtherCertificate,
            txWithRegisterDelegateRepresentativeCertificate_ScriptHashDRepCredential,
            txWithForeignRegisterDelegateRepresentativeCertificate,
            txWithOwnRegisterDelegateRepresentativeCertificate,
            txWithUnregisterDelegateRepresentativeCertificate_ScriptHashDRepCredential,
            txWithForeignUnregisterDelegateRepresentativeCertificate
          ],
          h: [
            txWithOtherCertificate,
            txWithRegisterDelegateRepresentativeCertificate_ScriptHashDRepCredential,
            txWithForeignRegisterDelegateRepresentativeCertificate,
            txWithOwnRegisterDelegateRepresentativeCertificate,
            txWithUnregisterDelegateRepresentativeCertificate_ScriptHashDRepCredential,
            txWithForeignUnregisterDelegateRepresentativeCertificate,
            txWithOwnUnregisterDelegateRepresentativeCertificate
          ]
        }),
        pubDRepKeyHash$: of(dRepPublicKeyHash)
      });
      expectObservable(target$).toBe('a-------e-----h', {
        a: false,
        e: true,
        h: false
      });
      flush();
    });
  });

  test('computes proper isRegisteredDrep value from historyTransactions$ covering the case when pubDRepKeyHash$ is undefined', () => {
    const txWithOwnRegisterDelegateRepresentativeCertificate = {
      body: {
        certificates: [
          {
            ...registerDelegateRepresentativeCertificate,
            dRepCredential: { hash: dRepKeyHash, type: Cardano.CredentialType.KeyHash }
          }
        ]
      }
    } as unknown as Cardano.HydratedTx;

    createTestScheduler().run(({ cold, expectObservable, flush }) => {
      const target$ = createDRepRegistrationTracker({
        historyTransactions$: of([txWithOwnRegisterDelegateRepresentativeCertificate]),
        pubDRepKeyHash$: cold('a-b', { a: undefined, b: dRepPublicKeyHash })
      });
      expectObservable(target$).toBe('a-b', {
        a: false,
        b: true
      });
      flush();
    });
  });
});
