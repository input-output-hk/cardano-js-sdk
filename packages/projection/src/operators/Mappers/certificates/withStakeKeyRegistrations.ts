import { Cardano } from '@cardano-sdk/core';
import { isNotNil } from '@cardano-sdk/util';
import { unifiedProjectorOperator } from '../../utils/index.js';
import type { Ed25519KeyHashHex } from '@cardano-sdk/crypto';
import type { WithCertificates } from './withCertificates.js';

export interface StakeKeyRegistration {
  pointer: Cardano.Pointer;
  stakeKeyHash: Ed25519KeyHashHex;
}

export interface WithStakeKeyRegistrations {
  stakeKeyRegistrations: StakeKeyRegistration[];
}

/** Collect all stake key registration certificates */
export const withStakeKeyRegistrations = unifiedProjectorOperator<WithCertificates, WithStakeKeyRegistrations>(
  (evt) => ({
    ...evt,
    stakeKeyRegistrations: evt.certificates
      .map(({ pointer, certificate }): StakeKeyRegistration | null => {
        if (Cardano.isCertType(certificate, Cardano.StakeRegistrationCertificateTypes)) {
          return {
            pointer,
            stakeKeyHash: certificate.stakeCredential.hash as unknown as Ed25519KeyHashHex
          };
        }
        return null;
      })
      .filter(isNotNil)
  })
);
