/* eslint-disable sonarjs/no-duplicate-string */
import * as Crypto from '@cardano-sdk/crypto';
import { AddressType, Bip32Account, GroupedAddress, InMemoryKeyAgent, util } from '@cardano-sdk/key-management';
import { Cardano } from '@cardano-sdk/core';
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
import { mockTxEvaluator } from './mocks';
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

/** Utility factory for tests to create a GenericTxBuilder with mocked dependencies */
const createTxBuilder = async ({
  stakeDelegations,
  numAddresses = stakeDelegations.length,
  useMultiplePaymentKeys = false,
  rewardAccounts,
  keyAgent
}: {
  stakeDelegations: {
    credentialStatus: Cardano.StakeCredentialStatus;
    poolId?: Cardano.PoolId;
    deposit?: Cardano.Lovelace;
  }[];
  numAddresses?: number;
  useMultiplePaymentKeys?: boolean;
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  rewardAccounts?: any;
  keyAgent: InMemoryKeyAgent;
}) => {
  let groupedAddresses = await Promise.all(
    Array.from({ length: numAddresses }).map(async (_, idx) =>
      keyAgent.deriveAddress({ index: 0, type: AddressType.External }, idx)
    )
  );

  // Simulate an HD wallet where a each stake key partitions 2 payment keys (2 addresses per stake key)
  if (useMultiplePaymentKeys) {
    const groupedAddresses2 = await Promise.all(
      stakeDelegations.map(async (_, idx) => keyAgent.deriveAddress({ index: 1, type: AddressType.External }, idx))
    );
    groupedAddresses = [...groupedAddresses, ...groupedAddresses2];
  }

  const txBuilderProviders: jest.Mocked<TxBuilderProviders> = {
    addresses: {
      add: jest.fn().mockImplementation((...addreses) => groupedAddresses.push(...addreses)),
      get: jest.fn().mockResolvedValue(groupedAddresses)
    },
    genesisParameters: jest.fn().mockResolvedValue(mocks.genesisParameters),
    protocolParameters: jest.fn().mockResolvedValue(mocks.protocolParameters),
    rewardAccounts:
      rewardAccounts ||
      jest.fn().mockImplementation(() =>
        Promise.resolve(
          // There can be multiple addresses with the same reward account. Extract the uniq reward accounts
          uniqBy(groupedAddresses, ({ rewardAccount }) => rewardAccount)
            // Create mock stakeKey/delegation status for each reward account according to the requested stakeDelegations.
            // This would normally be done by the wallet.delegation.rewardAccounts
            .map<RewardAccountWithPoolId>(({ rewardAccount: address }, index) => {
              const { credentialStatus, poolId, deposit } = stakeDelegations[index] ?? {};
              return {
                address,
                credentialStatus: credentialStatus ?? Cardano.StakeCredentialStatus.Unregistered,
                rewardBalance: mocks.rewardAccountBalance,
                ...(poolId ? { delegatee: { nextNextEpoch: { id: poolId } } } : undefined),
                ...(deposit && { deposit })
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
  const asyncKeyAgent = util.createAsyncKeyAgent(keyAgent);
  return {
    groupedAddresses,
    txBuilder: new GenericTxBuilder({
      bip32Account: await Bip32Account.fromAsyncKeyAgent(asyncKeyAgent),
      inputResolver,
      logger: dummyLogger,
      outputValidator,
      txBuilderProviders,
      txEvaluator: mockTxEvaluator,
      witnesser: util.createBip32Ed25519Witnesser(asyncKeyAgent)
    }),
    txBuilderProviders,
    txBuilderWithoutBip32Account: new GenericTxBuilder({
      inputResolver,
      logger: dummyLogger,
      outputValidator,
      txBuilderProviders,
      txEvaluator: mockTxEvaluator,
      witnesser: util.createBip32Ed25519Witnesser(asyncKeyAgent)
    })
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
      { bip32Ed25519: new Crypto.SodiumBip32Ed25519(), logger: dummyLogger }
    );
  });

  afterEach(() => jest.clearAllMocks());

  describe('single reward account', () => {
    beforeEach(async () => {
      const txBuilderFactory = await createTxBuilder({
        keyAgent,
        stakeDelegations: [{ credentialStatus: Cardano.StakeCredentialStatus.Unregistered }]
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
        __typename: Cardano.CertificateType.StakeRegistration,
        stakeCredential: {
          hash: Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(
            Cardano.RewardAccount.toHash(groupedAddresses[0].rewardAccount)
          ),
          type: Cardano.CredentialType.KeyHash
        }
      });
      expect(tx.body.certificates).toContainEqual({
        __typename: Cardano.CertificateType.StakeDelegation,
        poolId: poolIds[0],
        stakeCredential: {
          hash: Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(
            Cardano.RewardAccount.toHash(groupedAddresses[0].rewardAccount)
          ),
          type: Cardano.CredentialType.KeyHash
        }
      });

      expect(GreedyInputSelector).not.toHaveBeenCalled();
      expect(roundRobinRandomImprove).toHaveBeenCalled();
    });
  });

  describe('input selection type with multiple reward accounts and single pool delegation', () => {
    beforeEach(async () => {
      const txBuilderFactory = await createTxBuilder({
        keyAgent,
        stakeDelegations: [
          { credentialStatus: Cardano.StakeCredentialStatus.Registered },
          { credentialStatus: Cardano.StakeCredentialStatus.Unregistered }
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
        stakeDelegations: [
          { credentialStatus: Cardano.StakeCredentialStatus.Unregistered },
          { credentialStatus: Cardano.StakeCredentialStatus.Unregistered }
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
          Cardano.createStakeRegistrationCert(groupedAddresses[0].rewardAccount)
        );
        expect(tx.body.certificates).toContainEqual(
          Cardano.createDelegationCert(groupedAddresses[0].rewardAccount, poolIds[0])
        );
        expect(tx.body.certificates).toContainEqual(
          Cardano.createStakeRegistrationCert(groupedAddresses[1].rewardAccount)
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
    let nonDelegatingWalletTxBuilder: GenericTxBuilder;
    let multiDelegatingWalletTxBuilder: GenericTxBuilder;
    let singleDelegatingWalletTxBuilder: GenericTxBuilder;
    let singleDelegatingWalletGroupedAddresses: GroupedAddress[];
    let multiDelegatingWalletGroupedAddresses: GroupedAddress[];

    const deposit = 5n;

    beforeEach(async () => {
      const txBuilderFactory = await createTxBuilder({
        keyAgent,
        stakeDelegations: [
          { credentialStatus: Cardano.StakeCredentialStatus.Registered, poolId: poolIds[0] },
          { credentialStatus: Cardano.StakeCredentialStatus.Registered, deposit, poolId: poolIds[1] }
        ]
      });
      groupedAddresses = txBuilderFactory.groupedAddresses;
      txBuilder = txBuilderFactory.txBuilder;
      txBuilderProviders = txBuilderFactory.txBuilderProviders;

      nonDelegatingWalletTxBuilder = (
        await createTxBuilder({
          keyAgent,
          stakeDelegations: [
            { credentialStatus: Cardano.StakeCredentialStatus.Unregistered, poolId: poolIds[0] },
            { credentialStatus: Cardano.StakeCredentialStatus.Unregistered, poolId: poolIds[1] }
          ]
        })
      ).txBuilder;

      const multiDelegatingWalletTxBuilderFactory = await createTxBuilder({
        keyAgent,
        stakeDelegations: [
          { credentialStatus: Cardano.StakeCredentialStatus.Registered, poolId: poolIds[0] },
          { credentialStatus: Cardano.StakeCredentialStatus.Registered, poolId: poolIds[1] }
        ]
      });

      multiDelegatingWalletTxBuilder = multiDelegatingWalletTxBuilderFactory.txBuilder;
      multiDelegatingWalletGroupedAddresses = multiDelegatingWalletTxBuilderFactory.groupedAddresses;

      const singleDelegatingWalletTxBuilderFactory = await createTxBuilder({
        keyAgent,
        stakeDelegations: [{ credentialStatus: Cardano.StakeCredentialStatus.Registered, poolId: poolIds[0] }]
      });

      singleDelegatingWalletTxBuilder = singleDelegatingWalletTxBuilderFactory.txBuilder;
      singleDelegatingWalletGroupedAddresses = singleDelegatingWalletTxBuilderFactory.groupedAddresses;
    });

    it('does nothing and uses random improve input selector when the wallet is not delegating and delegatePortfolio is given a null portfolio', async () => {
      const tx = await nonDelegatingWalletTxBuilder.delegatePortfolio(null).build().inspect();
      expect(tx.body.certificates?.length).toBe(0);
      expect(GreedyInputSelector).not.toHaveBeenCalled();
      expect(roundRobinRandomImprove).toHaveBeenCalled();
    });

    it('does nothing and uses random improve input selector when the wallet is multi delegating and transaction is not changing delegation', async () => {
      const tx = await multiDelegatingWalletTxBuilder
        .addOutput(
          multiDelegatingWalletTxBuilder
            .buildOutput({ address: multiDelegatingWalletGroupedAddresses[0].address, value: { coins: 10n } })
            .toTxOut()
        )
        .build()
        .inspect();
      expect(tx.body.certificates).toBeUndefined();
      expect(tx.body.outputs.length).toBeTruthy();
      expect(GreedyInputSelector).not.toHaveBeenCalled();
      expect(roundRobinRandomImprove).toHaveBeenCalled();
    });

    it('does nothing and uses random improve input selector when the wallet is single delegating and transaction is not changing delegation', async () => {
      const tx = await singleDelegatingWalletTxBuilder
        .addOutput(
          singleDelegatingWalletTxBuilder
            .buildOutput({ address: singleDelegatingWalletGroupedAddresses[0].address, value: { coins: 10n } })
            .toTxOut()
        )
        .build()
        .inspect();
      expect(tx.body.certificates).toBeUndefined();
      expect(tx.body.outputs.length).toBeTruthy();
      expect(GreedyInputSelector).not.toHaveBeenCalled();
      expect(roundRobinRandomImprove).toHaveBeenCalled();
    });

    it('de-registers all stake keys and uses greedy selector when wallet is delegating and delegatePortfolio is given a null portfolio', async () => {
      const tx = await txBuilder.delegatePortfolio(null).build().inspect();
      expect(tx.body.certificates?.length).toBe(2);
      expect(tx.body.certificates).toContainEqual(
        Cardano.createStakeDeregistrationCert(groupedAddresses[0].rewardAccount)
      );
      expect(tx.body.certificates).toContainEqual(
        Cardano.createStakeDeregistrationCert(groupedAddresses[1].rewardAccount, deposit)
      );

      expect(GreedyInputSelector).toHaveBeenCalled();
      expect(roundRobinRandomImprove).not.toHaveBeenCalled();

      // All outputs go back to first address.
      expect(tx.body.outputs.every((output) => output.address === groupedAddresses[0].address)).toBeTruthy();
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
        Cardano.createStakeDeregistrationCert(groupedAddresses[0].rewardAccount)
      );

      await expectGreedyInputSelectorWith(new Map([[groupedAddresses[1].address, 1]]));
    });

    it('portfolio with empty pools array is not a valid CIP17 portfolio', () => {
      expect(() => txBuilder.delegatePortfolio({ name: 'Test Portfolio', pools: [] })).toThrow();
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
        Cardano.createStakeRegistrationCert(rewardAccounts[2].address),
        Cardano.createDelegationCert(rewardAccounts[2].address, poolIds[2])
      ]);
    });
  });

  describe('partial pre-existing multi-delegation', () => {
    beforeEach(async () => {
      const txBuilderFactory = await createTxBuilder({
        keyAgent,
        stakeDelegations: [
          { credentialStatus: Cardano.StakeCredentialStatus.Registered, poolId: poolIds[0] },
          { credentialStatus: Cardano.StakeCredentialStatus.Registered }
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
        Cardano.createStakeDeregistrationCert(groupedAddresses[1].rewardAccount)
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
        stakeDelegations: [
          { credentialStatus: Cardano.StakeCredentialStatus.Unregistered },
          { credentialStatus: Cardano.StakeCredentialStatus.Unregistered }
        ]
      });
      groupedAddresses = txBuilderFactory.groupedAddresses;
      txBuilder = txBuilderFactory.txBuilder;

      const firstStakeKeyHash = Cardano.RewardAccount.toHash(groupedAddresses[0].rewardAccount);

      const tx = await txBuilder.delegatePortfolio(portfolio).build().inspect();

      const certs = tx.body.certificates;
      expect(certs?.length).toBe(2);
      expect((certs![1] as Cardano.StakeDelegationCertificate).stakeCredential.hash).toEqual(firstStakeKeyHash);
    });

    it('uses first one when all stake keys are registered', async () => {
      const txBuilderFactory = await createTxBuilder({
        keyAgent,
        stakeDelegations: [
          { credentialStatus: Cardano.StakeCredentialStatus.Registered },
          { credentialStatus: Cardano.StakeCredentialStatus.Registered }
        ]
      });
      groupedAddresses = txBuilderFactory.groupedAddresses;
      txBuilder = txBuilderFactory.txBuilder;

      const tx = await txBuilder.delegatePortfolio(portfolio).build().inspect();

      const certs = tx.body.certificates as Cardano.StakeDelegationCertificate[];
      expect(certs.length).toBe(2);
      expect(certs).toEqual<Cardano.Certificate[]>([
        Cardano.createDelegationCert(groupedAddresses[0].rewardAccount, poolIds[0]),
        Cardano.createStakeDeregistrationCert(groupedAddresses[1].rewardAccount)
      ]);
    });

    it('uses stake keys in order when changing delegation', async () => {
      const txBuilderFactory = await createTxBuilder({
        keyAgent,
        stakeDelegations: [
          { credentialStatus: Cardano.StakeCredentialStatus.Registered, poolId: poolIds[0] },
          { credentialStatus: Cardano.StakeCredentialStatus.Registered, poolId: poolIds[1] }
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
      expect(certs[0].stakeCredential.hash).toEqual(firstStakeKeyHash);
      expect(certs[1].stakeCredential.hash).toEqual(secondStakeKeyHash);
    });

    it('uses registered stake keys over unregistered ones', async () => {
      const txBuilderFactory = await createTxBuilder({
        keyAgent,
        stakeDelegations: [
          { credentialStatus: Cardano.StakeCredentialStatus.Unregistered },
          { credentialStatus: Cardano.StakeCredentialStatus.Registered }
        ]
      });
      groupedAddresses = txBuilderFactory.groupedAddresses;
      txBuilder = txBuilderFactory.txBuilder;

      const secondStakeKeyHash = Cardano.RewardAccount.toHash(groupedAddresses[1].rewardAccount);

      const tx = await txBuilder.delegatePortfolio(portfolio).build().inspect();

      const certs = tx.body.certificates as Cardano.StakeDelegationCertificate[];
      expect(certs.length).toBe(1);
      expect(certs[0].stakeCredential.hash).toEqual(secondStakeKeyHash);
    });

    it('reuses delegated stake keys instead of registering new ones', async () => {
      const txBuilderFactory = await createTxBuilder({
        keyAgent,
        stakeDelegations: [
          { credentialStatus: Cardano.StakeCredentialStatus.Registered },
          { credentialStatus: Cardano.StakeCredentialStatus.Registered, poolId: poolIds[1] }
        ]
      });
      groupedAddresses = txBuilderFactory.groupedAddresses;
      txBuilder = txBuilderFactory.txBuilder;

      const tx = await txBuilder.delegatePortfolio(portfolio).build().inspect();

      const certs = tx.body.certificates as Cardano.StakeDelegationCertificate[];
      expect(certs.length).toBe(2);
      expect(certs).toEqual<Cardano.Certificate[]>([
        Cardano.createDelegationCert(groupedAddresses[1].rewardAccount, poolIds[0]),
        Cardano.createStakeDeregistrationCert(groupedAddresses[0].rewardAccount)
      ]);
    });

    it('attaches the portfolio as tx metadata', async () => {
      const txBuilderFactory = await createTxBuilder({
        keyAgent,
        stakeDelegations: [
          { credentialStatus: Cardano.StakeCredentialStatus.Registered },
          { credentialStatus: Cardano.StakeCredentialStatus.Registered, poolId: poolIds[1] }
        ]
      });
      groupedAddresses = txBuilderFactory.groupedAddresses;
      txBuilder = txBuilderFactory.txBuilder;

      const tx = await txBuilder.delegatePortfolio(portfolio).build().inspect();

      const certs = tx.body.certificates as Cardano.StakeDelegationCertificate[];
      expect(certs.length).toBe(2);
      expect(certs).toEqual<Cardano.Certificate[]>([
        Cardano.createDelegationCert(groupedAddresses[1].rewardAccount, poolIds[0]),
        Cardano.createStakeDeregistrationCert(groupedAddresses[0].rewardAccount)
      ]);

      const metadata = tx.auxiliaryData!.blob!.get(Cardano.DelegationMetadataLabel);
      expect(Cardano.cip17FromMetadatum(metadata!)).toEqual(portfolio);
    });
  });

  describe('rewardAccount syncing', () => {
    const normalRewardAccountsCalls = 3;
    it('can wait for delayed key agent stake keys', async () => {
      const address = await keyAgent.deriveAddress({ index: 0, type: AddressType.External }, 0);
      const rewardAccountsProvider = jest
        .fn()
        .mockResolvedValueOnce([])
        .mockResolvedValueOnce([])
        .mockResolvedValueOnce([])
        .mockImplementation(() =>
          Promise.resolve([
            {
              address: address.rewardAccount,
              credentialStatus: Cardano.StakeCredentialStatus.Unregistered,
              rewardBalance: mocks.rewardAccountBalance
            }
          ])
        );
      const txBuilderFactory = await createTxBuilder({
        keyAgent,
        numAddresses: 1,
        rewardAccounts: rewardAccountsProvider,
        stakeDelegations: []
      });

      txBuilder = txBuilderFactory.txBuilder;

      await expect(
        txBuilder
          .delegatePortfolio({
            name: 'Test Portfolio',
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
        stakeDelegations: []
      });

      txBuilder = txBuilderFactory.txBuilder;

      await expect(
        txBuilder
          .delegatePortfolio({
            name: 'Test Portfolio',
            pools: [{ id: Cardano.PoolIdHex(Cardano.PoolId.toKeyHash(poolIds[0])), weight: 1 }]
          })
          .build()
          .inspect()
      ).rejects.toThrow(OutOfSyncRewardAccounts);
      // Expect retries
      expect(rewardAccountsProvider.mock.calls.length).toBeGreaterThan(normalRewardAccountsCalls);
    });
  });

  describe('No Bip32Account', () => {
    it('throws if delegatePortfolio is called in a TxBuilder without Bip32Account', async () => {
      await keyAgent.deriveAddress({ index: 0, type: AddressType.External }, 0);
      const rewardAccountsProvider = jest.fn().mockResolvedValue([]);
      const txBuilderFactory = await createTxBuilder({
        keyAgent,
        rewardAccounts: rewardAccountsProvider,
        stakeDelegations: []
      });

      txBuilder = txBuilderFactory.txBuilderWithoutBip32Account;

      expect(() =>
        txBuilder.delegatePortfolio({
          name: 'Test Portfolio',
          pools: [{ id: Cardano.PoolIdHex(Cardano.PoolId.toKeyHash(poolIds[0])), weight: 1 }]
        })
      ).toThrow('BIP32 account is required to delegate portfolio.');
    });

    it('can delegate calling delegateFirstStakeCredential', async () => {
      const groupAddress = await keyAgent.deriveAddress({ index: 0, type: AddressType.External }, 0);
      const txBuilderFactory = await createTxBuilder({
        keyAgent,
        stakeDelegations: [{ credentialStatus: Cardano.StakeCredentialStatus.Unregistered }]
      });

      txBuilder = txBuilderFactory.txBuilderWithoutBip32Account;

      const tx = await txBuilder.delegateFirstStakeCredential(poolIds[0]).build().inspect();

      expect(tx.body.certificates?.length).toBe(2);
      expect(tx.body.certificates).toContainEqual<Cardano.Certificate>({
        __typename: Cardano.CertificateType.StakeRegistration,
        stakeCredential: {
          hash: Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(Cardano.RewardAccount.toHash(groupAddress.rewardAccount)),
          type: Cardano.CredentialType.KeyHash
        }
      });
      expect(tx.body.certificates).toContainEqual({
        __typename: Cardano.CertificateType.StakeDelegation,
        poolId: poolIds[0],
        stakeCredential: {
          hash: Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(Cardano.RewardAccount.toHash(groupAddress.rewardAccount)),
          type: Cardano.CredentialType.KeyHash
        }
      });

      expect(GreedyInputSelector).not.toHaveBeenCalled();
      expect(roundRobinRandomImprove).toHaveBeenCalled();
    });
  });
});
