import { Cardano, ChainSyncEventType } from '@cardano-sdk/core';
import {
  ProjectorEvent,
  RollBackwardEvent,
  RollForwardEvent,
  WithRolledBackEvents,
  withCertificates
} from '../../../src';
import { createTestScheduler } from '@cardano-sdk/util-dev';

const rollForwardEvent = (slot: Cardano.Slot, txs: Cardano.Certificate[][]) =>
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
    eventType: ChainSyncEventType.RollForward
  } as RollForwardEvent);

const rollBackwardEvent = (blocks: Cardano.Certificate[][][]) =>
  ({
    eventType: ChainSyncEventType.RollBackward,
    rolledBackEvents: blocks.map((txs, slot) => ({
      block: {
        body: txs.map((certificates) => ({
          body: { certificates }
        })),
        header: { slot: Cardano.Slot(slot) }
      }
    }))
  } as RollBackwardEvent<WithRolledBackEvents>);

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
      const source$ = hot<ProjectorEvent<{}, WithRolledBackEvents>>('ab', {
        a: rollForwardEvent(Cardano.Slot(1), certificates),
        b: rollForwardEvent(Cardano.Slot(2), [])
      });
      expectObservable(source$.pipe(withCertificates())).toBe('ab', {
        a: {
          ...rollForwardEvent(Cardano.Slot(1), certificates),
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
          ...rollForwardEvent(Cardano.Slot(2), []),
          certificates: []
        }
      });
      expectSubscriptions(source$.subscriptions).toBe('^');
    });
  });

  it('flattens and reverses the order of all rolled back certificates', () => {
    createTestScheduler().run(({ hot, expectObservable, expectSubscriptions }) => {
      const source$ = hot<ProjectorEvent<{}, WithRolledBackEvents>>('a', {
        a: rollBackwardEvent([certificates])
      });
      expectObservable(source$.pipe(withCertificates())).toBe('a', {
        a: {
          ...rollBackwardEvent([certificates]),
          certificates: [
            {
              certificate: certificates[1][1],
              pointer: {
                certIndex: 1,
                slot: 0,
                txIndex: 1
              }
            },
            {
              certificate: certificates[1][0],
              pointer: {
                certIndex: 0,
                slot: 0,
                txIndex: 1
              }
            },
            {
              certificate: certificates[0][0],
              pointer: {
                certIndex: 0,
                slot: 0,
                txIndex: 0
              }
            }
          ]
        }
      });
      expectSubscriptions(source$.subscriptions).toBe('^');
    });
  });
});
