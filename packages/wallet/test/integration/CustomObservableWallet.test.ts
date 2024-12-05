/* eslint-disable @typescript-eslint/no-unused-expressions */
/* eslint-disable sonarjs/no-extra-arguments */
/* eslint-disable unicorn/consistent-function-scoping */
import { BaseWallet, ObservableWallet, createPersonalWallet } from '../../src';
import { Bip32Account, GroupedAddress, util } from '@cardano-sdk/key-management';
import { Cardano, Serialization } from '@cardano-sdk/core';
import {
  OutputValidator,
  ProtocolParametersRequiredByOutputValidator,
  createOutputValidator
} from '@cardano-sdk/tx-construction';
import { RetryBackoffConfig } from 'backoff-rxjs';
import { coldObservableProvider } from '@cardano-sdk/util-rxjs';
import { createStubStakePoolProvider, mockProviders as mocks } from '@cardano-sdk/util-dev';
import { firstValueFrom, of, timer } from 'rxjs';
import { dummyLogger as logger } from 'ts-log';
import { testAsyncKeyAgent } from '../../../key-management/test/mocks';

describe('CustomObservableWallet', () => {
  describe('can create an application-specific subset of ObservableWallet interface', () => {
    type LaceBalance = {
      // Can use partial types
      utxo: Pick<ObservableWallet['balance']['utxo'], 'available$'>;
      rewardAccounts: ObservableWallet['balance']['rewardAccounts'];
    };

    /** Wallet interface as used by the application */
    interface LaceObservableWallet {
      // Interface supports multi-addresses for the most part (note plural in addresses$ and delegation.rewardAccounts$)
      // Might be missing some data (e.g. balance by address):
      // we're not sure what kind of data multi-address wallet wants to present to the users,
      // but we're open to extending the ObservableWallet interface to support more use cases.
      addresses$: ObservableWallet['addresses$'];
      delegation: {
        rewardAccounts$: ObservableWallet['delegation']['rewardAccounts$'];
      };
      balance: LaceBalance;
      submitTx: ObservableWallet['submitTx'];
    }

    it('can use BaseWallet to satisfy application-specific interface', async () => {
      // this compiles
      const extensionWallet: LaceObservableWallet = createPersonalWallet(
        { name: 'Extension Wallet' },
        {
          assetProvider: mocks.mockAssetProvider(),
          bip32Account: await Bip32Account.fromAsyncKeyAgent(await testAsyncKeyAgent()),
          chainHistoryProvider: mocks.mockChainHistoryProvider(),
          drepProvider: mocks.mockDrepProvider(),
          logger,
          networkInfoProvider: mocks.mockNetworkInfoProvider(),
          rewardsProvider: mocks.mockRewardsProvider(),
          stakePoolProvider: createStubStakePoolProvider(),
          txSubmitProvider: mocks.mockTxSubmitProvider(),
          utxoProvider: mocks.mockUtxoProvider(),
          witnesser: util.createBip32Ed25519Witnesser(await testAsyncKeyAgent())
        }
      );
      extensionWallet;
    });

    it('does not necessarily have to use BaseWallet, but can still utilize SDK utils', () => {
      // let's say we have an API endpoint to submit transaction as bytes and not as SDK's Cardano.Tx
      const submitTxBytesHexString: (tx: string) => Promise<Cardano.TransactionId> = () =>
        Promise.resolve(Cardano.TransactionId('0000000000000000000000000000000000000000000000000000000000000000'));
      // and another endpoint to get wallet addresses
      const getAddresses: () => Promise<GroupedAddress[]> = async () => [];
      // and another endpoint to get wallet's utxo balance
      const getAvailableUtxoBalance: () => Promise<Cardano.Value> = async () => ({ coins: 10_000_000n });
      // and another endpoint to get wallet's total reward accounts deposit
      const getAvailableRewardAccountsDeposit: () => Promise<Cardano.Lovelace> = async () => 200_000n;
      // and another endpoint to get wallet's reward accounts info (such as stake pool delegated to)
      const getRewardAccountsDelegation: () => Promise<Cardano.RewardAccountInfo[]> = async () => [
        {
          address: Cardano.RewardAccount('stake1u89sasnfyjtmgk8ydqfv3fdl52f36x3djedfnzfc9rkgzrcss5vgr'),
          credentialStatus: Cardano.StakeCredentialStatus.Unregistering,
          rewardBalance: 5000n
        }
      ];
      // some additional arguments might be needed to utilize SDK utils
      const retryBackoffConfig: RetryBackoffConfig = { initialInterval: 1000 };
      // for the sake of simplicity, let's say we just want to poll all backend endpoints every 10s
      const walletUpdateTrigger$ = timer(0, 10_000);

      // this compiles
      const desktopWallet: LaceObservableWallet = {
        // for the sake of simplicity, let's say we don't care about wallet's persistence/restoration
        // and want to just re-fetch data upon every subscription and then update using some interval.
        // If we did want more features, there are other SDK utils we could use
        addresses$: coldObservableProvider({
          logger,
          provider: getAddresses,
          retryBackoffConfig,
          trigger$: walletUpdateTrigger$
        }),
        balance: {
          rewardAccounts: {
            // can entirely bypass SDK and it's utils, providing custom observables
            deposit$: of(200_000n),
            rewards$: coldObservableProvider({
              logger,
              provider: getAvailableRewardAccountsDeposit,
              retryBackoffConfig,
              trigger$: walletUpdateTrigger$
            })
          },
          utxo: {
            available$: coldObservableProvider({
              logger,
              provider: getAvailableUtxoBalance,
              retryBackoffConfig,
              trigger$: walletUpdateTrigger$
            })
          }
        },
        delegation: {
          rewardAccounts$: coldObservableProvider({
            logger,
            provider: getRewardAccountsDelegation,
            retryBackoffConfig,
            trigger$: walletUpdateTrigger$
          })
        },
        submitTx(tx: Cardano.Tx) {
          // can use utils from SDK, in this case `Transaction.fromCore`
          // if you want to submit hex-encoded tx, there is also Transaction.toCore for the reverse
          const txBytes = Serialization.Transaction.fromCore(tx).toCbor();
          return submitTxBytesHexString(txBytes);
        }
      };
      desktopWallet;
    });

    describe('can use SDK abstractions that are not in scope of ObservableWallet interface', () => {
      // Let's say application depends on an OutputValidator. This util is a good example,
      // but many other utils depend on core.Cardano or ObservableWallet types,
      // which are not necessarily resolved by your custom wallet type.
      // Please let us know if you'd like to use some util
      // that is too constrained by the types - we're open to refactors
      let outputValidator: OutputValidator;

      it('can utilize BaseWallet', () => {
        const wallet: BaseWallet = {} as BaseWallet;
        // this compiles
        outputValidator = createOutputValidator({
          protocolParameters: () => firstValueFrom(wallet.protocolParameters$)
        });
        outputValidator;
      });

      it('can provide an implementation that utilize SDK utils, but doesnt depend on full ObservableWallet', () => {
        const protocolParameters: ProtocolParametersRequiredByOutputValidator = {
          coinsPerUtxoByte: 34_482,
          maxValueSize: 5000
        };
        // this compiles
        outputValidator = createOutputValidator({ protocolParameters: async () => protocolParameters });
      });

      it('can provide custom implementation', () => {
        outputValidator = {
          validateOutput: async (_output) => ({
            coinMissing: 0n,
            minimumCoin: 1_000_000n,
            tokenBundleSizeExceedsLimit: false
          })
        } as OutputValidator;
      });
    });
  });
});
