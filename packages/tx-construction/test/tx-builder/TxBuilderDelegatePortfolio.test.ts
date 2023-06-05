import * as Crypto from '@cardano-sdk/crypto';
import { AddressType, GroupedAddress, InMemoryKeyAgent, util } from '@cardano-sdk/key-management';
import { CML, Cardano } from '@cardano-sdk/core';
import { GenericTxBuilder, OutputValidation, RewardAccountWithPoolId, TxBuilderProviders } from '../../src';
import { dummyLogger } from 'ts-log';
import { mockProviders as mocks } from '@cardano-sdk/util-dev';

const createTxBuilder = async (
  stakeKeyDelegations: { keyStatus: Cardano.StakeKeyStatus; poolId?: Cardano.PoolId }[]
) => {
  const inputResolver: Cardano.InputResolver = {
    resolveInput: async (txIn) =>
      mocks.utxo.find(([hydratedTxIn]) => txIn.txId === hydratedTxIn.txId && txIn.index === hydratedTxIn.index)?.[1] ||
      null
  };
  const keyAgent: InMemoryKeyAgent = await InMemoryKeyAgent.fromBip39MnemonicWords(
    {
      chainId: Cardano.ChainIds.Preprod,
      getPassphrase: async () => Buffer.from('passphrase'),
      mnemonicWords: util.generateMnemonicWords()
    },
    { bip32Ed25519: new Crypto.CmlBip32Ed25519(CML), inputResolver, logger: dummyLogger }
  );
  const address1 = await keyAgent.deriveAddress({ index: 0, type: AddressType.External }, 0);
  const address2 = await keyAgent.deriveAddress({ index: 0, type: AddressType.External }, 1);
  const groupedAddresses = [address1, address2];

  const txBuilderProviders: jest.Mocked<TxBuilderProviders> = {
    genesisParameters: jest.fn().mockResolvedValue(mocks.genesisParameters),
    protocolParameters: jest.fn().mockResolvedValue(mocks.protocolParameters),
    rewardAccounts: jest.fn().mockImplementation(() =>
      Promise.resolve(
        keyAgent.knownAddresses.map<RewardAccountWithPoolId>((knownAddr, index) => {
          const { keyStatus, poolId } = stakeKeyDelegations[index] ?? {};
          return {
            address: knownAddr.rewardAccount,
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

  describe('no previous delegations', () => {
    beforeEach(async () => {
      const txBuilderFactory = await createTxBuilder([
        { keyStatus: Cardano.StakeKeyStatus.Unregistered },
        { keyStatus: Cardano.StakeKeyStatus.Unregistered }
      ]);
      groupedAddresses = txBuilderFactory.groupedAddresses;
      txBuilder = txBuilderFactory.txBuilder;
    });

    it('null portfolio does not add certificates', async () => {
      const tx = await txBuilder.delegatePortfolio(null).build().inspect();
      expect(tx.body.certificates?.length).toBeFalsy();
    });

    it('portfolio with multi-delegation adds certificates', async () => {
      const tx = await txBuilder
        .delegatePortfolio({
          pools: [
            {
              id: Cardano.PoolIdHex(Cardano.PoolId.toKeyHash(poolIds[0])),
              weight: 1
            },
            {
              id: Cardano.PoolIdHex(Cardano.PoolId.toKeyHash(poolIds[1])),
              weight: 1
            }
          ]
        })
        .build()
        .inspect();

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
  });

  describe('pre-existing multi-delegation on all stake keys', () => {
    let txBuilderProviders: jest.Mocked<TxBuilderProviders>;
    beforeEach(async () => {
      const txBuilderFactory = await createTxBuilder([
        { keyStatus: Cardano.StakeKeyStatus.Registered, poolId: poolIds[0] },
        { keyStatus: Cardano.StakeKeyStatus.Registered, poolId: poolIds[1] }
      ]);
      groupedAddresses = txBuilderFactory.groupedAddresses;
      txBuilder = txBuilderFactory.txBuilder;
      txBuilderProviders = txBuilderFactory.txBuilderProviders;
    });

    it('null portfolio de-registers all stake keys', async () => {
      const tx = await txBuilder.delegatePortfolio(null).build().inspect();
      expect(tx.body.certificates?.length).toBe(2);
      expect(tx.body.certificates).toContainEqual(
        Cardano.createStakeKeyDeregistrationCert(groupedAddresses[0].rewardAccount)
      );
      expect(tx.body.certificates).toContainEqual(
        Cardano.createStakeKeyDeregistrationCert(groupedAddresses[1].rewardAccount)
      );
    });

    it('does not change delegations when portfolio already satisfied', async () => {
      const tx = await txBuilder
        .delegatePortfolio({
          pools: [
            {
              id: Cardano.PoolIdHex(Cardano.PoolId.toKeyHash(poolIds[0])),
              weight: 1
            },
            {
              id: Cardano.PoolIdHex(Cardano.PoolId.toKeyHash(poolIds[1])),
              weight: 1
            }
          ]
        })
        .build()
        .inspect();

      expect(tx.body.certificates?.length).toBeFalsy();
    });

    it('creates certificate to change delegation when one pool matches while the other was changed ', async () => {
      const tx = await txBuilder
        .delegatePortfolio({
          pools: [
            {
              id: Cardano.PoolIdHex(Cardano.PoolId.toKeyHash(poolIds[2])),
              weight: 1
            },
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
        Cardano.createDelegationCert(groupedAddresses[0].rewardAccount, poolIds[2])
      );
    });

    it(`portfolio is subset: adds stake deregistration certificates
         for the delegations that are no longer in the portfolio`, async () => {
      const tx = await txBuilder
        .delegatePortfolio({
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
    });

    it('portfolio with empty pools array is not a valid CIP17 portfolio', () => {
      expect(() => txBuilder.delegatePortfolio({ pools: [] })).toThrow();
    });

    it('derives more stake keys when portfolio has more pools than available keys', async () => {
      const pools = poolIds.slice(0, 3);
      const tx = await txBuilder
        .delegatePortfolio({
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
      const txBuilderFactory = await createTxBuilder([
        { keyStatus: Cardano.StakeKeyStatus.Registered, poolId: poolIds[0] },
        { keyStatus: Cardano.StakeKeyStatus.Registered }
      ]);
      groupedAddresses = txBuilderFactory.groupedAddresses;
      txBuilder = txBuilderFactory.txBuilder;
    });

    it('portfolio is superset: adds certificates for the new delegations', async () => {
      const tx = await txBuilder
        .delegatePortfolio({
          pools: [
            {
              id: Cardano.PoolIdHex(Cardano.PoolId.toKeyHash(poolIds[0])),
              weight: 1
            },
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
        Cardano.createDelegationCert(groupedAddresses[1].rewardAccount, poolIds[1])
      );
    });

    it('changes delegation and deregisters stake keys that are not delegated', async () => {
      const tx = await txBuilder
        .delegatePortfolio({
          pools: [
            {
              id: Cardano.PoolIdHex(Cardano.PoolId.toKeyHash(poolIds[2])),
              weight: 1
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
    });
  });

  describe('rewardAccount selection', () => {
    const portfolio: Pick<Cardano.Cip17DelegationPortfolio, 'pools'> = {
      pools: [{ id: Cardano.PoolIdHex(Cardano.PoolId.toKeyHash(poolIds[0])), weight: 1 }]
    };

    it('uses first one when all stake keys are unregistered', async () => {
      const txBuilderFactory = await createTxBuilder([
        { keyStatus: Cardano.StakeKeyStatus.Unregistered },
        { keyStatus: Cardano.StakeKeyStatus.Unregistered }
      ]);
      groupedAddresses = txBuilderFactory.groupedAddresses;
      txBuilder = txBuilderFactory.txBuilder;

      const firstStakeKeyHash = Cardano.RewardAccount.toHash(groupedAddresses[0].rewardAccount);

      const tx = await txBuilder.delegatePortfolio(portfolio).build().inspect();

      const certs = tx.body.certificates;
      expect(certs?.length).toBe(2);
      expect((certs![1] as Cardano.StakeDelegationCertificate).stakeKeyHash).toEqual(firstStakeKeyHash);
    });

    it('uses first one when all stake keys are registered', async () => {
      const txBuilderFactory = await createTxBuilder([
        { keyStatus: Cardano.StakeKeyStatus.Registered },
        { keyStatus: Cardano.StakeKeyStatus.Registered }
      ]);
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
      const txBuilderFactory = await createTxBuilder([
        { keyStatus: Cardano.StakeKeyStatus.Registered, poolId: poolIds[0] },
        { keyStatus: Cardano.StakeKeyStatus.Registered, poolId: poolIds[1] }
      ]);
      groupedAddresses = txBuilderFactory.groupedAddresses;
      txBuilder = txBuilderFactory.txBuilder;

      const firstStakeKeyHash = Cardano.RewardAccount.toHash(groupedAddresses[0].rewardAccount);
      const secondStakeKeyHash = Cardano.RewardAccount.toHash(groupedAddresses[1].rewardAccount);

      const tx = await txBuilder
        .delegatePortfolio({
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
      const txBuilderFactory = await createTxBuilder([
        { keyStatus: Cardano.StakeKeyStatus.Unregistered },
        { keyStatus: Cardano.StakeKeyStatus.Registered }
      ]);
      groupedAddresses = txBuilderFactory.groupedAddresses;
      txBuilder = txBuilderFactory.txBuilder;

      const secondStakeKeyHash = Cardano.RewardAccount.toHash(groupedAddresses[1].rewardAccount);

      const tx = await txBuilder.delegatePortfolio(portfolio).build().inspect();

      const certs = tx.body.certificates as Cardano.StakeDelegationCertificate[];
      expect(certs.length).toBe(1);
      expect(certs[0].stakeKeyHash).toEqual(secondStakeKeyHash);
    });

    it('reuses delegated stake keys instead of registering new ones', async () => {
      const txBuilderFactory = await createTxBuilder([
        { keyStatus: Cardano.StakeKeyStatus.Registered },
        { keyStatus: Cardano.StakeKeyStatus.Registered, poolId: poolIds[1] }
      ]);
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
});
