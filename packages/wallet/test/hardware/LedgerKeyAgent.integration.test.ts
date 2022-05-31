import { Cardano } from '@cardano-sdk/core';
import { CommunicationType, KeyAgent, LedgerKeyAgent, restoreKeyAgent, util } from '../../src/KeyManagement';
import { ObservableWallet, SingleAddressWallet } from '../../src';
import { createStubStakePoolProvider } from '@cardano-sdk/util-dev';
import { firstValueFrom } from 'rxjs';
import {
  mockAssetProvider,
  mockChainHistoryProvider,
  mockNetworkInfoProvider,
  mockTxSubmitProvider,
  mockUtxoProvider,
  mockWalletProvider
} from '../mocks';

const createWallet = (keyAgent: KeyAgent) => {
  const txSubmitProvider = mockTxSubmitProvider();
  const walletProvider = mockWalletProvider();
  const stakePoolProvider = createStubStakePoolProvider();
  const networkInfoProvider = mockNetworkInfoProvider();
  const assetProvider = mockAssetProvider();
  const utxoProvider = mockUtxoProvider();
  const asyncKeyAgent = util.createAsyncKeyAgent(keyAgent);
  const chainHistoryProvider = mockChainHistoryProvider();
  return new SingleAddressWallet(
    { name: 'Wallet1' },
    {
      assetProvider,
      chainHistoryProvider,
      keyAgent: asyncKeyAgent,
      networkInfoProvider,
      stakePoolProvider,
      txSubmitProvider,
      utxoProvider,
      walletProvider
    }
  );
};

const getAddress = async (wallet: ObservableWallet) => (await firstValueFrom(wallet.addresses$))[0].address;

describe('LedgerKeyAgent+SingleAddressWallet', () => {
  test('creating and restoring LedgerKeyAgent wallet', async () => {
    const freshKeyAgent = await LedgerKeyAgent.createWithDevice({
      communicationType: CommunicationType.Node,
      networkId: Cardano.NetworkId.testnet,
      protocolMagic: 1_097_911_063
    });
    const freshWallet = createWallet(freshKeyAgent);
    const restoredKeyAgent = await restoreKeyAgent(freshKeyAgent.serializableData);
    const restoredWallet = createWallet(restoredKeyAgent);
    expect(await getAddress(freshWallet)).toEqual(await getAddress(restoredWallet));
    // TODO: finalizeTx with both wallets, assert that signature equals
    freshWallet.shutdown();
    restoredWallet.shutdown();
  });
});
