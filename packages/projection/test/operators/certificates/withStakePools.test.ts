/* eslint-disable unicorn/no-array-for-each */
import { Cardano, ChainSyncEventType } from '@cardano-sdk/core';
import {
  PoolRetirement,
  PoolUpdate,
  WithCertificateSource,
  withCertificates,
  withEpochNo,
  withRolledBackEvents,
  withStabilityWindow,
  withStakePools
} from '../../../src';
import { dataWithPoolRetirement } from '../../events';
import { genesisToEraSummary } from '../genesisToEraSummary';
import { lastValueFrom, tap } from 'rxjs';

describe('withStakePools', () => {
  it('can be used to keep track of stake pool registrations and retirements', async () => {
    const stakePools = new Map<
      Cardano.PoolId,
      {
        updates: PoolUpdate[];
        retirements: PoolRetirement[];
      }
    >();
    const findOrCreate = (poolId: Cardano.PoolId) => {
      let stakePool = stakePools.get(poolId);
      if (!stakePool) {
        stakePools.set(poolId, (stakePool = { retirements: [], updates: [] }));
      }
      return stakePool;
    };
    const project$ = dataWithPoolRetirement.chainSync$.pipe(
      withStabilityWindow(dataWithPoolRetirement.genesis),
      withRolledBackEvents(),
      withEpochNo([genesisToEraSummary(dataWithPoolRetirement.genesis)]),
      withCertificates(),
      withStakePools(),
      tap((evt) => {
        if (evt.eventType === ChainSyncEventType.RollForward) {
          for (const [poolId, poolUpdates] of evt.stakePools.updates) {
            findOrCreate(poolId).updates.push(...poolUpdates);
          }
          for (const [poolId, poolRetirements] of evt.stakePools.retirements) {
            findOrCreate(poolId).retirements.push(...poolRetirements);
          }
        } else {
          // delete all updates and retirements <= current tip
          const belowOrAtTip = ({ source }: WithCertificateSource) =>
            evt.tip !== 'origin' && source.slot <= evt.tip.slot;
          for (const [_, stakePool] of stakePools) {
            stakePool.updates = stakePool.updates.filter(belowOrAtTip);
            stakePool.retirements = stakePool.retirements.filter(belowOrAtTip);
          }
        }
      })
    );
    await lastValueFrom(project$);
    expect(stakePools.size).toBe(3);
    expect(
      stakePools.get(Cardano.PoolId('pool1n3s8unkvmre59uzt4ned0903f9q2p8dhscw5v9eeyc0sw0m439t'))!.updates
    ).toHaveLength(2);
    expect(
      stakePools.get(Cardano.PoolId('pool12pq2rzx8d7ern46udp6xrn0e0jaqt9hes9gs85hstp0egvfnf9q'))!.retirements
    ).toHaveLength(2);
  });
});
