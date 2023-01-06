import { Cardano } from '@cardano-sdk/core';
import { WithCertificates } from './withCertificates';
import { projectorOperator } from '../utils';

export interface WithStakeKeys {
  stakeKeys: {
    register: Set<Cardano.Ed25519KeyHash>;
    deregister: Set<Cardano.Ed25519KeyHash>;
  };
}

/**
 * Map events with certificates to a set of stake keys that are registered or deregistered.
 * Emitted `stakeKeys` do **not** represent the on-chain certificates, as rollback of a registration certificate
 * is intepreted as a deregistration (the opposite is true too).
 *
 * The intended use case of this operator is to keep track of the current set of active stake keys,
 * ignoring **when** they were registered or unregistered.
 */
export const withStakeKeys = projectorOperator<WithCertificates, WithCertificates, WithStakeKeys, WithStakeKeys>({
  rollBackward: (evt) => {
    const register = new Set<Cardano.Ed25519KeyHash>();
    const deregister = new Set<Cardano.Ed25519KeyHash>();
    for (const { certificate } of evt.certificates) {
      switch (certificate.__typename) {
        case Cardano.CertificateType.StakeKeyRegistration:
          deregister.add(certificate.stakeKeyHash);
          register.delete(certificate.stakeKeyHash);
          break;
        case Cardano.CertificateType.StakeKeyDeregistration:
          register.add(certificate.stakeKeyHash);
          deregister.delete(certificate.stakeKeyHash);
          break;
      }
    }
    return {
      ...evt,
      stakeKeys: { deregister, register }
    };
  },
  rollForward: (evt) => {
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
  }
});
