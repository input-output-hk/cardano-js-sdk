import {
  Cardano,
  ChainHistoryProvider,
  NetworkInfoProvider,
  RewardsProvider,
  TxSubmitProvider,
  UtxoProvider
} from '@cardano-sdk/core';
import { createStubStakePoolProvider } from '@cardano-sdk/util-dev';
import { filter, firstValueFrom } from 'rxjs';
import { dummyLogger as logger } from 'ts-log';

import * as mocks from '../mocks';
import { AddressType, GroupedAddress } from '@cardano-sdk/key-management';
import { ConnectionStatusTracker, PollingConfig, SingleAddressWallet, setupWallet } from '../../src';
import { WalletStores, createInMemoryWalletStores } from '../../src/persistence';
import { testAsyncKeyAgent } from '../../../key-management/test/mocks';
import { waitForWalletStateSettle } from '../util';

const name = 'Test Wallet';
const address = mocks.utxo[0][0].address!;
const rewardAccount = mocks.rewardAccount;

interface Providers {
  rewardsProvider: RewardsProvider;
  utxoProvider: UtxoProvider;
  chainHistoryProvider: ChainHistoryProvider;
  networkInfoProvider: NetworkInfoProvider;
  connectionStatusTracker$?: ConnectionStatusTracker;
  txSubmitProvider: TxSubmitProvider;
}

const createWallet = async (stores: WalletStores, providers: Providers, pollingConfig?: PollingConfig) => {
  const { wallet } = await setupWallet({
    createKeyAgent: async (dependencies) => {
      const groupedAddress: GroupedAddress = {
        accountIndex: 0,
        address,
        index: 0,
        networkId: Cardano.NetworkId.Testnet,
        rewardAccount,
        stakeKeyDerivationPath: mocks.stakeKeyDerivationPath,
        type: AddressType.External
      };
      const asyncKeyAgent = await testAsyncKeyAgent([groupedAddress], dependencies);
      asyncKeyAgent.deriveAddress = jest.fn().mockResolvedValue(groupedAddress);
      return asyncKeyAgent;
    },
    createWallet: async (keyAgent) => {
      const {
        txSubmitProvider,
        rewardsProvider,
        utxoProvider,
        chainHistoryProvider,
        networkInfoProvider,
        connectionStatusTracker$
      } = providers;
      const assetProvider = mocks.mockAssetProvider();
      const stakePoolProvider = createStubStakePoolProvider();

      return new SingleAddressWallet(
        { name, polling: pollingConfig },
        {
          assetProvider,
          chainHistoryProvider,
          connectionStatusTracker$,
          keyAgent,
          logger,
          networkInfoProvider,
          rewardsProvider,
          stakePoolProvider,
          stores,
          txSubmitProvider,
          utxoProvider
        }
      );
    },
    logger
  });
  return wallet;
};

const txOut: Cardano.TxOut = {
  address: Cardano.Address(
    'addr_test1qz2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzer3jcu5d8ps7zex2k2xt3uqxgjqnnj83ws8lhrn648jjxtwq2ytjqp'
  ),
  value: {
    coins: 10n
  }
};

const txBody: Cardano.TxBody = {
  fee: 10n,
  inputs: [
    {
      index: 0,
      txId: Cardano.TransactionId('0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5')
    }
  ],
  outputs: [txOut],
  validityInterval: {
    invalidHereafter: Cardano.Slot(mocks.ledgerTip.slot.valueOf() + 10)
  }
};

const vkey = '6199186adb51974690d7247d2646097d2c62763b767b528816fb7ed3f9f55d39';
const signature =
  // eslint-disable-next-line max-len
  'bdea87fca1b4b4df8a9b8fb4183c0fab2f8261eb6c5e4bc42c800bb9c8918755bdea87fca1b4b4df8a9b8fb4183c0fab2f8261eb6c5e4bc42c800bb9c8918755';
const tx: Cardano.Tx = {
  body: txBody,
  id: Cardano.TransactionId('de9d33f66cffff721673219b19470aec81d96bc9253182369e41eec58389a448'),
  witness: {
    signatures: new Map([[Cardano.Ed25519PublicKey(vkey), Cardano.Ed25519Signature(signature)]])
  }
};

describe('SingleAddressWallet rollback', () => {
  it('Rollback transaction is resubmitted', async () => {
    const stores = createInMemoryWalletStores();
    const rewardsProvider = mocks.mockRewardsProvider();
    const networkInfoProvider = mocks.mockNetworkInfoProvider();
    const chainHistoryProvider = mocks.mockChainHistoryProvider();
    const utxoProvider = mocks.mockUtxoProvider();
    const txSubmitProvider = mocks.mockTxSubmitProvider();

    const secondTip = {
      blockNo: 1_111_112,
      hash: '10d64cc11e9b20e15b6c46aa7b1fed11246f438e62225655a30ea47bf8cc22d0',
      slot: Cardano.Slot(mocks.ledgerTip.slot.valueOf() + 1)
    };

    networkInfoProvider.ledgerTip = jest.fn().mockResolvedValueOnce(mocks.ledgerTip).mockResolvedValueOnce(secondTip);

    const histTx1 = mocks.queryTransactionsResult.pageResults[0];
    const rollBackTx = { ...mocks.queryTransactionsResult.pageResults[1], id: tx.id };
    if (rollBackTx.body.validityInterval?.invalidHereafter) {
      rollBackTx.body.validityInterval.invalidHereafter = Cardano.Slot(secondTip.slot.valueOf() + 1);
    }

    const newTx = {
      ...rollBackTx,
      id: Cardano.TransactionId('fff4edf9712d2b619edb6ac86861fe93a730693183a262b165fcc1ba1bc99caa')
    };

    chainHistoryProvider.transactionsByAddresses = jest
      .fn()
      .mockResolvedValueOnce({ pageResults: [histTx1, rollBackTx], totalResultCount: 2 })
      .mockResolvedValueOnce({ pageResults: [newTx], totalResultCount: 1 })
      .mockResolvedValueOnce({ pageResults: [histTx1, newTx], totalResultCount: 2 });

    stores.volatileTransactions.set([
      {
        confirmedAt: rollBackTx.blockHeader.slot,
        tx
      }
    ]);

    const wallet = await createWallet(
      stores,
      {
        chainHistoryProvider,
        networkInfoProvider,
        rewardsProvider,
        txSubmitProvider,
        utxoProvider
      },
      { consideredOutOfSyncAfter: 5, interval: 0 }
    );

    await firstValueFrom(wallet.transactions.history$.pipe(filter((v) => v.some(({ id }) => id === newTx.id))));
    expect(txSubmitProvider.submitTx).toHaveBeenCalled();

    await waitForWalletStateSettle(wallet);

    wallet.shutdown();
  });
});
