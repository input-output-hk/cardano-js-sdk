import { Cardano } from '@cardano-sdk/core';
import { SingleAddressWallet } from '@cardano-sdk/wallet';
import {
  assetProviderFactory,
  chainHistoryProviderFactory,
  keyAgentById,
  networkInfoProviderFactory,
  rewardsProviderFactory,
  stakePoolProviderFactory,
  txSubmitProviderFactory,
  utxoProviderFactory
} from '../../../src/factories';
import { env } from '../environment';
import { filter, firstValueFrom, map } from 'rxjs';
import { isNotNil } from '@cardano-sdk/util';

describe('SingleAddressWallet/metadata', () => {
  let wallet: SingleAddressWallet;
  let ownAddress: Cardano.Address;

  beforeAll(async () => {
    wallet = new SingleAddressWallet(
      { name: 'Test Wallet' },
      {
        assetProvider: await assetProviderFactory.create(env.ASSET_PROVIDER, env.ASSET_PROVIDER_PARAMS),
        chainHistoryProvider: await chainHistoryProviderFactory.create(
          env.CHAIN_HISTORY_PROVIDER,
          env.CHAIN_HISTORY_PROVIDER_PARAMS
        ),
        keyAgent: await keyAgentById(0, env.KEY_MANAGEMENT_PROVIDER, env.KEY_MANAGEMENT_PARAMS),
        networkInfoProvider: await networkInfoProviderFactory.create(
          env.NETWORK_INFO_PROVIDER,
          env.NETWORK_INFO_PROVIDER_PARAMS
        ),
        rewardsProvider: await rewardsProviderFactory.create(env.REWARDS_PROVIDER, env.REWARDS_PROVIDER_PARAMS),
        stakePoolProvider: await stakePoolProviderFactory.create(
          env.STAKE_POOL_PROVIDER,
          env.STAKE_POOL_PROVIDER_PARAMS
        ),
        txSubmitProvider: await txSubmitProviderFactory.create(env.TX_SUBMIT_PROVIDER, env.TX_SUBMIT_PROVIDER_PARAMS),
        utxoProvider: await utxoProviderFactory.create(env.UTXO_PROVIDER, env.UTXO_PROVIDER_PARAMS)
      }
    );
    ownAddress = (await firstValueFrom(wallet.addresses$))[0].address;
  });

  afterAll(() => wallet.shutdown());

  test('can submit tx with metadata and then query it', async () => {
    const auxiliaryData: Cardano.AuxiliaryData = {
      body: {
        blob: new Map([[123n, '1234']])
      }
    };
    const txInternals = await wallet.initializeTx({
      auxiliaryData,
      outputs: new Set([{ address: ownAddress, value: { coins: 1_000_000n } }])
    });
    const outgoingTx = await wallet.finalizeTx(txInternals, auxiliaryData);
    await wallet.submitTx(outgoingTx);
    const loadedTx = await firstValueFrom(
      wallet.transactions.history$.pipe(
        map((txs) => txs.find((tx) => tx.id === outgoingTx.id)),
        filter(isNotNil)
      )
    );
    expect(loadedTx.auxiliaryData).toEqual(auxiliaryData);
  });
});
