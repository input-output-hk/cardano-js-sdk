/* eslint-disable unicorn/no-array-for-each */
import { Cardano, ChainSyncEventType } from '@cardano-sdk/core';
import { dataWithStakeKeyDeregistration } from '../../events';
import { defaultIfEmpty, lastValueFrom, mergeMap, tap } from 'rxjs';
import { operators, sinks } from '../../../src';

describe('withStakeKeys', () => {
  // TODO: current test is the same as in projectToSink.test.ts
  // This should be a unit test, without other operators.
  it('can be used to keep track of the current set of active stake keys', async () => {
    const activeStakeKeys = new Set<Cardano.Ed25519KeyHash>();
    const buffer = new sinks.InMemoryStabilityWindowBuffer(dataWithStakeKeyDeregistration.networkInfo);
    const project$ = dataWithStakeKeyDeregistration.chainSync({ points: ['origin'] }).pipe(
      mergeMap(({ chainSync$ }) => chainSync$),
      operators.withRolledBackBlock(buffer),
      tap((evt) => {
        evt;
      }),
      operators.withNetworkInfo(dataWithStakeKeyDeregistration.networkInfo),
      operators.withCertificates(),
      operators.withStakeKeys(),
      mergeMap((evt) => {
        const { stakeKeys: eventStakeKeys, eventType, requestNext } = evt;
        const operations =
          eventType === ChainSyncEventType.RollForward
            ? eventStakeKeys
            : {
                deregister: eventStakeKeys.register,
                register: eventStakeKeys.deregister
              };
        operations.register.forEach(activeStakeKeys.add.bind(activeStakeKeys));
        operations.deregister.forEach(activeStakeKeys.delete.bind(activeStakeKeys));
        return sinks.manageBuffer(evt, buffer).pipe(defaultIfEmpty(null), tap(requestNext));
      })
    );
    await lastValueFrom(project$);
    expect(activeStakeKeys).toEqual(
      new Set([Cardano.Ed25519KeyHash('3b62970858d61cf667701c1f34abef41659516b191d7d374e8b0857b')])
    );
  });
});
