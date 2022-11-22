import { Cardano, ChainSyncEventType } from '@cardano-sdk/core';
import { RollForwardEvent, UnifiedProjectorEvent, operators } from '../../../src';
import { createTestScheduler } from '@cardano-sdk/util-dev';

const createEvent = (eventType: ChainSyncEventType, slot: Cardano.Slot, txs: Cardano.Certificate[][]) =>
  ({
    block: {
      body: txs.map(
        (certificates) =>
          ({
            body: { certificates }
          } as Cardano.Tx)
      ),
      header: { slot }
    },
    eventType
  } as RollForwardEvent);

const certificates = [
  [{ __typename: Cardano.CertificateType.StakeKeyRegistration }] as Cardano.Certificate[],
  [
    { __typename: Cardano.CertificateType.StakeKeyDeregistration },
    { __typename: Cardano.CertificateType.GenesisKeyDelegation }
  ] as Cardano.Certificate[]
];

describe('withCertificates', () => {
  it('flattens certificates from all transactions, preserving an on-chain pointer', () => {
    createTestScheduler().run(({ hot, expectObservable, expectSubscriptions }) => {
      const source$ = hot<UnifiedProjectorEvent<{}>>('ab', {
        a: createEvent(ChainSyncEventType.RollForward, Cardano.Slot(1), certificates),
        b: createEvent(ChainSyncEventType.RollForward, Cardano.Slot(2), [])
      });
      expectObservable(source$.pipe(operators.withCertificates())).toBe('ab', {
        a: {
          ...createEvent(ChainSyncEventType.RollForward, Cardano.Slot(1), certificates),
          certificates: [
            {
              certificate: certificates[0][0],
              pointer: {
                certIndex: 0,
                slot: 1,
                txIndex: 0
              }
            },
            {
              certificate: certificates[1][0],
              pointer: {
                certIndex: 0,
                slot: 1,
                txIndex: 1
              }
            },
            {
              certificate: certificates[1][1],
              pointer: {
                certIndex: 1,
                slot: 1,
                txIndex: 1
              }
            }
          ]
        },
        b: {
          ...createEvent(ChainSyncEventType.RollForward, Cardano.Slot(2), []),
          certificates: []
        }
      });
      expectSubscriptions(source$.subscriptions).toBe('^');
    });
  });
});
