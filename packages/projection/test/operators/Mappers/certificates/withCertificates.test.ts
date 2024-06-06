import { Cardano, ChainSyncEventType } from '@cardano-sdk/core';
import { Mappers } from '../../../../src/index.js';
import { createTestScheduler } from '@cardano-sdk/util-dev';
import type { RollForwardEvent, UnifiedExtChainSyncEvent } from '../../../../src/index.js';

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
  [{ __typename: Cardano.CertificateType.StakeRegistration }] as Cardano.Certificate[],
  [
    { __typename: Cardano.CertificateType.StakeDeregistration },
    { __typename: Cardano.CertificateType.GenesisKeyDelegation }
  ] as Cardano.Certificate[]
];

describe('withCertificates', () => {
  it(`flattens certificates from all transactions, preserving an on-chain pointer.
      skips certificates from phase2validation failed transactions`, () => {
    createTestScheduler().run(({ hot, expectObservable, expectSubscriptions }) => {
      const source$ = hot<UnifiedExtChainSyncEvent<{}>>('abc', {
        a: createEvent(ChainSyncEventType.RollForward, Cardano.Slot(1), certificates),
        b: createEvent(ChainSyncEventType.RollForward, Cardano.Slot(2), []),
        c: createEvent(ChainSyncEventType.RollForward, Cardano.Slot(3), certificates, Cardano.InputSource.collaterals)
      });
      expectObservable(source$.pipe(Mappers.withCertificates())).toBe('abc', {
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
