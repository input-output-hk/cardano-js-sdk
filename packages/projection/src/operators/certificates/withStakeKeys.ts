import { Cardano } from '@cardano-sdk/core';
import { WithCertificates } from './withCertificates';
import { unifiedProjectorOperator } from '../utils';

export interface WithStakeKeys {
  stakeKeys: {
    register: Set<Cardano.Ed25519KeyHash>;
    deregister: Set<Cardano.Ed25519KeyHash>;
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
  const register = new Set<Cardano.Ed25519KeyHash>();
  const deregister = new Set<Cardano.Ed25519KeyHash>();
  for (const { certificate } of evt.certificates)
    switch (certificate.__typename) {
      case Cardano.CertificateType.StakeKeyRegistration:
        deregister.delete(certificate.stakeKeyHash);
        register.add(certificate.stakeKeyHash);
        break;
      case Cardano.CertificateType.StakeKeyDeregistration:
        register.delete(certificate.stakeKeyHash);
        deregister.add(certificate.stakeKeyHash);
        break;
    }
  return {
    ...evt,
    stakeKeys: {
      deregister,
      register
    }
  };
});
