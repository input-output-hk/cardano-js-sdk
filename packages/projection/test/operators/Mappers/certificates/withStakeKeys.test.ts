import * as Crypto from '@cardano-sdk/crypto';
import { Cardano } from '@cardano-sdk/core';
import { ChainSyncEventType, Mappers, UnifiedExtChainSyncEvent, WithBlock } from '../../../../src';
import { firstValueFrom, of } from 'rxjs';

type EventData = Mappers.WithCertificates & { eventType: ChainSyncEventType };

describe('withStakeKeys', () => {
  describe('1 certificate per stake key', () => {
    it.each(Cardano.StakeRegistrationCertificateTypes)(
      'collects all key registration [%s] and deregistration certificates',
      async (regCertType) => {
        const data: EventData = {
          certificates: [
            {
              certificate: {
                __typename: regCertType,
                stakeCredential: {
                  hash: Crypto.Hash28ByteBase16('3b62970858d61cf667701c1f34abef41659516b191d7d374e8b0857b'),
                  type: Cardano.CredentialType.KeyHash
                }
              } as Cardano.Certificate,
              pointer: {} as Cardano.Pointer
            },
            {
              certificate: {
                __typename: Cardano.CertificateType.StakeDeregistration,
                stakeCredential: {
                  hash: Crypto.Hash28ByteBase16('3b62970858d61cf667701c1f34abef41659516b191d7d374e8b0857c'),
                  type: Cardano.CredentialType.KeyHash
                }
              },
              pointer: {} as Cardano.Pointer
            }
          ],
          eventType: ChainSyncEventType.RollForward
        };

        const result = await firstValueFrom(
          Mappers.withStakeKeys()(of(data as UnifiedExtChainSyncEvent<Mappers.WithCertificates & WithBlock>))
        );
        expect(result.stakeKeys.insert).toEqual(['3b62970858d61cf667701c1f34abef41659516b191d7d374e8b0857b']);
        expect(result.stakeKeys.del).toEqual(['3b62970858d61cf667701c1f34abef41659516b191d7d374e8b0857c']);
      }
    );

    it('reverses the logic on RollBackward', async () => {
      const data: EventData = {
        certificates: [
          {
            certificate: {
              __typename: Cardano.CertificateType.StakeRegistration,
              stakeCredential: {
                hash: Crypto.Hash28ByteBase16('3b62970858d61cf667701c1f34abef41659516b191d7d374e8b0857b'),
                type: Cardano.CredentialType.KeyHash
              }
            },
            pointer: {} as Cardano.Pointer
          },
          {
            certificate: {
              __typename: Cardano.CertificateType.StakeDeregistration,
              stakeCredential: {
                hash: Crypto.Hash28ByteBase16('3b62970858d61cf667701c1f34abef41659516b191d7d374e8b0857c'),
                type: Cardano.CredentialType.KeyHash
              }
            },
            pointer: {} as Cardano.Pointer
          }
        ],
        eventType: ChainSyncEventType.RollBackward
      };

      const result = await firstValueFrom(
        Mappers.withStakeKeys()(of(data as UnifiedExtChainSyncEvent<Mappers.WithCertificates & WithBlock>))
      );
      expect(result.stakeKeys.insert).toEqual(['3b62970858d61cf667701c1f34abef41659516b191d7d374e8b0857c']);
      expect(result.stakeKeys.del).toEqual(['3b62970858d61cf667701c1f34abef41659516b191d7d374e8b0857b']);
    });

    it('"insert" and "del" of the same key cancel each other out', async () => {
      const data: EventData = {
        certificates: [
          {
            certificate: {
              __typename: Cardano.CertificateType.StakeRegistration,
              stakeCredential: {
                hash: Crypto.Hash28ByteBase16('3b62970858d61cf667701c1f34abef41659516b191d7d374e8b0857b'),
                type: Cardano.CredentialType.KeyHash
              }
            },
            pointer: {} as Cardano.Pointer
          },
          {
            certificate: {
              __typename: Cardano.CertificateType.StakeDeregistration,
              stakeCredential: {
                hash: Crypto.Hash28ByteBase16('3b62970858d61cf667701c1f34abef41659516b191d7d374e8b0857b'),
                type: Cardano.CredentialType.KeyHash
              }
            },
            pointer: {} as Cardano.Pointer
          }
        ],
        eventType: ChainSyncEventType.RollForward
      };
      const result = await firstValueFrom(
        Mappers.withStakeKeys()(of(data as UnifiedExtChainSyncEvent<Mappers.WithCertificates & WithBlock>))
      );
      expect(result.stakeKeys.insert.length).toBe(0);
      expect(result.stakeKeys.del.length).toBe(0);
    });

    it('"del" and "insert" of the same key cancel each other out', async () => {
      const data: Mappers.WithCertificates & { eventType: ChainSyncEventType } = {
        certificates: [
          {
            certificate: {
              __typename: Cardano.CertificateType.StakeDeregistration,
              stakeCredential: {
                hash: Crypto.Hash28ByteBase16('3b62970858d61cf667701c1f34abef41659516b191d7d374e8b0857b'),
                type: Cardano.CredentialType.KeyHash
              }
            },
            pointer: {} as Cardano.Pointer
          },
          {
            certificate: {
              __typename: Cardano.CertificateType.StakeRegistration,
              stakeCredential: {
                hash: Crypto.Hash28ByteBase16('3b62970858d61cf667701c1f34abef41659516b191d7d374e8b0857b'),
                type: Cardano.CredentialType.KeyHash
              }
            },
            pointer: {} as Cardano.Pointer
          }
        ],
        eventType: ChainSyncEventType.RollForward
      };
      const result = await firstValueFrom(
        Mappers.withStakeKeys()(of(data as UnifiedExtChainSyncEvent<Mappers.WithCertificates & WithBlock>))
      );
      expect(result.stakeKeys.insert.length).toBe(0);
      expect(result.stakeKeys.del.length).toBe(0);
    });
  });
});
