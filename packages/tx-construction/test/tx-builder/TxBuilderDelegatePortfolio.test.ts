/* eslint-disable sonarjs/no-duplicate-string */
import * as Crypto from '@cardano-sdk/crypto';
import { AddressType, GroupedAddress, InMemoryKeyAgent, util } from '@cardano-sdk/key-management';
import { CML, Cardano } from '@cardano-sdk/core';
import {
  GenericTxBuilder,
  OutOfSyncRewardAccounts,
  OutputValidation,
  RewardAccountWithPoolId,
  TxBuilderProviders,
  TxInspection
} from '../../src';
import { GreedyInputSelector, GreedySelectorProps, roundRobinRandomImprove } from '@cardano-sdk/input-selection';
import { dummyLogger } from 'ts-log';
import { mockProviders as mocks } from '@cardano-sdk/util-dev';
import uniqBy from 'lodash/uniqBy';

jest.mock('@cardano-sdk/input-selection', () => {
  const actual = jest.requireActual('@cardano-sdk/input-selection');
  return {
    ...actual,
    GreedyInputSelector: jest.fn((args) => new actual.GreedyInputSelector(args)),
    roundRobinRandomImprove: jest.fn((args) => actual.roundRobinRandomImprove(args))
  };
});

const expectGreedyInputSelectorWith = async (changeAddressesDistrib: Map<Cardano.PaymentAddress, number>) => {
  expect(GreedyInputSelector).toHaveBeenCalled();
  const greedySelectorProps: GreedySelectorProps = (GreedyInputSelector as jest.Mock).mock.calls[0][0];
  const changeAddresses = await greedySelectorProps.getChangeAddresses();
  expect(changeAddresses).toEqual(changeAddressesDistrib);
};

const inputResolver: Cardano.InputResolver = {
  resolveInput: async (txIn) =>
    mocks.utxo.find(([hydratedTxIn]) => txIn.txId === hydratedTxIn.txId && txIn.index === hydratedTxIn.index)?.[1] ||
    null
};

/**
 * Utility factory for tests to create a GenericTxBuilder with mocked dependencies
 *
 * @param stakeKeyDelegations for each entry it derives an address + a stake key. Reward accounts are created from the stake keys.
 *  Depending on the `keyStatus`, it configures the reward accounts to be registered, unregistered or delegated to a poolId
 * @param useMultiplePaymentKeys simulates 2 addresses per stake key (HD wallet). If enabled, groupedAddresses will have 2 entries per stake key.
 * @returns the txBuilder, groupedAddresses and other information useful in tests.
 */

