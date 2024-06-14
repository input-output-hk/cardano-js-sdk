import { Cardano } from '@cardano-sdk/core';
import { Mappers, UnifiedExtChainSyncEvent, WithEpochNo } from '../../../../src';
import { firstValueFrom, of } from 'rxjs';

describe('withStakePools', () => {
  const epochNo = Cardano.EpochNo(2);

  it('collects all pool registration and retirement certificates, keeping the last one per PoolId', async () => {
    const data: Mappers.WithCertificates & WithEpochNo = {
      certificates: [
        {
          certificate: {
            __typename: Cardano.CertificateType.PoolRegistration,
            poolParameters: {
              id: Cardano.PoolId('pool1n3s8unkvmre59uzt4ned0903f9q2p8dhscw5v9eeyc0sw0m439t')
            } as Cardano.PoolParameters
          },
          pointer: {} as Cardano.Pointer
        },
        {
          certificate: {
            __typename: Cardano.CertificateType.PoolRegistration,
            poolParameters: {
              id: Cardano.PoolId('pool12pq2rzx8d7ern46udp6xrn0e0jaqt9hes9gs85hstp0egvfnf9q')
            } as Cardano.PoolParameters
          },
          pointer: {} as Cardano.Pointer
        },
        {
          certificate: {
            __typename: Cardano.CertificateType.PoolRegistration,
            poolParameters: {
              cost: 123n,
              id: Cardano.PoolId('pool12pq2rzx8d7ern46udp6xrn0e0jaqt9hes9gs85hstp0egvfnf9q')
            } as Cardano.PoolParameters
          },
          pointer: {} as Cardano.Pointer
        },
        {
          certificate: {
            __typename: Cardano.CertificateType.PoolRetirement,
            epoch: Cardano.EpochNo(3),
            poolId: Cardano.PoolId('pool12pq2rzx8d7ern46udp6xrn0e0jaqt9hes9gs85hstp0egvfnf9q')
          },
          pointer: {} as Cardano.Pointer
        },
        {
          certificate: {
            __typename: Cardano.CertificateType.PoolRetirement,
            epoch: Cardano.EpochNo(4),
            poolId: Cardano.PoolId('pool12pq2rzx8d7ern46udp6xrn0e0jaqt9hes9gs85hstp0egvfnf9q')
          },
          pointer: {} as Cardano.Pointer
        }
      ],
      epochNo
    };
    const result = await firstValueFrom(
      Mappers.withStakePools()(of(data as UnifiedExtChainSyncEvent<Mappers.WithCertificates & WithEpochNo>))
    );
    expect(result.stakePools.updates.length).toBe(2);
    // keeps the latest pool update
    expect(
      result.stakePools.updates.find(
        ({ poolParameters: { id } }) => id === 'pool12pq2rzx8d7ern46udp6xrn0e0jaqt9hes9gs85hstp0egvfnf9q'
      )?.poolParameters.cost
    ).toEqual(123n);
    expect(result.stakePools.retirements.length).toBe(1);
    // keeps the latest pool retirement
    expect(result.stakePools.retirements[0].epoch).toEqual(4);
  });

  it("omits pool retirement if it's followed by a pool registration", async () => {
    const data: Mappers.WithCertificates & WithEpochNo = {
      certificates: [
        {
          certificate: {
            __typename: Cardano.CertificateType.PoolRetirement,
            epoch: Cardano.EpochNo(3),
            poolId: Cardano.PoolId('pool12pq2rzx8d7ern46udp6xrn0e0jaqt9hes9gs85hstp0egvfnf9q')
          },
          pointer: {} as Cardano.Pointer
        },
        {
          certificate: {
            __typename: Cardano.CertificateType.PoolRegistration,
            poolParameters: {
              id: Cardano.PoolId('pool12pq2rzx8d7ern46udp6xrn0e0jaqt9hes9gs85hstp0egvfnf9q')
            } as Cardano.PoolParameters
          },
          pointer: {} as Cardano.Pointer
        }
      ],
      epochNo
    };
    const result = await firstValueFrom(
      Mappers.withStakePools()(of(data as UnifiedExtChainSyncEvent<Mappers.WithCertificates & WithEpochNo>))
    );
    expect(result.stakePools.retirements.length).toBe(0);
  });
});
