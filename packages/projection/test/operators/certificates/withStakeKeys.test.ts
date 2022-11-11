/* eslint-disable unicorn/no-array-for-each */
import { Cardano } from '@cardano-sdk/core';
import { dataWithStakeKeyDeregistration } from '../../events';
import { lastValueFrom, tap } from 'rxjs';
import { withCertificates, withRolledBackEvents, withStabilityWindow, withStakeKeys } from '../../../src';

describe('withStakeKeys', () => {
  it('can be used to keep track of the current set of active stake keys', async () => {
    const activeStakeKeys = new Set<Cardano.Ed25519KeyHash>();
    const project$ = dataWithStakeKeyDeregistration.chainSync$.pipe(
      withStabilityWindow(dataWithStakeKeyDeregistration.genesis),
      withRolledBackEvents(),
      withCertificates(),
      withStakeKeys(),
      tap(({ stakeKeys: { register, deregister } }) => {
        register.forEach(activeStakeKeys.add.bind(activeStakeKeys));
        deregister.forEach(activeStakeKeys.delete.bind(activeStakeKeys));
      })
    );
    await lastValueFrom(project$);
    expect(activeStakeKeys).toEqual(
      new Set([Cardano.Ed25519KeyHash('3b62970858d61cf667701c1f34abef41659516b191d7d374e8b0857b')])
    );
  });
});
