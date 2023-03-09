import * as Crypto from '@cardano-sdk/crypto';
import { Cardano, ChainSyncEventType } from '@cardano-sdk/core';
import { CertificatePointer, WithCertificates, withStakeKeys } from '../../../src/operators';
import { UnifiedProjectorEvent, WithBlock } from '../../../src';
import { firstValueFrom, of } from 'rxjs';

type EventData = WithCertificates & { eventType: ChainSyncEventType };

describe('withStakeKeys', () => {
  describe('1 certificate per stake key', () => {
    it('collects all key registration and deregistration certificates', async () => {
      const data: EventData = {
        certificates: [
          {
            certificate: {
              __typename: Cardano.CertificateType.StakeKeyRegistration,
              stakeKeyHash: Crypto.Ed25519KeyHashHex('3b62970858d61cf667701c1f34abef41659516b191d7d374e8b0857b')
            },
            pointer: {} as CertificatePointer
          },
          {
            certificate: {
              __typename: Cardano.CertificateType.StakeKeyDeregistration,
              stakeKeyHash: Crypto.Ed25519KeyHashHex('3b62970858d61cf667701c1f34abef41659516b191d7d374e8b0857c')
            },
            pointer: {} as CertificatePointer
          }
        ],
        eventType: ChainSyncEventType.RollForward
      };

      const result = await firstValueFrom(
        withStakeKeys()(of(data as UnifiedProjectorEvent<WithCertificates & WithBlock>))
      );
      expect(result.stakeKeys.insert).toEqual(['3b62970858d61cf667701c1f34abef41659516b191d7d374e8b0857b']);
      expect(result.stakeKeys.del).toEqual(['3b62970858d61cf667701c1f34abef41659516b191d7d374e8b0857c']);
    });

    it('reverses the logic on RollBackward', async () => {
      const data: EventData = {
        certificates: [
          {
            certificate: {
              __typename: Cardano.CertificateType.StakeKeyRegistration,
              stakeKeyHash: Crypto.Ed25519KeyHashHex('3b62970858d61cf667701c1f34abef41659516b191d7d374e8b0857b')
            },
            pointer: {} as CertificatePointer
          },
          {
            certificate: {
              __typename: Cardano.CertificateType.StakeKeyDeregistration,
              stakeKeyHash: Crypto.Ed25519KeyHashHex('3b62970858d61cf667701c1f34abef41659516b191d7d374e8b0857c')
            },
            pointer: {} as CertificatePointer
          }
        ],
        eventType: ChainSyncEventType.RollBackward
      };

      const result = await firstValueFrom(
        withStakeKeys()(of(data as UnifiedProjectorEvent<WithCertificates & WithBlock>))
      );
      expect(result.stakeKeys.insert).toEqual(['3b62970858d61cf667701c1f34abef41659516b191d7d374e8b0857c']);
      expect(result.stakeKeys.del).toEqual(['3b62970858d61cf667701c1f34abef41659516b191d7d374e8b0857b']);
    });

    it('"insert" and "del" of the same key cancel each other out', async () => {
      const data: EventData = {
        certificates: [
          {
            certificate: {
              __typename: Cardano.CertificateType.StakeKeyRegistration,
              stakeKeyHash: Crypto.Ed25519KeyHashHex('3b62970858d61cf667701c1f34abef41659516b191d7d374e8b0857b')
            },
            pointer: {} as CertificatePointer
          },
          {
            certificate: {
              __typename: Cardano.CertificateType.StakeKeyDeregistration,
              stakeKeyHash: Crypto.Ed25519KeyHashHex('3b62970858d61cf667701c1f34abef41659516b191d7d374e8b0857b')
            },
            pointer: {} as CertificatePointer
          }
        ],
        eventType: ChainSyncEventType.RollForward
      };
      const result = await firstValueFrom(
        withStakeKeys()(of(data as UnifiedProjectorEvent<WithCertificates & WithBlock>))
      );
      expect(result.stakeKeys.insert.length).toBe(0);
      expect(result.stakeKeys.del.length).toBe(0);
    });

    it('"del" and "insert" of the same key cancel each other out', async () => {
      const data: WithCertificates & { eventType: ChainSyncEventType } = {
        certificates: [
          {
            certificate: {
              __typename: Cardano.CertificateType.StakeKeyDeregistration,
              stakeKeyHash: Crypto.Ed25519KeyHashHex('3b62970858d61cf667701c1f34abef41659516b191d7d374e8b0857b')
            },
            pointer: {} as CertificatePointer
          },
          {
            certificate: {
              __typename: Cardano.CertificateType.StakeKeyRegistration,
              stakeKeyHash: Crypto.Ed25519KeyHashHex('3b62970858d61cf667701c1f34abef41659516b191d7d374e8b0857b')
            },
            pointer: {} as CertificatePointer
          }
        ],
        eventType: ChainSyncEventType.RollForward
      };
      const result = await firstValueFrom(
        withStakeKeys()(of(data as UnifiedProjectorEvent<WithCertificates & WithBlock>))
      );
      expect(result.stakeKeys.insert.length).toBe(0);
      expect(result.stakeKeys.del.length).toBe(0);
    });
  });
});
