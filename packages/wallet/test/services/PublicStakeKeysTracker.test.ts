import {
  AccountKeyDerivationPath,
  Bip32Account,
  GroupedAddress,
  KeyPurpose,
  KeyRole
} from '@cardano-sdk/key-management';
import { Cardano } from '@cardano-sdk/core';
import { ObservableWallet } from '../../src';
import { PubStakeKeyAndStatus, createPublicStakeKeysTracker } from '../../src/services/PublicStakeKeysTracker';
import { firstValueFrom, from, lastValueFrom, of, shareReplay, toArray } from 'rxjs';
import { mockProviders as mocks } from '@cardano-sdk/util-dev';

describe('PublicStakeKeysTracker', () => {
  let addresses: GroupedAddress[];
  let rewardAccounts: Cardano.RewardAccountInfo[];
  let bip32Account: Bip32Account;
  let derivePublicKey: jest.Mock;

  /** Assert multiple emissions from stakePubKey$ */
  const assertEmits = async (
    stakePubKeys$: ObservableWallet['publicStakeKeys$'],
    expectedEmissions: PubStakeKeyAndStatus[][]
    // eslint-disable-next-line unicorn/consistent-function-scoping
  ) => {
    const publicKeyEmissions = await lastValueFrom(stakePubKeys$.pipe(toArray()));
    expect(publicKeyEmissions).toEqual(expectedEmissions);
  };

  beforeEach(async () => {
    addresses = [
      {
        rewardAccount: mocks.rewardAccount,
        stakeKeyDerivationPath: { index: 0, role: KeyRole.Stake }
      },
      {
        rewardAccount: Cardano.RewardAccount('stake_test1upx9faamuf54pm7alg4lna5l7ll08pz833rj45tgr9m2jyceasqjt'),
        stakeKeyDerivationPath: { index: 1, role: KeyRole.Stake }
      },
      {
        rewardAccount: Cardano.RewardAccount('stake_test1uzksuwayv930mvkas0hfe5cdshtwszpp06nvjs9y6rtugmstddurm'),
        stakeKeyDerivationPath: { index: 2, role: KeyRole.Stake }
      },
      {
        rewardAccount: Cardano.RewardAccount('stake_test1uzfef3dmd0ykz9wfm3zx35pq4xdtla929hk6sx6tcen9h6s3vf52j'),
        stakeKeyDerivationPath: { index: 3, role: KeyRole.Stake }
      }
    ] as GroupedAddress[];

    rewardAccounts = [
      {
        address: addresses[0].rewardAccount!,
        credentialStatus: Cardano.StakeCredentialStatus.Registering,
        rewardBalance: 1_000_000n
      },
      {
        address: addresses[1].rewardAccount!,
        credentialStatus: Cardano.StakeCredentialStatus.Registered,
        rewardBalance: 1_000_000n
      },
      {
        address: addresses[2].rewardAccount!,
        credentialStatus: Cardano.StakeCredentialStatus.Unregistering,
        rewardBalance: 1_000_000n
      },
      {
        address: addresses[3].rewardAccount!,
        credentialStatus: Cardano.StakeCredentialStatus.Unregistered,
        rewardBalance: 1_000_000n
      }
    ];

    derivePublicKey = derivePublicKey = jest
      .fn()
      .mockImplementation((path: AccountKeyDerivationPath) => Promise.resolve({ hex: () => `abc-${path.index}` }));
    bip32Account = {
      accountIndex: 0,
      chainId: Cardano.ChainIds.Preview,
      deriveAddress: jest.fn(),
      derivePublicKey,
      extendedAccountPublicKey: '' as unknown,
      purpose: KeyPurpose.STANDARD
    } as Bip32Account;
  });

  it('empty array when there are no reward accounts', async () => {
    const addresses$ = of(addresses);
    const rewardAccounts$ = of([]);

    const stakePubKeys$ = createPublicStakeKeysTracker({
      addresses$,
      bip32Account,
      rewardAccounts$
    });

    const publicKeys = await firstValueFrom(stakePubKeys$);
    expect(publicKeys).toEqual([]);
  });

  it('emits derivation paths for all stake keys', async () => {
    const addresses$ = of(addresses);
    const rewardAccounts$ = of(rewardAccounts);

    const stakePubKeys$ = createPublicStakeKeysTracker({
      addresses$,
      bip32Account,
      rewardAccounts$
    });

    await assertEmits(stakePubKeys$, [
      [
        { credentialStatus: rewardAccounts[0].credentialStatus, publicStakeKey: 'abc-0' },
        { credentialStatus: rewardAccounts[1].credentialStatus, publicStakeKey: 'abc-1' },
        { credentialStatus: rewardAccounts[2].credentialStatus, publicStakeKey: 'abc-2' },
        { credentialStatus: rewardAccounts[3].credentialStatus, publicStakeKey: 'abc-3' }
      ] as PubStakeKeyAndStatus[]
    ]);
    expect(derivePublicKey).toHaveBeenCalledTimes(4);
    expect(derivePublicKey).toHaveBeenCalledWith(addresses[0].stakeKeyDerivationPath);
    expect(derivePublicKey).toHaveBeenCalledWith(addresses[1].stakeKeyDerivationPath);
    expect(derivePublicKey).toHaveBeenCalledWith(addresses[2].stakeKeyDerivationPath);
    expect(derivePublicKey).toHaveBeenCalledWith(addresses[3].stakeKeyDerivationPath);
  });

  it('ignores reward accounts that are not part of grouped addresses', async () => {
    addresses[0].rewardAccount = 'something-else' as Cardano.RewardAccount;
    const addresses$ = of(addresses);
    const rewardAccounts$ = of(rewardAccounts);

    const stakePubKeys$ = createPublicStakeKeysTracker({
      addresses$,
      bip32Account,
      rewardAccounts$
    });

    await assertEmits(stakePubKeys$, [
      [
        { credentialStatus: rewardAccounts[1].credentialStatus, publicStakeKey: 'abc-1' },
        { credentialStatus: rewardAccounts[2].credentialStatus, publicStakeKey: 'abc-2' },
        { credentialStatus: rewardAccounts[3].credentialStatus, publicStakeKey: 'abc-3' }
      ] as PubStakeKeyAndStatus[]
    ]);
  });

  it('emits when reward accounts change', async () => {
    const addresses$ = of(addresses);
    const rewardAccounts$ = from([[rewardAccounts[0]], rewardAccounts]);

    const stakePubKeys$ = createPublicStakeKeysTracker({
      addresses$,
      bip32Account,
      rewardAccounts$
    });

    await assertEmits(stakePubKeys$, [
      [{ credentialStatus: rewardAccounts[0].credentialStatus, publicStakeKey: 'abc-0' }],
      [
        { credentialStatus: rewardAccounts[0].credentialStatus, publicStakeKey: 'abc-0' },
        { credentialStatus: rewardAccounts[1].credentialStatus, publicStakeKey: 'abc-1' },
        { credentialStatus: rewardAccounts[2].credentialStatus, publicStakeKey: 'abc-2' },
        { credentialStatus: rewardAccounts[3].credentialStatus, publicStakeKey: 'abc-3' }
      ]
    ] as PubStakeKeyAndStatus[][]);
  });

  it('emits when addresses change', async () => {
    const addresses$ = from([[addresses[0]], addresses]);
    const rewardAccounts$ = of(rewardAccounts);

    const stakePubKeys$ = createPublicStakeKeysTracker({
      addresses$,
      bip32Account,
      rewardAccounts$
    });

    await assertEmits(stakePubKeys$, [
      [{ credentialStatus: rewardAccounts[0].credentialStatus, publicStakeKey: 'abc-0' }],
      [
        { credentialStatus: rewardAccounts[0].credentialStatus, publicStakeKey: 'abc-0' },
        { credentialStatus: rewardAccounts[1].credentialStatus, publicStakeKey: 'abc-1' },
        { credentialStatus: rewardAccounts[2].credentialStatus, publicStakeKey: 'abc-2' },
        { credentialStatus: rewardAccounts[3].credentialStatus, publicStakeKey: 'abc-3' }
      ]
    ] as PubStakeKeyAndStatus[][]);
  });

  it('does not emit duplicates', async () => {
    const rewardAccounts$ = from([rewardAccounts, rewardAccounts]);
    const addresses$ = from([[addresses[0]], addresses, addresses]).pipe(
      shareReplay({ bufferSize: 1, refCount: true })
    );

    const stakePubKeys$ = createPublicStakeKeysTracker({
      addresses$,
      bip32Account,
      rewardAccounts$
    });

    await assertEmits(stakePubKeys$, [
      [{ credentialStatus: rewardAccounts[0].credentialStatus, publicStakeKey: 'abc-0' }],
      [
        { credentialStatus: rewardAccounts[0].credentialStatus, publicStakeKey: 'abc-0' },
        { credentialStatus: rewardAccounts[1].credentialStatus, publicStakeKey: 'abc-1' },
        { credentialStatus: rewardAccounts[2].credentialStatus, publicStakeKey: 'abc-2' },
        { credentialStatus: rewardAccounts[3].credentialStatus, publicStakeKey: 'abc-3' }
      ]
    ] as PubStakeKeyAndStatus[][]);
  });
});