const createTxBuilder = async ({
  stakeKeyDelegations,
  useMultiplePaymentKeys = false,
  rewardAccounts,
  keyAgent
}: {
  stakeKeyDelegations: { keyStatus: Cardano.StakeKeyStatus; poolId?: Cardano.PoolId }[];
  useMultiplePaymentKeys?: boolean;
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  rewardAccounts?: any;
  keyAgent: InMemoryKeyAgent;
}) => {
  let groupedAddresses = await Promise.all(
    stakeKeyDelegations.map(async (_, idx) => keyAgent.deriveAddress({ index: 0, type: AddressType.External }, idx))
  );

  // Simulate an HD wallet where a each stake key partitions 2 payment keys (2 addresses per stake key)
  if (useMultiplePaymentKeys) {
    const groupedAddresses2 = await Promise.all(
      stakeKeyDelegations.map(async (_, idx) => keyAgent.deriveAddress({ index: 1, type: AddressType.External }, idx))
    );
    groupedAddresses = [...groupedAddresses, ...groupedAddresses2];
  }

  const txBuilderProviders: jest.Mocked<TxBuilderProviders> = {
    genesisParameters: jest.fn().mockResolvedValue(mocks.genesisParameters),
    protocolParameters: jest.fn().mockResolvedValue(mocks.protocolParameters),
    rewardAccounts:
      rewardAccounts ||
      jest.fn().mockImplementation(() =>
        Promise.resolve(
          // There can be multiple addresses with the same reward account. Extract the uniq reward accounts
          uniqBy(keyAgent.knownAddresses, ({ rewardAccount }) => rewardAccount)
            // Create mock stakeKey/delegation status for each reward account according to the requested stakeKeyDelegations.
            // This would normally be done by the wallet.delegation.rewardAccounts
            .map<RewardAccountWithPoolId>(({ rewardAccount: address }, index) => {
              const { keyStatus, poolId } = stakeKeyDelegations[index] ?? {};
              return {
                address,
                keyStatus: keyStatus ?? Cardano.StakeKeyStatus.Unregistered,
                rewardBalance: mocks.rewardAccountBalance,
                ...(poolId ? { delegatee: { nextNextEpoch: { id: poolId } } } : undefined)
              };
            })
        )
      ),
    tip: jest.fn().mockResolvedValue(mocks.ledgerTip),
    utxoAvailable: jest.fn().mockResolvedValue(mocks.utxo)
  };
  const outputValidator = {
    validateOutput: jest.fn().mockResolvedValue({ coinMissing: 0n } as OutputValidation)
  };
  return {
    groupedAddresses,
    txBuilder: new GenericTxBuilder({
      inputResolver,
      keyAgent: util.createAsyncKeyAgent(keyAgent),
      logger: dummyLogger,
      outputValidator,
      txBuilderProviders
    }),
    txBuilderProviders
  };
};

