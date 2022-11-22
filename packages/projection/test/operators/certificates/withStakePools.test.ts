/* eslint-disable unicorn/no-array-for-each */
import { Cardano, ChainSyncEventType } from '@cardano-sdk/core';
import { dataWithPoolRetirement } from '../../events';
import { defaultIfEmpty, lastValueFrom, mergeMap, tap } from 'rxjs';
import { operators, sinks } from '../../../src';

describe('withStakePools', () => {
  // TODO: current test is the same as in projectToSink.test.ts
  // This should be a unit test, without other operators.
  it('can be used to keep track of stake pool registrations and retirements', async () => {
    const stakePools = new Map<
      Cardano.PoolId,
      {
        updates: operators.PoolUpdate[];
        retirements: operators.PoolRetirement[];
      }
    >();
    const findOrCreate = (poolId: Cardano.PoolId) => {
      let stakePool = stakePools.get(poolId);
      if (!stakePool) {
        stakePools.set(poolId, (stakePool = { retirements: [], updates: [] }));
      }
      return stakePool;
    };
    const buffer = new sinks.InMemoryStabilityWindowBuffer(dataWithPoolRetirement.networkInfo);
    const project$ = dataWithPoolRetirement.chainSync({ points: ['origin'] }).pipe(
      mergeMap(({ chainSync$ }) => chainSync$),
      operators.withRolledBackBlock(buffer),
      operators.withNetworkInfo(dataWithPoolRetirement.networkInfo),
      operators.withEpochNo(),
      operators.withCertificates(),
      operators.withStakePools(),
      mergeMap((evt) => {
        if (evt.eventType === ChainSyncEventType.RollForward) {
          for (const [poolId, poolUpdates] of evt.stakePools.updates) {
            findOrCreate(poolId).updates.push(...poolUpdates);
          }
          for (const [poolId, poolRetirements] of evt.stakePools.retirements) {
            findOrCreate(poolId).retirements.push(...poolRetirements);
          }
        } else {
          // delete all updates and retirements <= current tip
          const belowOrAtTip = ({ source }: operators.WithCertificateSource) =>
            evt.tip !== 'origin' && source.slot <= evt.tip.slot;
          for (const [_, stakePool] of stakePools) {
            stakePool.updates = stakePool.updates.filter(belowOrAtTip);
            stakePool.retirements = stakePool.retirements.filter(belowOrAtTip);
          }
        }
        return sinks.manageBuffer(evt, buffer).pipe(defaultIfEmpty(null), tap(evt.requestNext));
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
