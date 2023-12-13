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
// eslint-disable-next-line sonarjs/cognitive-complexity
export const withStakeKeys = unifiedProjectorOperator<WithCertificates, WithStakeKeys>((evt) => {
  const register = new Set<Crypto.Hash28ByteBase16>();
  const deregister = new Set<Crypto.Hash28ByteBase16>();
  for (const { certificate } of evt.certificates) {
    if (Cardano.RegAndDeregCertificateTypes.includes(certificate.__typename as Cardano.RegAndDeregCertificateTypes)) {
      const {
        stakeCredential: { hash: stakeCredentialHash }
      } = certificate as Cardano.RegAndDeregCertificateUnion;

      switch (certificate.__typename) {
        case Cardano.CertificateType.StakeDeregistration:
        case Cardano.CertificateType.Unregistration:
          if (register.has(certificate.stakeCredential.hash)) {
            register.delete(certificate.stakeCredential.hash);
          } else {
            deregister.add(certificate.stakeCredential.hash);
          }
          break;
        default:
          // Stake registration
          if (deregister.has(stakeCredentialHash)) {
            deregister.delete(stakeCredentialHash);
          } else {
            register.add(stakeCredentialHash);
          }
          break;
      }
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