describe('TxBuilder/delegatePortfolio', () => {
  const poolIds: Cardano.PoolId[] = [
    Cardano.PoolId('pool1zuevzm3xlrhmwjw87ec38mzs02tlkwec9wxpgafcaykmwg7efhh'),
    Cardano.PoolId('pool1t9xlrjyk76c96jltaspgwcnulq6pdkmhnge8xgza8ku7qvpsy9r'),
    Cardano.PoolId('pool1la4ghj4w4f8p4yk4qmx0qvqmzv6592ee9rs0vgla5w6lc2nc8w5'),
    Cardano.PoolId('pool1lu6ll4rcxm92059ggy6uym2p804s5hcwqyyn5vyqhy35kuxtn2f')
  ];
  let txBuilder: GenericTxBuilder;
  let groupedAddresses: GroupedAddress[];
  let keyAgent: InMemoryKeyAgent;

  beforeEach(async () => {
    keyAgent = await InMemoryKeyAgent.fromBip39MnemonicWords(
      {
        chainId: Cardano.ChainIds.Preprod,
        getPassphrase: async () => Buffer.from('passphrase'),
        mnemonicWords: util.generateMnemonicWords()
      },
      { bip32Ed25519: new Crypto.CmlBip32Ed25519(CML), inputResolver, logger: dummyLogger }
    );
  });

  afterEach(() => jest.clearAllMocks());

  describe('single reward account', () => {
    beforeEach(async () => {
      const txBuilderFactory = await createTxBuilder({
        keyAgent,
        stakeKeyDelegations: [{ keyStatus: Cardano.StakeKeyStatus.Unregistered }]
      });
      groupedAddresses = txBuilderFactory.groupedAddresses;
      txBuilder = txBuilderFactory.txBuilder;
    });

    it('uses random improve input selector when delegating to a single pool', async () => {
      const tx = await txBuilder
        .delegatePortfolio({
          name: 'Tests Portfolio',
          pools: [{ id: Cardano.PoolIdHex(Cardano.PoolId.toKeyHash(poolIds[0])), weight: 1 }]
        })
        .build()
        .inspect();

      expect(tx.body.certificates?.length).toBe(2);
      expect(tx.body.certificates).toContainEqual<Cardano.Certificate>({
        __typename: Cardano.CertificateType.StakeKeyRegistration,
        stakeKeyHash: Cardano.RewardAccount.toHash(groupedAddresses[0].rewardAccount)
      });
      expect(tx.body.certificates).toContainEqual({
        __typename: Cardano.CertificateType.StakeDelegation,
        poolId: poolIds[0],
        stakeKeyHash: Cardano.RewardAccount.toHash(groupedAddresses[0].rewardAccount)
      });

      expect(GreedyInputSelector).not.toHaveBeenCalled();
      expect(roundRobinRandomImprove).toHaveBeenCalled();
    });
  });

  describe('input selection type with multiple reward accounts and single pool delegation', () => {
    beforeEach(async () => {
      const txBuilderFactory = await createTxBuilder({
        keyAgent,
        stakeKeyDelegations: [
          { keyStatus: Cardano.StakeKeyStatus.Registered },
          { keyStatus: Cardano.StakeKeyStatus.Unregistered }
        ]
      });
      groupedAddresses = txBuilderFactory.groupedAddresses;
      txBuilder = txBuilderFactory.txBuilder;
    });

    it('uses roundRobinRandomImprove when only one reward account is registered', async () => {
      await txBuilder
        .delegatePortfolio({
          name: 'Tests Portfolio',
          pools: [
            {
              id: Cardano.PoolIdHex(Cardano.PoolId.toKeyHash(poolIds[0])),
              weight: 1
            }
          ]
        })
        .build()
        .inspect();

      expect(GreedyInputSelector).not.toHaveBeenCalled();
      expect(roundRobinRandomImprove).toHaveBeenCalled();
    });
  });

  describe('no previous delegations, multiple addresses per stake key', () => {
    beforeEach(async () => {
      const txBuilderFactory = await createTxBuilder({
        keyAgent,
        stakeKeyDelegations: [
          { keyStatus: Cardano.StakeKeyStatus.Unregistered },
          { keyStatus: Cardano.StakeKeyStatus.Unregistered }
        ],
        useMultiplePaymentKeys: true
      });
      groupedAddresses = txBuilderFactory.groupedAddresses;
      txBuilder = txBuilderFactory.txBuilder;
    });

    it('null portfolio does not add certificates', async () => {
      const tx = await txBuilder.delegatePortfolio(null).build().inspect();
      expect(tx.body.certificates?.length).toBeFalsy();
      expect(GreedyInputSelector).not.toHaveBeenCalled();
    });

    describe('transaction outputs and multi-delegation portfolio', () => {
      let tx: TxInspection;
      let output: Cardano.TxOut;

      beforeEach(async () => {
        output = { address: groupedAddresses[3].address, value: { coins: 10n } };
        tx = await txBuilder
          .delegatePortfolio({
            name: 'Tests Portfolio',
            pools: [
              {
                id: Cardano.PoolIdHex(Cardano.PoolId.toKeyHash(poolIds[0])),
                weight: 1
              },
              {
                id: Cardano.PoolIdHex(Cardano.PoolId.toKeyHash(poolIds[1])),
                weight: 2
              }
            ]
          })
          .addOutput(txBuilder.buildOutput(output).toTxOut())
          .build()
          .inspect();
      });

      it('adds delegation certificates', () => {
        expect(tx.body.certificates?.length).toBe(4);
        expect(tx.body.certificates).toContainEqual<Cardano.Certificate>(
          Cardano.createStakeKeyRegistrationCert(groupedAddresses[0].rewardAccount)
        );
        expect(tx.body.certificates).toContainEqual(
          Cardano.createDelegationCert(groupedAddresses[0].rewardAccount, poolIds[0])
        );
        expect(tx.body.certificates).toContainEqual(
          Cardano.createStakeKeyRegistrationCert(groupedAddresses[1].rewardAccount)
        );
        expect(tx.body.certificates).toContainEqual(
          Cardano.createDelegationCert(groupedAddresses[1].rewardAccount, poolIds[1])
        );
      });

      it(`configures only the first address per stake key as
          change address with configured weights using greedy input selector`, async () => {
        await expectGreedyInputSelectorWith(
          new Map([
            [groupedAddresses[0].address, 1],
            [groupedAddresses[1].address, 2]
          ])
        );
      });

      it('adds the configured outputs', async () => {
        expect(tx.body.outputs[0]).toEqual(output);
      });
    });
  });

  describe('pre-existing multi-delegation on all stake keys', () => {
    let txBuilderProviders: jest.Mocked<TxBuilderProviders>;
    beforeEach(async () => {
      const txBuilderFactory = await createTxBuilder({
        keyAgent,
        stakeKeyDelegations: [
          { keyStatus: Cardano.StakeKeyStatus.Registered, poolId: poolIds[0] },
          { keyStatus: Cardano.StakeKeyStatus.Registered, poolId: poolIds[1] }
        ]
      });
      groupedAddresses = txBuilderFactory.groupedAddresses;
      txBuilder = txBuilderFactory.txBuilder;
      txBuilderProviders = txBuilderFactory.txBuilderProviders;
    });

    it('null portfolio de-registers all stake keys, and uses random improve input selector', async () => {
      const tx = await txBuilder.delegatePortfolio(null).build().inspect();
      expect(tx.body.certificates?.length).toBe(2);
      expect(tx.body.certificates).toContainEqual(
        Cardano.createStakeKeyDeregistrationCert(groupedAddresses[0].rewardAccount)
      );
      expect(tx.body.certificates).toContainEqual(
        Cardano.createStakeKeyDeregistrationCert(groupedAddresses[1].rewardAccount)
      );

      expect(GreedyInputSelector).not.toHaveBeenCalled();
      expect(roundRobinRandomImprove).toHaveBeenCalled();
    });

    it('does not change delegations when portfolio already satisfied, but updates distribution', async () => {
      const tx = await txBuilder
        .delegatePortfolio({
          name: 'Tests Portfolio',
          pools: [
            {
              id: Cardano.PoolIdHex(Cardano.PoolId.toKeyHash(poolIds[0])),
              weight: 20
            },
            {
              id: Cardano.PoolIdHex(Cardano.PoolId.toKeyHash(poolIds[1])),
              weight: 10
            }
          ]
        })
        .build()
        .inspect();

      expect(tx.body.certificates?.length).toBeFalsy();

      await expectGreedyInputSelectorWith(
        new Map([
          [groupedAddresses[0].address, 20],
          [groupedAddresses[1].address, 10]
        ])
      );
    });

    it(`creates certificate to change delegation when one pool matches while the other was changed,
        and updates change addresses distribution`, async () => {
      const tx = await txBuilder
        .delegatePortfolio({
          name: 'Tests Portfolio',
          pools: [
            {
              id: Cardano.PoolIdHex(Cardano.PoolId.toKeyHash(poolIds[2])),
              weight: 95
            },
            {
              id: Cardano.PoolIdHex(Cardano.PoolId.toKeyHash(poolIds[1])),
              weight: 5
            }
          ]
        })
        .build()
        .inspect();

      expect(tx.body.certificates?.length).toBe(1);
      expect(tx.body.certificates![0]).toEqual(
        Cardano.createDelegationCert(groupedAddresses[0].rewardAccount, poolIds[2])
      );

      await expectGreedyInputSelectorWith(
        new Map([
          [groupedAddresses[0].address, 95],
          [groupedAddresses[1].address, 5]
        ])
      );
    });

    it(`portfolio is subset: adds stake deregistration certificates
         for the delegations that are no longer in the portfolio,
         and configures change addresses so funds go to the delegated address`, async () => {
      const tx = await txBuilder
        .delegatePortfolio({
          name: 'Tests Portfolio',
          pools: [
            {
              id: Cardano.PoolIdHex(Cardano.PoolId.toKeyHash(poolIds[1])),
              weight: 1
            }
          ]
        })
        .build()
        .inspect();

      expect(tx.body.certificates?.length).toBe(1);
      expect(tx.body.certificates![0]).toEqual(
        Cardano.createStakeKeyDeregistrationCert(groupedAddresses[0].rewardAccount)
      );

      await expectGreedyInputSelectorWith(new Map([[groupedAddresses[1].address, 1]]));
    });

    it('portfolio with empty pools array is not a valid CIP17 portfolio', () => {
      expect(() => txBuilder.delegatePortfolio({ name: 'Tests Portfolio', pools: [] })).toThrow();
    });

    it('derives more stake keys when portfolio has more pools than available keys', async () => {
      const pools = poolIds.slice(0, 3);
      const tx = await txBuilder
        .delegatePortfolio({
          name: 'Tests Portfolio',
          pools: pools.map((pool) => ({ id: Cardano.PoolIdHex(Cardano.PoolId.toKeyHash(pool)), weight: 1 }))
        })
        .build()
        .inspect();

      const rewardAccounts = await txBuilderProviders.rewardAccounts();

      expect(tx.body.certificates).toEqual([
        Cardano.createStakeKeyRegistrationCert(rewardAccounts[2].address),
        Cardano.createDelegationCert(rewardAccounts[2].address, poolIds[2])
      ]);
    });
  });

  describe('partial pre-existing multi-delegation', () => {
    beforeEach(async () => {
      const txBuilderFactory = await createTxBuilder({
        keyAgent,
        stakeKeyDelegations: [
          { keyStatus: Cardano.StakeKeyStatus.Registered, poolId: poolIds[0] },
          { keyStatus: Cardano.StakeKeyStatus.Registered }
        ]
      });
      groupedAddresses = txBuilderFactory.groupedAddresses;
      txBuilder = txBuilderFactory.txBuilder;
    });

    it('portfolio is superset: adds certificates for the new delegations', async () => {
      const tx = await txBuilder
        .delegatePortfolio({
          name: 'Tests Portfolio',
          pools: [
            {
              id: Cardano.PoolIdHex(Cardano.PoolId.toKeyHash(poolIds[0])),
              weight: 3
            },
            {
              id: Cardano.PoolIdHex(Cardano.PoolId.toKeyHash(poolIds[1])),
              weight: 7
            }
          ]
        })
        .build()
        .inspect();

      expect(tx.body.certificates?.length).toBe(1);
      expect(tx.body.certificates![0]).toEqual(
        Cardano.createDelegationCert(groupedAddresses[1].rewardAccount, poolIds[1])
      );

      await expectGreedyInputSelectorWith(
        new Map([
          [groupedAddresses[0].address, 3],
          [groupedAddresses[1].address, 7]
        ])
      );
    });

    it('changes delegation and deregisters stake keys that are not delegated', async () => {
      const tx = await txBuilder
        .delegatePortfolio({
          name: 'Tests Portfolio',
          pools: [
            {
              id: Cardano.PoolIdHex(Cardano.PoolId.toKeyHash(poolIds[2])),
              weight: 5
            }
          ]
        })
        .build()
        .inspect();

      expect(tx.body.certificates?.length).toBe(2);
      expect(tx.body.certificates).toContainEqual(
        Cardano.createDelegationCert(groupedAddresses[0].rewardAccount, poolIds[2])
      );
      expect(tx.body.certificates).toContainEqual(
        Cardano.createStakeKeyDeregistrationCert(groupedAddresses[1].rewardAccount)
      );

      await expectGreedyInputSelectorWith(new Map([[groupedAddresses[0].address, 5]]));
    });
  });

  describe('rewardAccount selection', () => {
    const portfolio: Cardano.Cip17DelegationPortfolio = {
      name: 'Tests Portfolio',
      pools: [{ id: Cardano.PoolIdHex(Cardano.PoolId.toKeyHash(poolIds[0])), weight: 1 }]
    };

    it('uses first one when all stake keys are unregistered', async () => {
      const txBuilderFactory = await createTxBuilder({
        keyAgent,
        stakeKeyDelegations: [
          { keyStatus: Cardano.StakeKeyStatus.Unregistered },
          { keyStatus: Cardano.StakeKeyStatus.Unregistered }
        ]
      });
      groupedAddresses = txBuilderFactory.groupedAddresses;
      txBuilder = txBuilderFactory.txBuilder;

      const firstStakeKeyHash = Cardano.RewardAccount.toHash(groupedAddresses[0].rewardAccount);

      const tx = await txBuilder.delegatePortfolio(portfolio).build().inspect();

      const certs = tx.body.certificates;
      expect(certs?.length).toBe(2);
      expect((certs![1] as Cardano.StakeDelegationCertificate).stakeKeyHash).toEqual(firstStakeKeyHash);
    });

    it('uses first one when all stake keys are registered', async () => {
      const txBuilderFactory = await createTxBuilder({
        keyAgent,
        stakeKeyDelegations: [
          { keyStatus: Cardano.StakeKeyStatus.Registered },
          { keyStatus: Cardano.StakeKeyStatus.Registered }
        ]
      });
      groupedAddresses = txBuilderFactory.groupedAddresses;
      txBuilder = txBuilderFactory.txBuilder;

      const tx = await txBuilder.delegatePortfolio(portfolio).build().inspect();

      const certs = tx.body.certificates as Cardano.StakeDelegationCertificate[];
      expect(certs.length).toBe(2);
      expect(certs).toEqual<Cardano.Certificate[]>([
        Cardano.createDelegationCert(groupedAddresses[0].rewardAccount, poolIds[0]),
        Cardano.createStakeKeyDeregistrationCert(groupedAddresses[1].rewardAccount)
      ]);
    });

    it('uses stake keys in order when changing delegation', async () => {
      const txBuilderFactory = await createTxBuilder({
        keyAgent,
        stakeKeyDelegations: [
          { keyStatus: Cardano.StakeKeyStatus.Registered, poolId: poolIds[0] },
          { keyStatus: Cardano.StakeKeyStatus.Registered, poolId: poolIds[1] }
        ]
      });
      groupedAddresses = txBuilderFactory.groupedAddresses;
      txBuilder = txBuilderFactory.txBuilder;

      const firstStakeKeyHash = Cardano.RewardAccount.toHash(groupedAddresses[0].rewardAccount);
      const secondStakeKeyHash = Cardano.RewardAccount.toHash(groupedAddresses[1].rewardAccount);

      const tx = await txBuilder
        .delegatePortfolio({
          name: 'Tests Portfolio',
          pools: [
            { id: Cardano.PoolIdHex(Cardano.PoolId.toKeyHash(poolIds[2])), weight: 1 },
            { id: Cardano.PoolIdHex(Cardano.PoolId.toKeyHash(poolIds[3])), weight: 1 }
          ]
        })
        .build()
        .inspect();

      const certs = tx.body.certificates as Cardano.StakeDelegationCertificate[];
      expect(certs.length).toBe(2);
      expect(certs[0].stakeKeyHash).toEqual(firstStakeKeyHash);
      expect(certs[1].stakeKeyHash).toEqual(secondStakeKeyHash);
    });

    it('uses registered stake keys over unregistered ones', async () => {
      const txBuilderFactory = await createTxBuilder({
        keyAgent,
        stakeKeyDelegations: [
          { keyStatus: Cardano.StakeKeyStatus.Unregistered },
          { keyStatus: Cardano.StakeKeyStatus.Registered }
        ]
      });
      groupedAddresses = txBuilderFactory.groupedAddresses;
      txBuilder = txBuilderFactory.txBuilder;

      const secondStakeKeyHash = Cardano.RewardAccount.toHash(groupedAddresses[1].rewardAccount);

      const tx = await txBuilder.delegatePortfolio(portfolio).build().inspect();

      const certs = tx.body.certificates as Cardano.StakeDelegationCertificate[];
      expect(certs.length).toBe(1);
      expect(certs[0].stakeKeyHash).toEqual(secondStakeKeyHash);
    });

    it('reuses delegated stake keys instead of registering new ones', async () => {
      const txBuilderFactory = await createTxBuilder({
        keyAgent,
        stakeKeyDelegations: [
          { keyStatus: Cardano.StakeKeyStatus.Registered },
          { keyStatus: Cardano.StakeKeyStatus.Registered, poolId: poolIds[1] }
        ]
      });
      groupedAddresses = txBuilderFactory.groupedAddresses;
      txBuilder = txBuilderFactory.txBuilder;

      const tx = await txBuilder.delegatePortfolio(portfolio).build().inspect();

      const certs = tx.body.certificates as Cardano.StakeDelegationCertificate[];
      expect(certs.length).toBe(2);
      expect(certs).toEqual<Cardano.Certificate[]>([
        Cardano.createDelegationCert(groupedAddresses[1].rewardAccount, poolIds[0]),
        Cardano.createStakeKeyDeregistrationCert(groupedAddresses[0].rewardAccount)
      ]);
    });
  });

  describe('rewardAccount syncing', () => {
    const normalRewardAccountsCalls = 3;
    it('can wait for delayed key agent stake keys', async () => {
      await keyAgent.deriveAddress({ index: 0, type: AddressType.External }, 0);
      const rewardAccountsProvider = jest
        .fn()
        .mockResolvedValueOnce([])
        .mockResolvedValueOnce([])
        .mockResolvedValueOnce([])
        .mockImplementation(() =>
          Promise.resolve(
            keyAgent.knownAddresses.map<RewardAccountWithPoolId>(({ rewardAccount: address }) => ({
              address,
              keyStatus: Cardano.StakeKeyStatus.Unregistered,
              rewardBalance: mocks.rewardAccountBalance
            }))
          )
        );
      const txBuilderFactory = await createTxBuilder({
        keyAgent,
        rewardAccounts: rewardAccountsProvider,
        stakeKeyDelegations: []
      });

      txBuilder = txBuilderFactory.txBuilder;

      await expect(
        txBuilder
          .delegatePortfolio({
            name: 'Tests Portfolio',
            pools: [{ id: Cardano.PoolIdHex(Cardano.PoolId.toKeyHash(poolIds[0])), weight: 1 }]
          })
          .build()
          .inspect()
      ).resolves.toBeTruthy();

      // Expect 3 retries
      expect(rewardAccountsProvider.mock.calls.length).toBe(normalRewardAccountsCalls + 3);
    });

    it('throws if new stake keys are not part of reward accounts in a reasonable time', async () => {
      await keyAgent.deriveAddress({ index: 0, type: AddressType.External }, 0);
      const rewardAccountsProvider = jest.fn().mockResolvedValue([]);
      const txBuilderFactory = await createTxBuilder({
        keyAgent,
        rewardAccounts: rewardAccountsProvider,
        stakeKeyDelegations: []
      });

      txBuilder = txBuilderFactory.txBuilder;

      await expect(
        txBuilder
          .delegatePortfolio({
            name: 'Tests Portfolio',
            pools: [{ id: Cardano.PoolIdHex(Cardano.PoolId.toKeyHash(poolIds[0])), weight: 1 }]
          })
          .build()
          .inspect()
      ).rejects.toThrow(OutOfSyncRewardAccounts);
      // Expect retries
      expect(rewardAccountsProvider.mock.calls.length).toBeGreaterThan(normalRewardAccountsCalls);
    });
  });
});
