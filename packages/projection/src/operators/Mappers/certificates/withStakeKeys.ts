import * as Crypto from '@cardano-sdk/crypto';
import { Cardano, ChainSyncEventType } from '@cardano-sdk/core';
import { WithCertificates } from './withCertificates';
import { unifiedProjectorOperator } from '../../utils';

export interface WithStakeKeys {
  stakeKeys: {
    insert: Crypto.Hash28ByteBase16[];
    del: Crypto.Hash28ByteBase16[];
  };
}

/**
 * Map events with certificates to a set of stake keys that are registered or deregistered.
 *
 * Users of this operator can take advantage of the facts that it is impossible to make transactions which:
 * - registers an already registered stake key
 * - deregisters a stake key that wasn't previously registered
 *
 * The intended use case of this operator is to keep track of the current set of active stake keys,
 * ignoring **when** they were registered or unregistered.
 */
export const withStakeKeys = unifiedProjectorOperator<WithCertificates, WithStakeKeys>((evt) => {
  const register = new Set<Crypto.Hash28ByteBase16>();
  const deregister = new Set<Crypto.Hash28ByteBase16>();
  for (const { certificate } of evt.certificates) {
    if (!Cardano.isCertType(certificate, Cardano.RegAndDeregCertificateTypes)) continue;

    const {
      stakeCredential: { hash: stakeCredentialHash }
    } = certificate;

    if (Cardano.isCertType(certificate, Cardano.StakeRegistrationCertificateTypes)) {
      // Stake registration
      if (deregister.has(stakeCredentialHash)) {
        deregister.delete(stakeCredentialHash);
      } else {
        register.add(stakeCredentialHash);
      }
      continue;
    }

    // Stake deregistration
    if (register.has(stakeCredentialHash)) {
      register.delete(stakeCredentialHash);
    } else {
      deregister.add(stakeCredentialHash);
    }
  }

  const [insert, del] =
    evt.eventType === ChainSyncEventType.RollForward
      ? [[...register], [...deregister]]
      : [[...deregister], [...register]];
  return {
    ...evt,
    stakeKeys: {
      del,
      insert
    }
  };
});
