import { Cardano } from '@cardano-sdk/core';
import { unifiedProjectorOperator } from '../../utils/index.js';
import type { WithCertificates } from './withCertificates.js';
import type { WithEpochNo } from '../../../types.js';

export interface WithCertificateSource {
  source: Cardano.Pointer;
}

export type PoolUpdate = Omit<Cardano.PoolRegistrationCertificate, '__typename'> & WithCertificateSource;

export type PoolRetirement = Omit<Cardano.PoolRetirementCertificate, '__typename'> & WithCertificateSource;

export interface WithStakePools {
  stakePools: {
    /** One per PoolId (only the latest certificate takes effect) */
    updates: PoolUpdate[];
    /**
     * Does not include retirements that were invalidated by PoolUpdate in this same block.
     * One per PoolId (only the latest certificate takes effect)
     */
    retirements: PoolRetirement[];
  };
}

/** Map blocks with certificates to stake pool updates and retirements. */
export const withStakePools = unifiedProjectorOperator<WithCertificates & WithEpochNo, WithStakePools>((evt) => {
  const updates: Record<Cardano.PoolId, PoolUpdate> = {};
  const retirements: Record<Cardano.PoolId, PoolRetirement> = {};
  for (const { certificate, pointer: source } of evt.certificates) {
    switch (certificate.__typename) {
      case Cardano.CertificateType.PoolRegistration:
        updates[certificate.poolParameters.id] = {
          poolParameters: certificate.poolParameters,
          source
        };
        // PoolRegistration cancels PoolRetirement
        delete retirements[certificate.poolParameters.id];
        break;
      case Cardano.CertificateType.PoolRetirement:
        retirements[certificate.poolId] = {
          epoch: certificate.epoch,
          poolId: certificate.poolId,
          source
        };
        break;
    }
  }
  return {
    ...evt,
    stakePools: { retirements: Object.values(retirements), updates: Object.values(updates) }
  };
});
