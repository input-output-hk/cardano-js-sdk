import * as Crypto from '@cardano-sdk/crypto';
import { Cardano, ChainSyncEventType } from '@cardano-sdk/core';
import { WithCertificates } from './withCertificates';
import { unifiedProjectorOperator } from '../utils';

export interface WithStakeKeys {
  stakeKeys: {
    insert: Crypto.Ed25519KeyHashHex[];
    del: Crypto.Ed25519KeyHashHex[];
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
  const register = new Set<Crypto.Ed25519KeyHashHex>();
  const deregister = new Set<Crypto.Ed25519KeyHashHex>();
  for (const { certificate } of evt.certificates) {
    switch (certificate.__typename) {
      case Cardano.CertificateType.StakeKeyRegistration:
        if (deregister.has(certificate.stakeKeyHash)) {
          deregister.delete(certificate.stakeKeyHash);
        } else {
          register.add(certificate.stakeKeyHash);
        }
        break;
      case Cardano.CertificateType.StakeKeyDeregistration:
        if (register.has(certificate.stakeKeyHash)) {
          register.delete(certificate.stakeKeyHash);
        } else {
          deregister.add(certificate.stakeKeyHash);
        }
        break;
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
