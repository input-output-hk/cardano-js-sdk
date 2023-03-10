/* eslint-disable max-len */
import * as Crypto from '@cardano-sdk/crypto';
import * as mocks from '../mocks';
import { AddressType, GroupedAddress } from '@cardano-sdk/key-management';
import { CML, Cardano } from '@cardano-sdk/core';
import {
  OutputValidator,
  ProtocolParametersRequiredByOutputValidator,
  SingleAddressWallet,
  WalletUtilContext,
  createInputResolver,
  createLazyWalletUtil,
  createOutputValidator,
  requiresForeignSignatures,
  setupWallet
} from '../../src';
import { createStubStakePoolProvider } from '@cardano-sdk/util-dev';
import { dummyLogger as logger } from 'ts-log';
import { mockChainHistoryProvider, mockRewardsProvider, utxo as mockUtxo } from '../mocks';
import { of } from 'rxjs';
import { testAsyncKeyAgent } from '../../../key-management/test/mocks';
import { waitForWalletStateSettle } from '../util';

describe('WalletUtil', () => {
  describe('createOutputValidator', () => {
    let validator: OutputValidator;

    beforeAll(() => {
      validator = createOutputValidator({
        protocolParameters$: of<ProtocolParametersRequiredByOutputValidator>({
          coinsPerUtxoByte: 4310,
          maxValueSize: 90
        })
      });
    });

    it('validateValue validates minimum coin quantity', async () => {
      expect((await validator.validateValue({ coins: 2_000_000n })).coinMissing).toBe(0n);
      expect((await validator.validateValue({ coins: 500_000n })).coinMissing).toBeGreaterThan(0n);
    });

    it('validateValue validates bundle size', async () => {
      expect(
        (
          await validator.validateValue({
            assets: new Map([
              [Cardano.AssetId('b01fb3b8c3dd6b3705a5dc8bcd5a70759f70ad5d97a72005caeac3c652657675746f31333237'), 1n]
            ]),
            coins: 2_000_000n
          })
        ).tokenBundleSizeExceedsLimit
      ).toBe(false);
      expect(
        (
          await validator.validateValue({
            assets: new Map([
              [Cardano.AssetId('b01fb3b8c3dd6b3705a5dc8bcd5a70759f70ad5d97a72005caeac3c652657675746f31333237'), 1n],
              [Cardano.AssetId('c01fb3b8c3dd6b3705a5dc8bcd5a70759f70ad5d97a72005caeac3c652657675746f31333237'), 2n]
            ]),
            coins: 2_000_000n
          })
        ).tokenBundleSizeExceedsLimit
      ).toBe(true);
    });
  });

  describe('createInputResolver', () => {
    it('resolveInput resolves inputs from provided utxo set', async () => {
      const utxo: Cardano.Utxo[] = [
        [
          {
            address: Cardano.PaymentAddress(
              'addr_test1qz2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzer3jcu5d8ps7zex2k2xt3uqxgjqnnj83ws8lhrn648jjxtwq2ytjqp'
            ),
            index: 0,
            txId: Cardano.TransactionId('0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5')
          },
          {
            address: Cardano.PaymentAddress('addr_test1vr8nl4u0u6fmtfnawx2rxfz95dy7m46t6dhzdftp2uha87syeufdg'),
            value: { coins: 50_000_000n }
          }
        ]
      ];
      const resolver = createInputResolver({ utxo: { available$: of(utxo) } });
      expect(
        await resolver.resolveInput({
          index: 0,
          txId: Cardano.TransactionId('0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5')
        })
      ).toEqual({
        address: 'addr_test1vr8nl4u0u6fmtfnawx2rxfz95dy7m46t6dhzdftp2uha87syeufdg',
        value: { coins: 50_000_000n }
      });
      expect(
        await resolver.resolveInput({
          index: 0,
          txId: Cardano.TransactionId('0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d4')
        })
      ).toBeNull();
    });
  });

  describe('createLazyWalletUtil', () => {
    it('awaits for "initialize" to be called before resolving call to any util', async () => {
      const util = createLazyWalletUtil();
      const resultPromise = util.validateValue({ coins: 2_000_000n });
      util.initialize({
        protocolParameters$: of<ProtocolParametersRequiredByOutputValidator>({
          coinsPerUtxoByte: 4310,
          maxValueSize: 90
        })
      } as WalletUtilContext);
      const result = await resultPromise;
      expect(result.coinMissing).toBe(0n);
    });
  });

  describe('requiresForeignSignatures', () => {
    const address = mocks.utxo[0][0].address!;
    let txSubmitProvider: mocks.TxSubmitProviderStub;
    let networkInfoProvider: mocks.NetworkInfoProviderStub;
    let wallet: SingleAddressWallet;
    let utxoProvider: mocks.UtxoProviderStub;
    let tx: Cardano.Tx;

    beforeEach(async () => {
      txSubmitProvider = mocks.mockTxSubmitProvider();
      networkInfoProvider = mocks.mockNetworkInfoProvider();
      utxoProvider = mocks.mockUtxoProvider();
      const assetProvider = mocks.mockAssetProvider();
      const stakePoolProvider = createStubStakePoolProvider();
      const rewardsProvider = mockRewardsProvider();
      const chainHistoryProvider = mockChainHistoryProvider();
      const groupedAddress: GroupedAddress = {
        accountIndex: 0,
        address,
        index: 0,
        networkId: Cardano.NetworkId.Testnet,
        rewardAccount: mocks.rewardAccount,
        stakeKeyDerivationPath: mocks.stakeKeyDerivationPath,
        type: AddressType.External
      };
      ({ wallet } = await setupWallet({
        bip32Ed25519: new Crypto.CmlBip32Ed25519(CML),
        createKeyAgent: async (dependencies) => {
          const asyncKeyAgent = await testAsyncKeyAgent([groupedAddress], dependencies);
          asyncKeyAgent.deriveAddress = jest.fn().mockResolvedValue(groupedAddress);
          return asyncKeyAgent;
        },
        createWallet: async (keyAgent) =>
          new SingleAddressWallet(
            { name: 'Test Wallet' },
            {
              assetProvider,
              chainHistoryProvider,
              keyAgent,
              logger,
              networkInfoProvider,
              rewardsProvider,
              stakePoolProvider,
              txSubmitProvider,
              utxoProvider
            }
          ),
        logger
      }));

      await waitForWalletStateSettle(wallet);

      const props = {
        certificates: [
          {
            __typename: Cardano.CertificateType.StakeKeyDeregistration,
            stakeKeyHash: mocks.stakeKeyHash
          } as Cardano.StakeAddressCertificate
        ],
        collaterals: new Set([mockUtxo[2][0]]),
        outputs: new Set([
          {
            address: Cardano.PaymentAddress(
              'addr_test1qpu5vlrf4xkxv2qpwngf6cjhtw542ayty80v8dyr49rf5ewvxwdrt70qlcpeeagscasafhffqsxy36t90ldv06wqrk2qum8x5w'
            ),
            value: { coins: 11_111_111n }
          }
        ])
      };

      tx = await wallet.finalizeTx({ tx: await wallet.initializeTx(props) });
    });

    afterEach(() => {
      wallet.shutdown();
    });

    it('returns false when all inputs and certificates are accounted for ', async () => {
      // Inputs are selected by input selection algorithm
      expect(tx.body.inputs.length).toBeGreaterThanOrEqual(1);
      expect(tx.body.certificates!.length).toBe(1);
      expect(await requiresForeignSignatures(tx, wallet)).toBeFalsy();
    });

    it('returns true when at least one certificate can not be accounted for - StakeKeyDeregistration ', async () => {
      const foreignRewardAccountHash = Cardano.RewardAccount.toHash(
        Cardano.RewardAccount('stake_test1uqfu74w3wh4gfzu8m6e7j987h4lq9r3t7ef5gaw497uu85qsqfy27')
      );

      tx.body.certificates = [
        {
          __typename: Cardano.CertificateType.StakeKeyDeregistration,
          stakeKeyHash: foreignRewardAccountHash
        } as Cardano.StakeAddressCertificate,
        ...tx.body.certificates!
      ];

      expect(tx.body.inputs.length).toBeGreaterThanOrEqual(1);
      expect(tx.body.certificates!.length).toBe(2);
      expect(await requiresForeignSignatures(tx, wallet)).toBeTruthy();
    });

    it('returns true when at least one certificate can not be accounted for - StakeDelegation ', async () => {
      const foreignRewardAccountHash = Cardano.RewardAccount.toHash(
        Cardano.RewardAccount('stake_test1uqfu74w3wh4gfzu8m6e7j987h4lq9r3t7ef5gaw497uu85qsqfy27')
      );

      tx.body.certificates = [
        {
          __typename: Cardano.CertificateType.StakeDelegation,
          poolId: Cardano.PoolId.fromKeyHash(foreignRewardAccountHash),
          stakeKeyHash: foreignRewardAccountHash
        } as Cardano.StakeDelegationCertificate,
        ...tx.body.certificates!
      ];

      expect(tx.body.inputs.length).toBeGreaterThanOrEqual(1);
      expect(tx.body.certificates!.length).toBe(2);
      expect(await requiresForeignSignatures(tx, wallet)).toBeTruthy();
    });

    it('returns true when at least one certificate can not be accounted for - PoolRegistration ', async () => {
      const foreignRewardAccountHash = Cardano.RewardAccount.toHash(
        Cardano.RewardAccount('stake_test1uqfu74w3wh4gfzu8m6e7j987h4lq9r3t7ef5gaw497uu85qsqfy27')
      );

      tx.body.certificates = [
        {
          __typename: Cardano.CertificateType.PoolRegistration,
          poolParameters: {
            cost: 340n,
            id: Cardano.PoolId.fromKeyHash(foreignRewardAccountHash),
            margin: {
              denominator: 50,
              numerator: 10
            },
            owners: [Cardano.RewardAccount('stake_test1uqfu74w3wh4gfzu8m6e7j987h4lq9r3t7ef5gaw497uu85qsqfy27')],
            pledge: 10_000n,
            relays: [
              {
                __typename: 'RelayByName',
                hostname: 'localhost'
              }
            ],
            rewardAccount: Cardano.RewardAccount('stake_test1uqfu74w3wh4gfzu8m6e7j987h4lq9r3t7ef5gaw497uu85qsqfy27'),
            vrf: Cardano.VrfVkHex('641d042ed39c2c258d381060c1424f40ef8abfe25ef566f4cb22477c42b2a014')
          }
        } as Cardano.PoolRegistrationCertificate,
        ...tx.body.certificates!
      ];

      expect(tx.body.inputs.length).toBeGreaterThanOrEqual(1);
      expect(tx.body.certificates!.length).toBe(2);
      expect(await requiresForeignSignatures(tx, wallet)).toBeTruthy();
    });

    it('returns true when at least one certificate can not be accounted for - PoolRetirement ', async () => {
      const foreignRewardAccountHash = Cardano.RewardAccount.toHash(
        Cardano.RewardAccount('stake_test1uqfu74w3wh4gfzu8m6e7j987h4lq9r3t7ef5gaw497uu85qsqfy27')
      );

      tx.body.certificates = [
        {
          __typename: Cardano.CertificateType.PoolRetirement,
          epoch: Cardano.EpochNo(100),
          poolId: Cardano.PoolId.fromKeyHash(foreignRewardAccountHash)
        } as Cardano.PoolRetirementCertificate,
        ...tx.body.certificates!
      ];

      expect(tx.body.inputs.length).toBeGreaterThanOrEqual(1);
      expect(tx.body.certificates!.length).toBe(2);
      expect(await requiresForeignSignatures(tx, wallet)).toBeTruthy();
    });

    it('returns true when at least one certificate can not be accounted for - MIR ', async () => {
      tx.body.certificates = [
        {
          __typename: Cardano.CertificateType.MIR,
          pot: Cardano.MirCertificatePot.Treasury,
          quantity: 100n,
          rewardAccount: Cardano.RewardAccount('stake_test1uqfu74w3wh4gfzu8m6e7j987h4lq9r3t7ef5gaw497uu85qsqfy27')
        } as Cardano.MirCertificate,
        ...tx.body.certificates!
      ];

      expect(tx.body.inputs.length).toBeGreaterThanOrEqual(1);
      expect(tx.body.certificates!.length).toBe(2);
      expect(await requiresForeignSignatures(tx, wallet)).toBeTruthy();
    });

    it('returns false when a StakeKeyRegistration certificate can not be accounted for ', async () => {
      const foreignRewardAccountHash = Cardano.RewardAccount.toHash(
        Cardano.RewardAccount('stake_test1uqfu74w3wh4gfzu8m6e7j987h4lq9r3t7ef5gaw497uu85qsqfy27')
      );

      tx.body.certificates = [
        {
          __typename: Cardano.CertificateType.StakeKeyRegistration,
          stakeKeyHash: foreignRewardAccountHash
        } as Cardano.StakeAddressCertificate,
        ...tx.body.certificates!
      ];

      expect(tx.body.inputs.length).toBeGreaterThanOrEqual(1);
      expect(tx.body.certificates!.length).toBe(2);
      expect(await requiresForeignSignatures(tx, wallet)).toBeFalsy();
    });

    it('returns false when a GenesisKeyDelegation certificate can not be accounted for ', async () => {
      tx.body.certificates = [
        {
          __typename: Cardano.CertificateType.GenesisKeyDelegation,
          genesisDelegateHash: Crypto.Hash28ByteBase16('00000000000000000000000000000000000000000000000000000000'),
          genesisHash: Crypto.Hash28ByteBase16('00000000000000000000000000000000000000000000000000000000'),
          vrfKeyHash: Crypto.Hash32ByteBase16('0000000000000000000000000000000000000000000000000000000000000000')
        } as Cardano.GenesisKeyDelegationCertificate,
        ...tx.body.certificates!
      ];

      expect(tx.body.inputs.length).toBeGreaterThanOrEqual(1);
      expect(tx.body.certificates!.length).toBe(2);
      expect(await requiresForeignSignatures(tx, wallet)).toBeFalsy();
    });

    it('returns true when at least one input from collateral is not accounted for ', async () => {
      tx.body.collaterals = [
        {
          index: 0,
          txId: Cardano.TransactionId('0000000000000000000000000000000000000000000000000000000000000000')
        },
        ...tx.body.collaterals!
      ];

      expect(tx.body.inputs.length).toBeGreaterThanOrEqual(1);
      expect(tx.body.certificates!.length).toBe(1);
      expect(await requiresForeignSignatures(tx, wallet)).toBeTruthy();
    });

    it('returns true when at least one input is not accounted for ', async () => {
      tx.body.inputs = [
        {
          index: 0,
          txId: Cardano.TransactionId('0000000000000000000000000000000000000000000000000000000000000000')
        },
        ...tx.body.inputs
      ];

      expect(tx.body.inputs.length).toBeGreaterThanOrEqual(2);
      expect(tx.body.certificates!.length).toBe(1);
      expect(await requiresForeignSignatures(tx, wallet)).toBeTruthy();
    });
  });
});
