import { AccountKeyDerivationPath, AsyncKeyAgent, GroupedAddress, KeyRole } from '@cardano-sdk/key-management';
import { Cardano } from '@cardano-sdk/core';
import { ObservableWallet } from '../../src';
import { createActivePublicStakeKeysTracker } from '../../src/services/ActiveStakePublicKeysTracker';
import { firstValueFrom, from, lastValueFrom, of, shareReplay, toArray } from 'rxjs';
import { mockProviders as mocks } from '@cardano-sdk/util-dev';

describe('ActivePublicStakeKeysTracker', () => {
  let addresses: GroupedAddress[];
  let rewardAccounts: Cardano.RewardAccountInfo[];
  let keyAgent: AsyncKeyAgent;
  let derivePublicKey: jest.Mock;

  /** Assert multiple emissions from stakePubKey$ */
  const assertEmits = async (
    stakePubKeys$: ObservableWallet['activePublicStakeKeys$'],
    expectedEmissions: string[][]
    // eslint-disable-next-line unicorn/consistent-function-scoping
  ) => {
    const publicKeyEmissions = await lastValueFrom(stakePubKeys$.pipe(toArray()));
    expect(publicKeyEmissions).toEqual(expectedEmissions);
  };

  beforeEach(() => {
    addresses = [
      {
        rewardAccount: mocks.rewardAccount,
        stakeKeyDerivationPath: { index: 0, role: KeyRole.Stake }
      },
      {
        rewardAccount: Cardano.RewardAccount('stake_test1upx9faamuf54pm7alg4lna5l7ll08pz833rj45tgr9m2jyceasqjt'),
        stakeKeyDerivationPath: { index: 1, role: KeyRole.Stake }
      }
    ] as GroupedAddress[];

    rewardAccounts = [
      {
        address: addresses[0].rewardAccount!,
        keyStatus: Cardano.StakeKeyStatus.Registered,
        rewardBalance: 1_000_000n
      },
      {
        address: addresses[1].rewardAccount!,
        keyStatus: Cardano.StakeKeyStatus.Registered,
        rewardBalance: 1_000_000n
      }
    ];

    derivePublicKey = jest
      .fn()
      .mockImplementation((path: AccountKeyDerivationPath) => Promise.resolve(`abc-${path.index}`));
    keyAgent = {
      derivePublicKey
    } as unknown as AsyncKeyAgent;
  });

  it('empty array when there are no reward accounts', async () => {
    const addresses$ = of([]);
    const rewardAccounts$ = of([]);

    const stakePubKeys$ = createActivePublicStakeKeysTracker({
      addresses$,
      keyAgent,
      rewardAccounts$
    });

    const publicKeys = await firstValueFrom(stakePubKeys$);
    expect(publicKeys).toEqual([]);
  });

  it('emits derivation paths for all active keys', async () => {
    const addresses$ = of(addresses);
    const rewardAccounts$ = of(rewardAccounts);

    const stakePubKeys$ = createActivePublicStakeKeysTracker({
      addresses$,
      keyAgent,
      rewardAccounts$
    });

    const publicKeys = await firstValueFrom(stakePubKeys$);
    expect(publicKeys).toEqual(['abc-0', 'abc-1']);
    expect(derivePublicKey).toHaveBeenCalledTimes(2);
    expect(derivePublicKey).toHaveBeenCalledWith(addresses[0].stakeKeyDerivationPath);
    expect(derivePublicKey).toHaveBeenCalledWith(addresses[1].stakeKeyDerivationPath);
  });

  it('ignores stake keys that are not registered', async () => {
    const addresses$ = of(addresses);

    rewardAccounts[0].keyStatus = Cardano.StakeKeyStatus.Unregistered;
    const rewardAccounts$ = of(rewardAccounts);

    const stakePubKeys$ = createActivePublicStakeKeysTracker({
      addresses$,
      keyAgent,
      rewardAccounts$
    });

    const publicKeys = await firstValueFrom(stakePubKeys$);
    expect(publicKeys).toEqual(['abc-1']);
    expect(derivePublicKey).toHaveBeenCalledTimes(1);
    expect(derivePublicKey).toHaveBeenCalledWith(addresses[1].stakeKeyDerivationPath);
  });

  it('ignores reward accounts that are not part of grouped addresses', async () => {
    addresses[0].rewardAccount = 'something-else' as Cardano.RewardAccount;
    const addresses$ = of(addresses);
    const rewardAccounts$ = of(rewardAccounts);

    const stakePubKeys$ = createActivePublicStakeKeysTracker({
      addresses$,
      keyAgent,
      rewardAccounts$
    });

    const publicKeys = await firstValueFrom(stakePubKeys$);
    expect(publicKeys).toEqual(['abc-1']);
    expect(derivePublicKey).toHaveBeenCalledTimes(1);
    expect(derivePublicKey).toHaveBeenCalledWith(addresses[1].stakeKeyDerivationPath);
  });

  it('emits when reward accounts change', async () => {
    const addresses$ = of(addresses);
    const rewardAccounts$ = from([[rewardAccounts[0]], rewardAccounts]);

    const stakePubKeys$ = createActivePublicStakeKeysTracker({
      addresses$,
      keyAgent,
      rewardAccounts$
    });

    await assertEmits(stakePubKeys$, [['abc-0'], ['abc-0', 'abc-1']]);
  });

  it('emits when addresses change', async () => {
    const addresses$ = from([[addresses[0]], addresses]);
    const rewardAccounts$ = of(rewardAccounts);

    const stakePubKeys$ = createActivePublicStakeKeysTracker({
      addresses$,
      keyAgent,
      rewardAccounts$
    });

    await assertEmits(stakePubKeys$, [['abc-0'], ['abc-0', 'abc-1']]);
  });

  it('does not emit duplicates', async () => {
    const rewardAccounts$ = from([rewardAccounts, rewardAccounts]);
    const addresses$ = from([[addresses[0]], addresses, addresses]).pipe(
      shareReplay({ bufferSize: 1, refCount: true })
    );

    const stakePubKeys$ = createActivePublicStakeKeysTracker({
      addresses$,
      keyAgent,
      rewardAccounts$
    });

    await assertEmits(stakePubKeys$, [['abc-0'], ['abc-0', 'abc-1']]);
  });
});
