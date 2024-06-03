import * as Crypto from '@cardano-sdk/crypto';
import {
  AddressType,
  Bip32Account,
  GroupedAddress,
  util as KeyManagementUtil,
  KeyPurpose,
  KeyRole
} from '@cardano-sdk/key-management';
import {
  BaseWallet,
  ObservableWallet,
  ScriptAddress,
  combineInputResolvers,
  createBackendInputResolver,
  createInputResolver,
  createPersonalWallet,
  requiresForeignSignatures
} from '../../src';
import { Cardano, ChainHistoryProvider } from '@cardano-sdk/core';
import { DrepScriptHashVoter } from '@cardano-sdk/core/dist/cjs/Cardano';
import { createAsyncKeyAgent, signTx, toSignedTx, waitForWalletStateSettle } from '../util';
import { createStubStakePoolProvider, mockProviders as mocks } from '@cardano-sdk/util-dev';
import { dummyLogger as logger } from 'ts-log';
import { of } from 'rxjs';

const createMockChainHistoryProvider = (txs: Cardano.HydratedTx[] = []): ChainHistoryProvider => {
  const chainHistoryProvider = {
    blocksByHashes: jest.fn(),
    healthCheck: jest.fn(),
    transactionsByAddresses: jest.fn(),
    transactionsByHashes: jest.fn()
  };
  chainHistoryProvider.blocksByHashes.mockResolvedValue(txs);
  chainHistoryProvider.transactionsByHashes.mockResolvedValue(txs);
  chainHistoryProvider.transactionsByAddresses.mockResolvedValue(txs);
  return chainHistoryProvider;
};

