import { Cardano, ChainSyncEventType } from '@cardano-sdk/core';
import { Operators, RollForwardEvent, UnifiedProjectorEvent } from '../../../src';
import { createTestScheduler } from '@cardano-sdk/util-dev';

const createEvent = (
  eventType: ChainSyncEventType,
  slot: Cardano.Slot,
  txs: Cardano.Certificate[][],
  inputSource: Cardano.InputSource = Cardano.InputSource.inputs
) =>
  ({
    block: {
      body: txs.map(
        (certificates) =>
          ({
            body: { certificates },
            inputSource
          } as Cardano.OnChainTx)
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
  it(`flattens certificates from all transactions, preserving an on-chain pointer.
      skips certificates from phase2validation failed transactions`, () => {
    createTestScheduler().run(({ hot, expectObservable, expectSubscriptions }) => {
      const source$ = hot<UnifiedProjectorEvent<{}>>('abc', {
        a: createEvent(ChainSyncEventType.RollForward, Cardano.Slot(1), certificates),
        b: createEvent(ChainSyncEventType.RollForward, Cardano.Slot(2), []),
        c: createEvent(ChainSyncEventType.RollForward, Cardano.Slot(3), certificates, Cardano.InputSource.collaterals)
      });
      expectObservable(source$.pipe(Operators.withCertificates())).toBe('abc', {
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
        },
        c: {
          ...createEvent(
            ChainSyncEventType.RollForward,
            Cardano.Slot(3),
            certificates,
            Cardano.InputSource.collaterals
          ),
          certificates: []
        }
      });
      expectSubscriptions(source$.subscriptions).toBe('^');
    });
  });
});
