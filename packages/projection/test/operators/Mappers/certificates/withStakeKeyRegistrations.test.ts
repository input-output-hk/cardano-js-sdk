import * as Crypto from '@cardano-sdk/crypto';
import { Cardano } from '@cardano-sdk/core';
import { ChainSyncEventType, Mappers, UnifiedExtChainSyncEvent, WithBlock } from '../../../../src';
import { firstValueFrom, of } from 'rxjs';

type EventData = Mappers.WithCertificates & { eventType: ChainSyncEventType };

describe('withStakeKeyRegistrations', () => {
  it.each(Cardano.StakeRegistrationCertificateTypes)('collects %s registration certificates', async (regCertType) => {
    const pointer: Cardano.Pointer = {
      certIndex: Cardano.CertIndex(1),
      slot: 123n,
      txIndex: Cardano.TxIndex(2)
    };
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
          pointer
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
      Mappers.withStakeKeyRegistrations()(of(data as UnifiedExtChainSyncEvent<Mappers.WithCertificates & WithBlock>))
    );
    expect(result.stakeKeyRegistrations).toEqual([
      {
        pointer,
        stakeKeyHash: '3b62970858d61cf667701c1f34abef41659516b191d7d374e8b0857b'
      }
    ]);
  });
});