describe('WalletUtil', () => {
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
      const resolver = createInputResolver({
        transactions: { outgoing: { signed$: of() } },
        utxo: { available$: of(utxo) }
      });
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

    it('resolveInput resolves inputs from provided hints', async () => {
      const tx = {
        body: {
          outputs: [
            {
              address: Cardano.PaymentAddress(
                'addr_test1qzs0umu0s2ammmpw0hea0w2crtcymdjvvlqngpgqy76gpfnuzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475qp3y3vz'
              ),
              value: { coins: 50_000_000n }
            },
            {
              address: Cardano.PaymentAddress(
                'addr_test1qzs0umu0s2ammmpw0hea0w2crtcymdjvvlqngpgqy76gpfnuzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475qp3y3vz'
              ),
              value: { coins: 150_000_000n }
            }
          ]
        },
        id: Cardano.TransactionId('0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5')
      } as Cardano.HydratedTx;

      const resolver = createInputResolver({
        transactions: { outgoing: { signed$: of() } },
        utxo: { available$: of([]) }
      });

      expect(
        await resolver.resolveInput(
          {
            index: 0,
            txId: Cardano.TransactionId('0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5')
          },
          { hints: [tx] }
        )
      ).toEqual({
        address:
          'addr_test1qzs0umu0s2ammmpw0hea0w2crtcymdjvvlqngpgqy76gpfnuzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475qp3y3vz',
        value: { coins: 50_000_000n }
      });

      expect(
        await resolver.resolveInput(
          {
            index: 1,
            txId: Cardano.TransactionId('0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5')
          },
          { hints: [tx] }
        )
      ).toEqual({
        address:
          'addr_test1qzs0umu0s2ammmpw0hea0w2crtcymdjvvlqngpgqy76gpfnuzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475qp3y3vz',
        value: { coins: 150_000_000n }
      });
    });

    it('resolveInput resolves inputs from provided signed transactions utxo set', async () => {
      const signedTxs = mocks.queryTransactionsResult.pageResults.map(toSignedTx);

      const resolver = createInputResolver({
        transactions: { outgoing: { signed$: of(signedTxs) } },
        utxo: { available$: of() }
      });
      expect(
        await resolver.resolveInput({
          index: 0,
          txId: signedTxs[0].tx.id
        })
      ).toEqual({
        address:
          'addr_test1qpfhhfy2qgls50r9u4yh0l7z67xpg0a5rrhkmvzcuqrd0znuzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475q9gw0lz',
        value: { coins: 5_000_000n }
      });
      expect(
        await resolver.resolveInput({
          index: 0,
          txId: Cardano.TransactionId('0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5')
        })
      ).toBeNull();
    });
  });

  describe('createBackendInputResolver', () => {
    it('resolveInput resolves inputs from provided chain history provider', async () => {
      const tx = {
        body: {
          outputs: [
            {
              address: Cardano.PaymentAddress(
                'addr_test1qzs0umu0s2ammmpw0hea0w2crtcymdjvvlqngpgqy76gpfnuzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475qp3y3vz'
              ),
              value: { coins: 50_000_000n }
            },
            {
              address: Cardano.PaymentAddress(
                'addr_test1qzs0umu0s2ammmpw0hea0w2crtcymdjvvlqngpgqy76gpfnuzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475qp3y3vz'
              ),
              value: { coins: 150_000_000n }
            }
          ]
        }
      } as Cardano.HydratedTx;

      const resolver = createBackendInputResolver(createMockChainHistoryProvider([tx]));

      expect(
        await resolver.resolveInput({
          index: 0,
          txId: Cardano.TransactionId('0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5')
        })
      ).toEqual({
        address:
          'addr_test1qzs0umu0s2ammmpw0hea0w2crtcymdjvvlqngpgqy76gpfnuzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475qp3y3vz',
        value: { coins: 50_000_000n }
      });

      expect(
        await resolver.resolveInput({
          index: 1,
          txId: Cardano.TransactionId('0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5')
        })
      ).toEqual({
        address:
          'addr_test1qzs0umu0s2ammmpw0hea0w2crtcymdjvvlqngpgqy76gpfnuzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475qp3y3vz',
        value: { coins: 150_000_000n }
      });
    });

    it('resolveInput resolves inputs from provided hints', async () => {
      const tx = {
        body: {
          outputs: [
            {
              address: Cardano.PaymentAddress(
                'addr_test1qzs0umu0s2ammmpw0hea0w2crtcymdjvvlqngpgqy76gpfnuzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475qp3y3vz'
              ),
              value: { coins: 50_000_000n }
            },
            {
              address: Cardano.PaymentAddress(
                'addr_test1qzs0umu0s2ammmpw0hea0w2crtcymdjvvlqngpgqy76gpfnuzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475qp3y3vz'
              ),
              value: { coins: 150_000_000n }
            }
          ]
        },
        id: Cardano.TransactionId('0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5')
      } as Cardano.HydratedTx;

      const resolver = createBackendInputResolver(createMockChainHistoryProvider([]));

      expect(
        await resolver.resolveInput(
          {
            index: 0,
            txId: Cardano.TransactionId('0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5')
          },
          { hints: [tx] }
        )
      ).toEqual({
        address:
          'addr_test1qzs0umu0s2ammmpw0hea0w2crtcymdjvvlqngpgqy76gpfnuzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475qp3y3vz',
        value: { coins: 50_000_000n }
      });

      expect(
        await resolver.resolveInput(
          {
            index: 1,
            txId: Cardano.TransactionId('0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5')
          },
          { hints: [tx] }
        )
      ).toEqual({
        address:
          'addr_test1qzs0umu0s2ammmpw0hea0w2crtcymdjvvlqngpgqy76gpfnuzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475qp3y3vz',
        value: { coins: 150_000_000n }
      });
    });
  });

  describe('combineInputResolvers', () => {
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
      const resolver = combineInputResolvers(
        createInputResolver({ transactions: { outgoing: { signed$: of() } }, utxo: { available$: of(utxo) } }),
        createBackendInputResolver(createMockChainHistoryProvider())
      );

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

    it('resolveInput resolves inputs from provided chain history provider', async () => {
      const tx = {
        body: {
          outputs: [
            {
              address: Cardano.PaymentAddress(
                'addr_test1qzs0umu0s2ammmpw0hea0w2crtcymdjvvlqngpgqy76gpfnuzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475qp3y3vz'
              ),
              value: { coins: 50_000_000n }
            },
            {
              address: Cardano.PaymentAddress(
                'addr_test1qzs0umu0s2ammmpw0hea0w2crtcymdjvvlqngpgqy76gpfnuzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475qp3y3vz'
              ),
              value: { coins: 150_000_000n }
            }
          ]
        }
      } as Cardano.HydratedTx;

      const resolver = combineInputResolvers(
        createInputResolver({ transactions: { outgoing: { signed$: of() } }, utxo: { available$: of([]) } }),
        createBackendInputResolver(createMockChainHistoryProvider([tx]))
      );

      expect(
        await resolver.resolveInput({
          index: 0,
          txId: Cardano.TransactionId('0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5')
        })
      ).toEqual({
        address:
          'addr_test1qzs0umu0s2ammmpw0hea0w2crtcymdjvvlqngpgqy76gpfnuzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475qp3y3vz',
        value: { coins: 50_000_000n }
      });

      expect(
        await resolver.resolveInput({
          index: 1,
          txId: Cardano.TransactionId('0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5')
        })
      ).toEqual({
        address:
          'addr_test1qzs0umu0s2ammmpw0hea0w2crtcymdjvvlqngpgqy76gpfnuzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475qp3y3vz',
        value: { coins: 150_000_000n }
      });
    });

    it('can resolve inputs from own transactions, hints and from chain history provider', async () => {
      const hints = [
        {
          body: {
            outputs: [
              {
                address: Cardano.PaymentAddress(
                  'addr_test1qzs0umu0s2ammmpw0hea0w2crtcymdjvvlqngpgqy76gpfnuzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475qp3y3vz'
                ),
                value: { coins: 200_000_000n }
              }
            ]
          },
          id: Cardano.TransactionId('0000bbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0FFFFFFFFFF')
        } as Cardano.HydratedTx
      ];

      const tx = {
        body: {
          outputs: [
            {
              address: Cardano.PaymentAddress(
                'addr_test1qzs0umu0s2ammmpw0hea0w2crtcymdjvvlqngpgqy76gpfnuzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475qp3y3vz'
              ),
              value: { coins: 50_000_000n }
            },
            {
              address: Cardano.PaymentAddress(
                'addr_test1qzs0umu0s2ammmpw0hea0w2crtcymdjvvlqngpgqy76gpfnuzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475qp3y3vz'
              ),
              value: { coins: 150_000_000n }
            }
          ]
        }
      } as Cardano.HydratedTx;

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

      const resolver = combineInputResolvers(
        createInputResolver({ transactions: { outgoing: { signed$: of() } }, utxo: { available$: of(utxo) } }),
        createBackendInputResolver(createMockChainHistoryProvider([tx]))
      );

      expect(
        await resolver.resolveInput(
          {
            index: 0,
            txId: Cardano.TransactionId('0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5')
          },
          { hints }
        )
      ).toEqual({
        address: 'addr_test1vr8nl4u0u6fmtfnawx2rxfz95dy7m46t6dhzdftp2uha87syeufdg',
        value: { coins: 50_000_000n }
      });

      expect(
        await resolver.resolveInput(
          {
            index: 0,
            txId: Cardano.TransactionId('0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e7FFFFFFFF')
          },
          { hints }
        )
      ).toEqual({
        address:
          'addr_test1qzs0umu0s2ammmpw0hea0w2crtcymdjvvlqngpgqy76gpfnuzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475qp3y3vz',
        value: { coins: 50_000_000n }
      });

      expect(
        await resolver.resolveInput(
          {
            index: 1,
            txId: Cardano.TransactionId('0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e7FFFFFFFF')
          },
          { hints }
        )
      ).toEqual({
        address:
          'addr_test1qzs0umu0s2ammmpw0hea0w2crtcymdjvvlqngpgqy76gpfnuzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475qp3y3vz',
        value: { coins: 150_000_000n }
      });
      expect(
        await resolver.resolveInput(
          {
            index: 0,
            txId: Cardano.TransactionId('0000bbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0FFFFFFFFFF')
          },
          { hints }
        )
      ).toEqual({
        address:
          'addr_test1qzs0umu0s2ammmpw0hea0w2crtcymdjvvlqngpgqy76gpfnuzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475qp3y3vz',
        value: { coins: 200_000_000n }
      });
    });

    it('resolveInput resolves to null if the input can not be found', async () => {
      const resolver = combineInputResolvers(
        createInputResolver({ transactions: { outgoing: { signed$: of() } }, utxo: { available$: of([]) } }),
        createBackendInputResolver(createMockChainHistoryProvider())
      );

      expect(
        await resolver.resolveInput({
          index: 0,
          txId: Cardano.TransactionId('0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d4')
        })
      ).toBeNull();
    });
  });

  describe('requiresForeignSignatures', () => {
    const address = mocks.utxo[0][0].address!;
    let txSubmitProvider: mocks.TxSubmitProviderStub;
    let networkInfoProvider: mocks.NetworkInfoProviderStub;
    let wallet: BaseWallet;
    let utxoProvider: mocks.UtxoProviderStub;
    let tx: Cardano.Tx;

    const foreignRewardAccount = Cardano.RewardAccount(
      'stake_test1uqfu74w3wh4gfzu8m6e7j987h4lq9r3t7ef5gaw497uu85qsqfy27'
    );
    const foreignRewardAccountHash = Cardano.RewardAccount.toHash(foreignRewardAccount);

    let dRepCredential: Crypto.Ed25519PublicKeyHex;
    let dRepKeyHash: Crypto.Hash28ByteBase16;
    const foreignDRepKeyHash = Crypto.Hash28ByteBase16('8293d319ef5b3ac72366dd28006bd315b715f7e7cfcbd3004129b80d');

    beforeEach(async () => {
      txSubmitProvider = mocks.mockTxSubmitProvider();
      networkInfoProvider = mocks.mockNetworkInfoProvider();
      utxoProvider = mocks.mockUtxoProvider();
      const assetProvider = mocks.mockAssetProvider();
      const stakePoolProvider = createStubStakePoolProvider();
      const rewardsProvider = mocks.mockRewardsProvider();
      const chainHistoryProvider = mocks.mockChainHistoryProvider();
      const groupedAddress: GroupedAddress = {
        accountIndex: 0,
        address,
        index: 0,
        networkId: Cardano.NetworkId.Testnet,
        purpose: KeyPurpose.MULTI_SIG,
        rewardAccount: mocks.rewardAccount,
        stakeKeyDerivationPath: {
          index: 0,
          purpose: KeyPurpose.STANDARD,
          role: KeyRole.Stake
        },
        type: AddressType.External
      };
      const asyncKeyAgent = await createAsyncKeyAgent();
      const bip32Account = await Bip32Account.fromAsyncKeyAgent(asyncKeyAgent);
      bip32Account.deriveAddress = jest.fn().mockResolvedValue(groupedAddress);
      wallet = createPersonalWallet(
        { name: 'Test Wallet' },
        {
          assetProvider,
          bip32Account,
          chainHistoryProvider,
          logger,
          networkInfoProvider,
          rewardsProvider,
          stakePoolProvider,
          txSubmitProvider,
          utxoProvider,
          witnesser: KeyManagementUtil.createBip32Ed25519Witnesser(asyncKeyAgent)
        }
      );

      await waitForWalletStateSettle(wallet);

      const props = {
        certificates: [
          {
            __typename: Cardano.CertificateType.StakeDeregistration,
            stakeCredential: {
              hash: Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(mocks.stakeKeyHash),
              type: Cardano.CredentialType.KeyHash
            }
          } as Cardano.StakeAddressCertificate
        ],
        collaterals: new Set([mocks.utxo[2][0]]),
        outputs: new Set([
          {
            address: Cardano.PaymentAddress(
              'addr_test1qpu5vlrf4xkxv2qpwngf6cjhtw542ayty80v8dyr49rf5ewvxwdrt70qlcpeeagscasafhffqsxy36t90ldv06wqrk2qum8x5w'
            ),
            value: { coins: 11_111_111n }
          }
        ])
      };

      tx = await signTx({
        addresses$: wallet.addresses$,
        tx: await wallet.initializeTx(props),
        walletUtil: wallet.util
      });

      dRepCredential = (await wallet.governance.getPubDRepKey())!;
      dRepKeyHash = Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(
        (await Crypto.Ed25519PublicKey.fromHex(dRepCredential).hash()).hex()
      );
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

      expect(await requiresForeignSignatures(tx, wallet)).toBeFalsy();
    });

    describe('StakeCredential based check', () => {
      it('detects foreign stakeKeyHash in StakeDeregistration certificate', async () => {
        tx.body.certificates = [
          {
            __typename: Cardano.CertificateType.StakeDeregistration,
            stakeCredential: {
              hash: Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(foreignRewardAccountHash),
              type: Cardano.CredentialType.KeyHash
            }
          } as Cardano.StakeAddressCertificate,
          ...tx.body.certificates!
        ];
        expect(await requiresForeignSignatures(tx, wallet)).toBeTruthy();
      });

      it('detects foreign stakeKeyHash in StakeDelegation certificate', async () => {
        tx.body.certificates = [
          {
            __typename: Cardano.CertificateType.StakeDelegation,
            poolId: Cardano.PoolId.fromKeyHash(foreignRewardAccountHash),
            stakeCredential: {
              hash: Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(foreignRewardAccountHash),
              type: Cardano.CredentialType.KeyHash
            }
          } as Cardano.StakeDelegationCertificate,
          ...tx.body.certificates!
        ];
        expect(await requiresForeignSignatures(tx, wallet)).toBeTruthy();
      });

      it('detects foreign pool owner in PoolRegistration certificate', async () => {
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
              owners: [foreignRewardAccount],
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

        expect(await requiresForeignSignatures(tx, wallet)).toBeTruthy();
      });

      it('detects foreign poolId in PoolRetirement certificate', async () => {
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

      it('returns false when a StakeRegistration certificate can not be accounted for', async () => {
        tx.body.certificates = [
          {
            __typename: Cardano.CertificateType.StakeRegistration,
            stakeCredential: {
              hash: Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(foreignRewardAccountHash),
              type: Cardano.CredentialType.KeyHash
            }
          } as Cardano.StakeAddressCertificate,
          ...tx.body.certificates!
        ];
        expect(await requiresForeignSignatures(tx, wallet)).toBeFalsy();
      });

      it('accepts valid conway certificates', async () => {
        tx.body.certificates = [
          {
            __typename: Cardano.CertificateType.Registration,
            stakeCredential: {
              hash: Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(mocks.stakeKeyHash),
              type: Cardano.CredentialType.KeyHash
            }
          } as Cardano.NewStakeAddressCertificate,
          {
            __typename: Cardano.CertificateType.Unregistration,
            stakeCredential: {
              hash: Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(mocks.stakeKeyHash),
              type: Cardano.CredentialType.KeyHash
            }
          } as Cardano.NewStakeAddressCertificate,
          {
            __typename: Cardano.CertificateType.VoteDelegation,
            stakeCredential: {
              hash: Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(mocks.stakeKeyHash),
              type: Cardano.CredentialType.KeyHash
            }
          } as Cardano.VoteDelegationCertificate,
          {
            __typename: Cardano.CertificateType.StakeVoteDelegation,
            stakeCredential: {
              hash: Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(mocks.stakeKeyHash),
              type: Cardano.CredentialType.KeyHash
            }
          } as Cardano.StakeVoteDelegationCertificate,
          {
            __typename: Cardano.CertificateType.StakeRegistrationDelegation,
            stakeCredential: {
              hash: Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(mocks.stakeKeyHash),
              type: Cardano.CredentialType.KeyHash
            }
          } as Cardano.StakeRegistrationDelegationCertificate,
          {
            __typename: Cardano.CertificateType.VoteRegistrationDelegation,
            stakeCredential: {
              hash: Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(mocks.stakeKeyHash),
              type: Cardano.CredentialType.KeyHash
            }
          } as Cardano.VoteRegistrationDelegationCertificate,
          {
            __typename: Cardano.CertificateType.StakeVoteRegistrationDelegation,
            stakeCredential: {
              hash: Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(mocks.stakeKeyHash),
              type: Cardano.CredentialType.KeyHash
            }
          } as Cardano.StakeVoteRegistrationDelegationCertificate,
          ...tx.body.certificates!
        ];

        expect(await requiresForeignSignatures(tx, wallet)).toBeFalsy();
      });

      it('detects foreign VoteDelegation', async () => {
        tx.body.certificates = [
          {
            __typename: Cardano.CertificateType.VoteDelegation,
            stakeCredential: {
              hash: Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(foreignRewardAccountHash),
              type: Cardano.CredentialType.KeyHash
            }
          } as Cardano.VoteDelegationCertificate,
          ...tx.body.certificates!
        ];

        expect(await requiresForeignSignatures(tx, wallet)).toBeTruthy();
      });

      it('detects foreign StakeVoteDelegation', async () => {
        tx.body.certificates = [
          {
            __typename: Cardano.CertificateType.StakeVoteDelegation,
            stakeCredential: {
              hash: Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(foreignRewardAccountHash),
              type: Cardano.CredentialType.KeyHash
            }
          } as Cardano.StakeVoteDelegationCertificate,
          ...tx.body.certificates!
        ];

        expect(await requiresForeignSignatures(tx, wallet)).toBeTruthy();
      });

      it('detects foreign StakeRegistrationDelegation', async () => {
        tx.body.certificates = [
          {
            __typename: Cardano.CertificateType.StakeRegistrationDelegation,
            stakeCredential: {
              hash: Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(foreignRewardAccountHash),
              type: Cardano.CredentialType.KeyHash
            }
          } as Cardano.StakeRegistrationDelegationCertificate,
          ...tx.body.certificates!
        ];

        expect(await requiresForeignSignatures(tx, wallet)).toBeTruthy();
      });

      it('detects foreign VoteRegistrationDelegation', async () => {
        tx.body.certificates = [
          {
            __typename: Cardano.CertificateType.VoteRegistrationDelegation,
            stakeCredential: {
              hash: Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(foreignRewardAccountHash),
              type: Cardano.CredentialType.KeyHash
            }
          } as Cardano.VoteRegistrationDelegationCertificate,
          ...tx.body.certificates!
        ];

        expect(await requiresForeignSignatures(tx, wallet)).toBeTruthy();
      });

      it('detects foreign stake_vote_reg_deleg_cert', async () => {
        tx.body.certificates = [
          {
            __typename: Cardano.CertificateType.StakeVoteRegistrationDelegation,
            stakeCredential: {
              hash: Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(foreignRewardAccountHash),
              type: Cardano.CredentialType.KeyHash
            }
          } as Cardano.StakeVoteRegistrationDelegationCertificate,
          ...tx.body.certificates!
        ];

        expect(await requiresForeignSignatures(tx, wallet)).toBeTruthy();
      });

      it('detects foreign Unregistration', async () => {
        tx.body.certificates = [
          {
            __typename: Cardano.CertificateType.Unregistration,
            stakeCredential: {
              hash: Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(foreignRewardAccountHash),
              type: Cardano.CredentialType.KeyHash
            }
          } as Cardano.NewStakeAddressCertificate,
          ...tx.body.certificates!
        ];

        expect(await requiresForeignSignatures(tx, wallet)).toBeTruthy();
      });
    });

    describe('MIR certificates', () => {
      it('returns true when at least one certificate can not be accounted for', async () => {
        tx.body.certificates = [
          {
            __typename: Cardano.CertificateType.MIR,
            kind: Cardano.MirCertificateKind.ToStakeCreds,
            pot: Cardano.MirCertificatePot.Treasury,
            quantity: 100n,
            stakeCredential: Cardano.Address.fromString(
              'stake_test1uqfu74w3wh4gfzu8m6e7j987h4lq9r3t7ef5gaw497uu85qsqfy27'
            )!
              .asReward()!
              .getPaymentCredential()
          } as Cardano.MirCertificate,
          ...tx.body.certificates!
        ];

        expect(tx.body.inputs.length).toBeGreaterThanOrEqual(1);
        expect(tx.body.certificates!.length).toBe(2);
        expect(await requiresForeignSignatures(tx, wallet)).toBeTruthy();
      });

      it('detects as foreign if type is "toOtherPot"', async () => {
        tx.body.certificates = [
          {
            __typename: Cardano.CertificateType.MIR,
            kind: Cardano.MirCertificateKind.ToOtherPot
          } as Cardano.MirCertificate,
          ...tx.body.certificates!
        ];

        expect(await requiresForeignSignatures(tx, wallet)).toBeTruthy();
      });
    });

    describe('inputs and collaterals', () => {
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

    describe('Voting procedures', () => {
      it('accepts dRep and stakePool voters', async () => {
        tx.body.votingProcedures = [
          {
            voter: {
              __typename: Cardano.VoterType.dRepKeyHash,
              credential: { hash: dRepKeyHash, type: Cardano.CredentialType.KeyHash }
            },
            votes: []
          },
          {
            voter: {
              __typename: Cardano.VoterType.stakePoolKeyHash,
              credential: { hash: Crypto.Hash28ByteBase16(mocks.stakeKeyHash), type: Cardano.CredentialType.KeyHash }
            },
            votes: []
          }
        ];

        expect(await requiresForeignSignatures(tx, wallet)).toBeFalsy();
      });

      it('detects foreign dRep voter credentials', async () => {
        tx.body.votingProcedures = [
          {
            voter: {
              __typename: Cardano.VoterType.dRepKeyHash,
              credential: { hash: foreignDRepKeyHash, type: Cardano.CredentialType.KeyHash }
            },
            votes: []
          }
        ];
        expect(await requiresForeignSignatures(tx, wallet)).toBeTruthy();
      });

      it('detects foreign stakePool voter credentials', async () => {
        tx.body.votingProcedures = [
          {
            voter: {
              __typename: Cardano.VoterType.stakePoolKeyHash,
              credential: {
                hash: Crypto.Hash28ByteBase16(foreignRewardAccountHash),
                type: Cardano.CredentialType.KeyHash
              }
            },
            votes: []
          }
        ];
        expect(await requiresForeignSignatures(tx, wallet)).toBeTruthy();
      });

      it('constitutional committee voter is always foreign', async () => {
        tx.body.votingProcedures = [
          {
            voter: {
              __typename: Cardano.VoterType.ccHotKeyHash,
              credential: {
                hash: Crypto.Hash28ByteBase16(mocks.stakeKeyHash),
                type: Cardano.CredentialType.KeyHash
              }
            },
            votes: []
          }
        ];
        expect(await requiresForeignSignatures(tx, wallet)).toBeTruthy();

        tx.body.votingProcedures = [
          {
            voter: {
              __typename: Cardano.VoterType.ccHotScriptHash,
              credential: {
                hash: Crypto.Hash28ByteBase16(mocks.stakeKeyHash),
                type: Cardano.CredentialType.ScriptHash
              }
            },
            votes: []
          }
        ];
        expect(await requiresForeignSignatures(tx, wallet)).toBeTruthy();
      });

      it('scriptHash voters are always foreign', async () => {
        tx.body.votingProcedures = [
          {
            voter: {
              __typename: Cardano.VoterType.dRepScriptHash,
              credential: {
                hash: Crypto.Hash28ByteBase16(dRepKeyHash),
                type: Cardano.CredentialType.ScriptHash
              }
            },
            votes: []
          }
        ];
        expect(await requiresForeignSignatures(tx, wallet)).toBeTruthy();
      });
    });

    describe('DRepCredential based checks', () => {
      it('accepts valid conway certificates', async () => {
        tx.body.certificates = [
          {
            __typename: Cardano.CertificateType.UnregisterDelegateRepresentative,
            dRepCredential: { hash: dRepKeyHash, type: Cardano.CredentialType.KeyHash },
            deposit: 0n
          } as Cardano.UnRegisterDelegateRepresentativeCertificate,
          {
            __typename: Cardano.CertificateType.UpdateDelegateRepresentative,
            anchor: null,
            dRepCredential: { hash: dRepKeyHash, type: Cardano.CredentialType.KeyHash }
          } as Cardano.UpdateDelegateRepresentativeCertificate,
          {
            __typename: Cardano.CertificateType.RegisterDelegateRepresentative,
            anchor: null,
            dRepCredential: { hash: dRepKeyHash, type: Cardano.CredentialType.KeyHash }
          } as Cardano.RegisterDelegateRepresentativeCertificate,
          ...tx.body.certificates!
        ];

        expect(await requiresForeignSignatures(tx, wallet)).toBeFalsy();
      });

      it('detects foreign unreg_drep_cert', async () => {
        tx.body.certificates = [
          {
            __typename: Cardano.CertificateType.UnregisterDelegateRepresentative,
            dRepCredential: { hash: foreignDRepKeyHash, type: Cardano.CredentialType.KeyHash },
            deposit: 0n
          } as Cardano.UnRegisterDelegateRepresentativeCertificate,
          ...tx.body.certificates!
        ];

        expect(await requiresForeignSignatures(tx, wallet)).toBeTruthy();
      });

      it('detects foreign update_drep_cert', async () => {
        tx.body.certificates = [
          {
            __typename: Cardano.CertificateType.UpdateDelegateRepresentative,
            anchor: null,
            dRepCredential: { hash: foreignDRepKeyHash, type: Cardano.CredentialType.KeyHash }
          } as Cardano.UpdateDelegateRepresentativeCertificate,
          ...tx.body.certificates!
        ];

        expect(await requiresForeignSignatures(tx, wallet)).toBeTruthy();
      });

      it('detects foreign register_drep_cert', async () => {
        tx.body.certificates = [
          {
            __typename: Cardano.CertificateType.RegisterDelegateRepresentative,
            anchor: null,
            dRepCredential: { hash: foreignDRepKeyHash, type: Cardano.CredentialType.KeyHash }
          } as Cardano.RegisterDelegateRepresentativeCertificate,
          ...tx.body.certificates!
        ];

        expect(await requiresForeignSignatures(tx, wallet)).toBeTruthy();
      });
    });

    describe('Script Wallet', () => {
      const scriptCredential = {
        hash: Crypto.Hash28ByteBase16('0aaa5f1de4257ee30717527c19eea5aa25cbd87f33530699dec851e9'),
        type: Cardano.CredentialType.ScriptHash
      };

      const scriptAddress: ScriptAddress = {
        address: Cardano.PaymentAddress(
          'addr_test1xq925hcausjhacc8zaf8cx0w5k4ztj7c0ue4xp5emmy9r6g24f03mep90m3sw96j0sv7afd2yh9aslen2vrfnhkg285szhu5xq'
        ),
        networkId: Cardano.NetworkId.Testnet,
        rewardAccount: Cardano.RewardAccount('stake_test17q925hcausjhacc8zaf8cx0w5k4ztj7c0ue4xp5emmy9r6gk8ctn0'),
        scripts: {
          payment: {
            __type: Cardano.ScriptType.Native,
            kind: Cardano.NativeScriptKind.RequireAllOf,
            scripts: [
              {
                __type: Cardano.ScriptType.Native,
                keyHash: mocks.stakeKeyHash,
                kind: Cardano.NativeScriptKind.RequireSignature
              }
            ]
          },
          stake: {
            __type: Cardano.ScriptType.Native,
            kind: Cardano.NativeScriptKind.RequireAllOf,
            scripts: [
              {
                __type: Cardano.ScriptType.Native,
                keyHash: mocks.stakeKeyHash,
                kind: Cardano.NativeScriptKind.RequireSignature
              }
            ]
          }
        }
      };

      const scriptWallet = {
        addresses$: of([scriptAddress]),
        utxo: {
          total$: of(mocks.utxo)
        }
      } as ObservableWallet;

      it('returns false when all inputs and certificates are accounted for ', async () => {
        // Inputs are selected by input selection algorithm
        tx.body.certificates = [
          {
            __typename: Cardano.CertificateType.StakeRegistration,
            stakeCredential: scriptCredential
          } as Cardano.StakeAddressCertificate
        ];

        expect(tx.body.inputs.length).toBeGreaterThanOrEqual(1);
        expect(tx.body.certificates!.length).toBe(1);
        expect(await requiresForeignSignatures(tx, scriptWallet)).toBeFalsy();
      });

      it('returns false when a GenesisKeyDelegation certificate can not be accounted for ', async () => {
        tx.body.certificates = [
          {
            __typename: Cardano.CertificateType.GenesisKeyDelegation,
            genesisDelegateHash: Crypto.Hash28ByteBase16('00000000000000000000000000000000000000000000000000000000'),
            genesisHash: Crypto.Hash28ByteBase16('00000000000000000000000000000000000000000000000000000000'),
            vrfKeyHash: Crypto.Hash32ByteBase16('0000000000000000000000000000000000000000000000000000000000000000')
          } as Cardano.GenesisKeyDelegationCertificate
        ];

        expect(await requiresForeignSignatures(tx, scriptWallet)).toBeFalsy();
      });

      it('detects foreign credential in StakeDeregistration certificate', async () => {
        tx.body.certificates = [
          {
            __typename: Cardano.CertificateType.StakeDeregistration,
            stakeCredential: {
              hash: Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(foreignRewardAccountHash),
              type: Cardano.CredentialType.KeyHash
            }
          } as Cardano.StakeAddressCertificate
        ];

        expect(await requiresForeignSignatures(tx, scriptWallet)).toBeTruthy();
      });

      it('detects foreign stakeKeyHash in StakeDelegation certificate', async () => {
        tx.body.certificates = [
          {
            __typename: Cardano.CertificateType.StakeDelegation,
            poolId: Cardano.PoolId.fromKeyHash(foreignRewardAccountHash),
            stakeCredential: {
              hash: Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(foreignRewardAccountHash),
              type: Cardano.CredentialType.KeyHash
            }
          } as Cardano.StakeDelegationCertificate
        ];

        expect(await requiresForeignSignatures(tx, scriptWallet)).toBeTruthy();
      });

      it('detects foreign pool owner in PoolRegistration certificate', async () => {
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
              owners: [foreignRewardAccount],
              pledge: 10_000n,
              relays: [
                {
                  __typename: 'RelayByName',
                  hostname: 'localhost'
                }
              ],
              rewardAccount: Cardano.RewardAccount('stake_test17q925hcausjhacc8zaf8cx0w5k4ztj7c0ue4xp5emmy9r6gk8ctn0'),
              vrf: Cardano.VrfVkHex('641d042ed39c2c258d381060c1424f40ef8abfe25ef566f4cb22477c42b2a014')
            }
          } as Cardano.PoolRegistrationCertificate
        ];

        expect(await requiresForeignSignatures(tx, scriptWallet)).toBeTruthy();
      });

      it('detects foreign poolId in PoolRetirement certificate', async () => {
        tx.body.certificates = [
          {
            __typename: Cardano.CertificateType.PoolRetirement,
            epoch: Cardano.EpochNo(100),
            poolId: Cardano.PoolId.fromKeyHash(foreignRewardAccountHash)
          } as Cardano.PoolRetirementCertificate
        ];

        expect(await requiresForeignSignatures(tx, scriptWallet)).toBeTruthy();
      });

      it('returns false when a StakeRegistration certificate can not be accounted for', async () => {
        tx.body.certificates = [
          {
            __typename: Cardano.CertificateType.StakeRegistration,
            stakeCredential: {
              hash: Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(foreignRewardAccountHash),
              type: Cardano.CredentialType.KeyHash
            }
          } as Cardano.StakeAddressCertificate
        ];
        expect(await requiresForeignSignatures(tx, scriptWallet)).toBeFalsy();
      });

      it('accepts valid certificates', async () => {
        tx.body.certificates = [
          {
            __typename: Cardano.CertificateType.Registration,
            // using foreign intentionally because registration is not signed so it should be accepted
            stakeCredential: {
              hash: Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(mocks.stakeKeyHash),
              type: Cardano.CredentialType.KeyHash
            }
          } as Cardano.NewStakeAddressCertificate,
          {
            __typename: Cardano.CertificateType.Unregistration,
            stakeCredential: scriptCredential
          } as Cardano.NewStakeAddressCertificate,
          {
            __typename: Cardano.CertificateType.VoteDelegation,
            stakeCredential: scriptCredential
          } as Cardano.VoteDelegationCertificate,
          {
            __typename: Cardano.CertificateType.StakeVoteDelegation,
            stakeCredential: scriptCredential
          } as Cardano.StakeVoteDelegationCertificate,
          {
            __typename: Cardano.CertificateType.StakeRegistrationDelegation,
            stakeCredential: scriptCredential
          } as Cardano.StakeRegistrationDelegationCertificate,
          {
            __typename: Cardano.CertificateType.VoteRegistrationDelegation,
            stakeCredential: scriptCredential
          } as Cardano.VoteRegistrationDelegationCertificate,
          {
            __typename: Cardano.CertificateType.StakeVoteRegistrationDelegation,
            stakeCredential: scriptCredential
          } as Cardano.StakeVoteRegistrationDelegationCertificate
        ];

        expect(await requiresForeignSignatures(tx, scriptWallet)).toBeFalsy();
      });

      it('detects foreign VoteDelegation', async () => {
        tx.body.certificates = [
          {
            __typename: Cardano.CertificateType.VoteDelegation,
            stakeCredential: {
              hash: Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(foreignRewardAccountHash),
              type: Cardano.CredentialType.KeyHash
            }
          } as Cardano.VoteDelegationCertificate
        ];

        expect(await requiresForeignSignatures(tx, scriptWallet)).toBeTruthy();
      });

      it('detects foreign StakeVoteDelegation', async () => {
        tx.body.certificates = [
          {
            __typename: Cardano.CertificateType.StakeVoteDelegation,
            stakeCredential: {
              hash: Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(foreignRewardAccountHash),
              type: Cardano.CredentialType.KeyHash
            }
          } as Cardano.StakeVoteDelegationCertificate
        ];

        expect(await requiresForeignSignatures(tx, scriptWallet)).toBeTruthy();
      });

      it('detects foreign StakeRegistrationDelegation', async () => {
        tx.body.certificates = [
          {
            __typename: Cardano.CertificateType.StakeRegistrationDelegation,
            stakeCredential: {
              hash: Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(foreignRewardAccountHash),
              type: Cardano.CredentialType.KeyHash
            }
          } as Cardano.StakeRegistrationDelegationCertificate
        ];

        expect(await requiresForeignSignatures(tx, scriptWallet)).toBeTruthy();
      });

      it('detects foreign VoteRegistrationDelegation', async () => {
        tx.body.certificates = [
          {
            __typename: Cardano.CertificateType.VoteRegistrationDelegation,
            stakeCredential: {
              hash: Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(foreignRewardAccountHash),
              type: Cardano.CredentialType.KeyHash
            }
          } as Cardano.VoteRegistrationDelegationCertificate
        ];

        expect(await requiresForeignSignatures(tx, scriptWallet)).toBeTruthy();
      });

      it('detects foreign stake_vote_reg_deleg_cert', async () => {
        tx.body.certificates = [
          {
            __typename: Cardano.CertificateType.StakeVoteRegistrationDelegation,
            stakeCredential: {
              hash: Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(foreignRewardAccountHash),
              type: Cardano.CredentialType.KeyHash
            }
          } as Cardano.StakeVoteRegistrationDelegationCertificate
        ];

        expect(await requiresForeignSignatures(tx, scriptWallet)).toBeTruthy();
      });

      it('detects foreign Unregistration', async () => {
        tx.body.certificates = [
          {
            __typename: Cardano.CertificateType.Unregistration,
            stakeCredential: {
              hash: Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(foreignRewardAccountHash),
              type: Cardano.CredentialType.KeyHash
            }
          } as Cardano.NewStakeAddressCertificate
        ];

        expect(await requiresForeignSignatures(tx, scriptWallet)).toBeTruthy();
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
        expect(await requiresForeignSignatures(tx, scriptWallet)).toBeTruthy();
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
        expect(await requiresForeignSignatures(tx, scriptWallet)).toBeTruthy();
      });

      it('returns true when at least one voter is not accounted for', async () => {
        tx.body.certificates = [];
        tx.body.votingProcedures = [
          {
            voter: {
              __typename: Cardano.VoterType.dRepScriptHash,
              credential: {
                hash: Crypto.Hash28ByteBase16(dRepKeyHash),
                type: Cardano.CredentialType.ScriptHash
              }
            },
            votes: []
          }
        ];
        expect(await requiresForeignSignatures(tx, scriptWallet)).toBeTruthy();
      });

      it('returns false when all voters are accounted for', async () => {
        tx.body.certificates = [];
        tx.body.votingProcedures = [
          {
            voter: {
              __typename: Cardano.VoterType.dRepScriptHash,
              credential: scriptCredential
            } as DrepScriptHashVoter,
            votes: []
          }
        ];
        expect(await requiresForeignSignatures(tx, scriptWallet)).toBeFalsy();
      });

      it('returns true when at least one dRep certificate is not accounted for', async () => {
        tx.body.certificates = [
          {
            __typename: Cardano.CertificateType.UnregisterDelegateRepresentative,
            dRepCredential: {
              hash: Crypto.Hash28ByteBase16.fromEd25519KeyHashHex(foreignRewardAccountHash),
              type: Cardano.CredentialType.KeyHash
            },
            deposit: 0n
          } as Cardano.UnRegisterDelegateRepresentativeCertificate
        ];

        expect(await requiresForeignSignatures(tx, scriptWallet)).toBeTruthy();
      });

      it('returns false when all dReps certificates are accounted for', async () => {
        tx.body.certificates = [
          {
            __typename: Cardano.CertificateType.UnregisterDelegateRepresentative,
            dRepCredential: scriptCredential,
            deposit: 0n
          } as Cardano.UnRegisterDelegateRepresentativeCertificate
        ];

        expect(await requiresForeignSignatures(tx, scriptWallet)).toBeFalsy();
      });
    });
  });
});
