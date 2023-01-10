import { Cardano } from '@cardano-sdk/core';
import { CertificatePointer, WithCertificates, WithEpochNo, withStakePools } from '../../../src/operators';
import { UnifiedProjectorEvent } from '../../../src';
import { firstValueFrom, of } from 'rxjs';

describe('withStakePools', () => {
  const epochNo = Cardano.EpochNo(2);

  it('collects all pool registration and retirement certificates and groups them by type and poolId', async () => {
    const data: WithCertificates & WithEpochNo = {
      certificates: [
        {
          certificate: {
            __typename: Cardano.CertificateType.PoolRegistration,
            poolParameters: {
              id: Cardano.PoolId('pool1n3s8unkvmre59uzt4ned0903f9q2p8dhscw5v9eeyc0sw0m439t')
            } as Cardano.PoolParameters
          },
          pointer: {} as CertificatePointer
        },
        {
          certificate: {
            __typename: Cardano.CertificateType.PoolRegistration,
            poolParameters: {
              id: Cardano.PoolId('pool12pq2rzx8d7ern46udp6xrn0e0jaqt9hes9gs85hstp0egvfnf9q')
            } as Cardano.PoolParameters
          },
          pointer: {} as CertificatePointer
        },
        {
          certificate: {
            __typename: Cardano.CertificateType.PoolRetirement,
            epoch: Cardano.EpochNo(3),
            poolId: Cardano.PoolId('pool12pq2rzx8d7ern46udp6xrn0e0jaqt9hes9gs85hstp0egvfnf9q')
          },
          pointer: {} as CertificatePointer
        }
      ],
      epochNo
    };
    const result = await firstValueFrom(
      withStakePools()(of(data as UnifiedProjectorEvent<WithCertificates & WithEpochNo>))
    );
    expect(result.stakePools.updates.size).toBe(2);
    expect(result.stakePools.retirements.size).toBe(1);
  });

  it('adds "issuedAtEpochNo" to pool updates', async () => {
    const data: WithCertificates & WithEpochNo = {
      certificates: [
        {
          certificate: {
            __typename: Cardano.CertificateType.PoolRegistration,
            poolParameters: {
              id: Cardano.PoolId('pool1n3s8unkvmre59uzt4ned0903f9q2p8dhscw5v9eeyc0sw0m439t')
            } as Cardano.PoolParameters
          },
          pointer: {} as CertificatePointer
        }
      ],
      epochNo
    };
    const result = await firstValueFrom(
      withStakePools()(of(data as UnifiedProjectorEvent<WithCertificates & WithEpochNo>))
    );
    expect(
      result.stakePools.updates.get(Cardano.PoolId('pool1n3s8unkvmre59uzt4ned0903f9q2p8dhscw5v9eeyc0sw0m439t'))![0]
        .issuedAtEpochNo
    ).toBe(epochNo);
  });
});
