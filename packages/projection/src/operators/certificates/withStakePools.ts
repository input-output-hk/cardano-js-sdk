import { Cardano } from '@cardano-sdk/core';
import { CertificatePointer, WithCertificates } from './withCertificates';
import { WithEpochNo } from '../withEpochNo';
import { projectorOperator } from '../utils';

export interface WithCertificateSource {
  source: CertificatePointer;
}

export interface PoolUpdate extends WithCertificateSource {
  poolParameters: Cardano.PoolParameters;
  issuedAtEpochNo: Cardano.EpochNo;
}

export interface PoolRetirement extends WithCertificateSource {
  retireAtEpoch: Cardano.EpochNo;
}

export interface WithStakePools {
  stakePools: {
    updates: Map<Cardano.PoolId, PoolUpdate[]>;
    retirements: Map<Cardano.PoolId, PoolRetirement[]>;
  };
}

const addPoolItem = <T>(collection: Map<Cardano.PoolId, T[]>, poolId: Cardano.PoolId, item: T) => {
  let poolItems = collection.get(poolId);
  if (!poolItems) {
    poolItems = [];
    collection.set(poolId, poolItems);
  }
  poolItems.push(item);
};

/**
 * Map RollForward events with certificates to stake pool updates and retirements.
 * RollBackward events are unmodified.
 */
export const withStakePools = projectorOperator<WithCertificates & WithEpochNo, {}, WithStakePools, {}>({
  rollBackward: (evt) => evt,
  rollForward: (evt) => {
    const updates = new Map<Cardano.PoolId, PoolUpdate[]>();
    const retirements = new Map<Cardano.PoolId, PoolRetirement[]>();
    for (const { certificate, pointer: source } of evt.certificates) {
      switch (certificate.__typename) {
        case Cardano.CertificateType.PoolRegistration:
          addPoolItem(updates, certificate.poolParameters.id, {
            issuedAtEpochNo: evt.epochNo,
            poolParameters: certificate.poolParameters,
            source
          });
          break;
        case Cardano.CertificateType.PoolRetirement:
          addPoolItem(retirements, certificate.poolId, {
            retireAtEpoch: certificate.epoch,
            source
          });
          break;
      }
    }
    return {
      ...evt,
      stakePools: { retirements, updates }
    };
  }
});
