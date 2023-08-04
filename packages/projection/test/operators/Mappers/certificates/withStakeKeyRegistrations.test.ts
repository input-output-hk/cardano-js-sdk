import * as Crypto from '@cardano-sdk/crypto';
import { Cardano, ChainSyncEventType } from '@cardano-sdk/core';
import { Mappers, UnifiedExtChainSyncEvent, WithBlock } from '../../../../src';
import { firstValueFrom, of } from 'rxjs';

type EventData = Mappers.WithCertificates & { eventType: ChainSyncEventType };

describe('withStakeKeyRegistrations', () => {
  it('collects all key registration certificates', async () => {
    const pointer: Cardano.Pointer = {
      certIndex: Cardano.CertIndex(1),
      slot: Cardano.Slot(123),
      txIndex: Cardano.TxIndex(2)
    };
    const data: EventData = {
      certificates: [
        {
          certificate: {
            __typename: Cardano.CertificateType.StakeKeyRegistration,
            stakeKeyHash: Crypto.Ed25519KeyHashHex('3b62970858d61cf667701c1f34abef41659516b191d7d374e8b0857b')
          },
          pointer
        },
        {
          certificate: {
            __typename: Cardano.CertificateType.StakeKeyDeregistration,
            stakeKeyHash: Crypto.Ed25519KeyHashHex('3b62970858d61cf667701c1f34abef41659516b191d7d374e8b0857c')
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
