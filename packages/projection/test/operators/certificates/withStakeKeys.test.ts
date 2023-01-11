import { Cardano } from '@cardano-sdk/core';
import { CertificatePointer, WithCertificates, withStakeKeys } from '../../../src/operators';
import { UnifiedProjectorEvent, WithBlock } from '../../../src';
import { firstValueFrom, of } from 'rxjs';

describe('withStakeKeys', () => {
  it('collects all key registration and deregistration certificates', async () => {
    const data: WithCertificates = {
      certificates: [
        {
          certificate: {
            __typename: Cardano.CertificateType.StakeKeyRegistration,
            stakeKeyHash: Cardano.Ed25519KeyHash('3b62970858d61cf667701c1f34abef41659516b191d7d374e8b0857b')
          },
          pointer: {} as CertificatePointer
        },
        {
          certificate: {
            __typename: Cardano.CertificateType.StakeKeyDeregistration,
            stakeKeyHash: Cardano.Ed25519KeyHash('3b62970858d61cf667701c1f34abef41659516b191d7d374e8b0857c')
          },
          pointer: {} as CertificatePointer
        }
      ]
    };
    const result = await firstValueFrom(
      withStakeKeys()(of(data as UnifiedProjectorEvent<WithCertificates & WithBlock>))
    );
    expect(result.stakeKeys.register.size).toBe(1);
    expect(result.stakeKeys.deregister.size).toBe(1);
  });

  it('"register" and "deregister" of the same key cancel each other out', async () => {
    const data: WithCertificates = {
      certificates: [
        {
          certificate: {
            __typename: Cardano.CertificateType.StakeKeyRegistration,
            stakeKeyHash: Cardano.Ed25519KeyHash('3b62970858d61cf667701c1f34abef41659516b191d7d374e8b0857b')
          },
          pointer: {} as CertificatePointer
        },
        {
          certificate: {
            __typename: Cardano.CertificateType.StakeKeyDeregistration,
            stakeKeyHash: Cardano.Ed25519KeyHash('3b62970858d61cf667701c1f34abef41659516b191d7d374e8b0857b')
          },
          pointer: {} as CertificatePointer
        }
      ]
    };
    const result = await firstValueFrom(
      withStakeKeys()(of(data as UnifiedProjectorEvent<WithCertificates & WithBlock>))
    );
    expect(result.stakeKeys.register.size).toBe(0);
    expect(result.stakeKeys.deregister.size).toBe(0);
  });

  it('"deregister" and "register" of the same key cancel each other out', async () => {
    const data: WithCertificates = {
      certificates: [
        {
          certificate: {
            __typename: Cardano.CertificateType.StakeKeyDeregistration,
            stakeKeyHash: Cardano.Ed25519KeyHash('3b62970858d61cf667701c1f34abef41659516b191d7d374e8b0857b')
          },
          pointer: {} as CertificatePointer
        },
        {
          certificate: {
            __typename: Cardano.CertificateType.StakeKeyRegistration,
            stakeKeyHash: Cardano.Ed25519KeyHash('3b62970858d61cf667701c1f34abef41659516b191d7d374e8b0857b')
          },
          pointer: {} as CertificatePointer
        }
      ]
    };
    const result = await firstValueFrom(
      withStakeKeys()(of(data as UnifiedProjectorEvent<WithCertificates & WithBlock>))
    );
    expect(result.stakeKeys.register.size).toBe(0);
    expect(result.stakeKeys.deregister.size).toBe(0);
  });
});
