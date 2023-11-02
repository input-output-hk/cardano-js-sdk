import * as Crypto from '@cardano-sdk/crypto';
import { AddressType, CommunicationType, SerializableTrezorKeyAgentData, util } from '@cardano-sdk/key-management';
import { AssetId, createStubStakePoolProvider, mockProviders as mocks } from '@cardano-sdk/util-dev';
import { Cardano } from '@cardano-sdk/core';
import { InitializeTxProps, InitializeTxResult } from '@cardano-sdk/tx-construction';
import { PersonalWallet, setupWallet } from '../../../src';
import { TrezorKeyAgent } from '@cardano-sdk/hardware-trezor';
import { dummyLogger as logger } from 'ts-log';
import { mockKeyAgentDependencies } from '../../../../key-management/test/mocks';

describe('TrezorKeyAgent', () => {
  let wallet: PersonalWallet;
  let keyAgent: TrezorKeyAgent;
  let txSubmitProvider: mocks.TxSubmitProviderStub;

  const trezorConfig = {
    communicationType: CommunicationType.Node,
    manifest: {
      appUrl: 'https://your.application.com',
      email: 'email@developer.com'
    }
  };

  beforeAll(async () => {
    txSubmitProvider = mocks.mockTxSubmitProvider();
    ({ keyAgent, wallet } = await setupWallet({
      bip32Ed25519: new Crypto.SodiumBip32Ed25519(),
      createKeyAgent: async (dependencies) =>
        await TrezorKeyAgent.createWithDevice(
          {
            chainId: Cardano.ChainIds.Preprod,
            trezorConfig
          },
          dependencies
        ),
      createWallet: async (trezorKeyAgent) => {
        const { address, rewardAccount } = await trezorKeyAgent.deriveAddress(
          { index: 0, type: AddressType.External },
          0
        );
        const assetProvider = mocks.mockAssetProvider();
        const stakePoolProvider = createStubStakePoolProvider();
        const networkInfoProvider = mocks.mockNetworkInfoProvider();
        const utxoProvider = mocks.mockUtxoProvider({ address });
        const rewardsProvider = mocks.mockRewardsProvider({ rewardAccount });
        const chainHistoryProvider = mocks.mockChainHistoryProvider({ rewardAccount });
        const asyncKeyAgent = util.createAsyncKeyAgent(trezorKeyAgent);
        return new PersonalWallet(
          { name: 'HW Wallet' },
          {
            assetProvider,
            chainHistoryProvider,
            keyAgent: asyncKeyAgent,
            logger,
            networkInfoProvider,
            rewardsProvider,
            stakePoolProvider,
            txSubmitProvider,
            utxoProvider
          }
        );
      },
      logger
    }));
  });

  afterAll(() => wallet.shutdown());

  describe('sign transaction', () => {
    const poolId = Cardano.PoolId('pool1ev8vy6fyj7693ergzty2t0azjvw35tvkt2vcjwpgajqs7z6u2vn');
    const outputs = {
      outputWithAssets: {
        address: Cardano.PaymentAddress(
          'addr_test1qz2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzer3jcu5d8ps7zex2k2xt3uqxgjqnnj83ws8lhrn648jjxtwq2ytjqp'
        ),
        value: {
          assets: new Map([[AssetId.TSLA, 6n]]),
          coins: 5n
        }
      },
      simpleOutput: {
        address: Cardano.PaymentAddress(
          'addr_test1qpu5vlrf4xkxv2qpwngf6cjhtw542ayty80v8dyr49rf5ewvxwdrt70qlcpeeagscasafhffqsxy36t90ldv06wqrk2qum8x5w'
        ),
        value: { coins: 11_111_111n }
      }
    };

    let props: InitializeTxProps;
    let txInternals: InitializeTxResult;

    it('successfully signs simple transaction', async () => {
      props = {
        outputs: new Set<Cardano.TxOut>([outputs.simpleOutput])
      };
      txInternals = await wallet.initializeTx(props);

      const signatures = await keyAgent.signTransaction({
        body: txInternals.body,
        hash: txInternals.hash
      });
      expect(signatures.size).toBe(2);
    });

    it('successfully signs a transaction with assets', async () => {
      props = {
        outputs: new Set<Cardano.TxOut>([outputs.outputWithAssets])
      };
      txInternals = await wallet.initializeTx(props);

      const signatures = await keyAgent.signTransaction({
        body: txInternals.body,
        hash: txInternals.hash
      });
      expect(signatures.size).toBe(2);
    });

    it('successfully signs a transaction with metadata', async () => {
      props = {
        auxiliaryData: { blob: new Map([[123n, '1234']]) },
        outputs: new Set<Cardano.TxOut>([outputs.simpleOutput])
      };
      txInternals = await wallet.initializeTx(props);

      const signatures = await keyAgent.signTransaction({
        body: txInternals.body,
        hash: txInternals.hash
      });
      expect(signatures.size).toBe(2);
    });

    it('successfully signs a transaction with validityInterval', async () => {
      props = {
        options: {
          validityInterval: {
            invalidBefore: Cardano.Slot(1),
            invalidHereafter: Cardano.Slot(999_999_999)
          }
        },
        outputs: new Set<Cardano.TxOut>([outputs.simpleOutput])
      };
      txInternals = await wallet.initializeTx(props);

      const signatures = await keyAgent.signTransaction({
        body: txInternals.body,
        hash: txInternals.hash
      });
      expect(signatures.size).toBe(2);
    });

    it('successfully signs a transaction that mints a token', async () => {
      const policyId = Cardano.PolicyId('38299ce86f8cbef9ebeecc2e94370cb49196d60c93797fffb71d3932');
      const assetId = Cardano.AssetId(`${policyId}707572706C65`);
      props = {
        mint: new Map([[assetId, 1n]]),
        outputs: new Set<Cardano.TxOut>([outputs.simpleOutput])
      };
      txInternals = await wallet.initializeTx(props);

      const signatures = await keyAgent.signTransaction({
        body: txInternals.body,
        hash: txInternals.hash
      });
      expect(signatures.size).toBe(2);
    });

    it('successfully signs stake registration and delegation transaction', async () => {
      const rewardAccount = keyAgent.knownAddresses[0].rewardAccount;
      const stakeKeyHash = Cardano.RewardAccount.toHash(rewardAccount);
      const stakeRegistrationCert = {
        __typename: Cardano.CertificateType.StakeKeyRegistration,
        stakeKeyHash
      } as Cardano.StakeAddressCertificate;
      const stakeDelegationCert = {
        __typename: Cardano.CertificateType.StakeDelegation,
        poolId,
        stakeKeyHash
      } as Cardano.StakeDelegationCertificate;

      props = {
        certificates: [stakeRegistrationCert, stakeDelegationCert],
        outputs: new Set<Cardano.TxOut>([outputs.simpleOutput])
      };
      txInternals = await wallet.initializeTx(props);

      const signatures = await keyAgent.signTransaction({
        body: txInternals.body,
        hash: txInternals.hash
      });
      expect(signatures.size).toBe(2);
    });

    it('successfully signs stake deregistration transaction', async () => {
      const rewardAccount = keyAgent.knownAddresses[0].rewardAccount;
      const stakeKeyHash = Cardano.RewardAccount.toHash(rewardAccount);
      const stakeDeregistrationCert = {
        __typename: Cardano.CertificateType.StakeKeyDeregistration,
        stakeKeyHash
      } as Cardano.StakeAddressCertificate;

      props = {
        certificates: [stakeDeregistrationCert],
        outputs: new Set<Cardano.TxOut>([outputs.simpleOutput])
      };
      txInternals = await wallet.initializeTx(props);

      const signatures = await keyAgent.signTransaction({
        body: txInternals.body,
        hash: txInternals.hash
      });
      expect(signatures.size).toBe(2);
    });

    it.skip('successfully signs pool registration transaction', async () => {
      const rewardAccount = keyAgent.knownAddresses[0].rewardAccount;
      const poolRewardAcc = Cardano.RewardAccount('stake_test1uqfu74w3wh4gfzu8m6e7j987h4lq9r3t7ef5gaw497uu85qsqfy27');
      const metadataJson = {
        hash: Crypto.Hash32ByteBase16('0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5'),
        url: 'https://example.com'
      };
      const vrfVkHex = Cardano.VrfVkHex('198890ad6c92e80fbdab554dda02da9fb49d001bbd96181f3e07f7a6ab0d0640');
      const poolRegistrationCert = {
        __typename: Cardano.CertificateType.PoolRegistration,
        poolParameters: {
          cost: 340_000_000n,
          id: poolId,
          margin: { denominator: 2, numerator: 1 },
          metadataJson,
          owners: [rewardAccount, poolRewardAcc],
          pledge: 500_000_000n,
          relays: [],
          rewardAccount: poolRewardAcc,
          vrf: vrfVkHex
        }
      } as Cardano.PoolRegistrationCertificate;
      props = {
        certificates: [poolRegistrationCert],
        outputs: new Set<Cardano.TxOut>([outputs.simpleOutput])
      };
      txInternals = await wallet.initializeTx(props);

      const signatures = await keyAgent.signTransaction({
        body: txInternals.body,
        hash: txInternals.hash
      });
      expect(signatures.size).toBe(2);
    });

    it('throws if signed transaction hash doesnt match hash computed by the wallet', async () => {
      await expect(
        keyAgent.signTransaction({
          body: txInternals.body,
          hash: 'non-matching' as unknown as Cardano.TransactionId
        })
      ).rejects.toThrow();
    });
  });

  it('can be created with any account index', async () => {
    const trezorKeyAgentWithRandomIndex = await TrezorKeyAgent.createWithDevice(
      {
        accountIndex: 5,
        chainId: Cardano.ChainIds.Preprod,
        trezorConfig
      },
      mockKeyAgentDependencies()
    );
    expect(trezorKeyAgentWithRandomIndex).toBeInstanceOf(TrezorKeyAgent);
    expect(trezorKeyAgentWithRandomIndex.accountIndex).toEqual(5);
    expect(trezorKeyAgentWithRandomIndex.extendedAccountPublicKey).not.toEqual(keyAgent.extendedAccountPublicKey);
  });

  test('__typename', () => {
    expect(typeof keyAgent.serializableData.__typename).toBe('string');
  });

  test('chainId', () => {
    expect(keyAgent.chainId).toBe(Cardano.ChainIds.Preprod);
  });

  test('accountIndex', () => {
    expect(typeof keyAgent.accountIndex).toBe('number');
  });

  test('knownAddresses', () => {
    expect(Array.isArray(keyAgent.knownAddresses)).toBe(true);
  });

  test('extendedAccountPublicKey', () => {
    expect(typeof keyAgent.extendedAccountPublicKey).toBe('string');
  });

  describe('serializableData', () => {
    let serializableData: SerializableTrezorKeyAgentData;

    beforeEach(() => {
      serializableData = keyAgent.serializableData as SerializableTrezorKeyAgentData;
    });

    it('all fields are of correct types', () => {
      expect(typeof serializableData.__typename).toBe('string');
      expect(typeof serializableData.accountIndex).toBe('number');
      expect(typeof serializableData.chainId).toBe('object');
      expect(typeof serializableData.extendedAccountPublicKey).toBe('string');
      expect(Array.isArray(serializableData.knownAddresses)).toBe(true);
    });

    it('is serializable', () => {
      expect(JSON.parse(JSON.stringify(serializableData))).toEqual(serializableData);
    });
  });
});
