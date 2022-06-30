/* eslint-disable sonarjs/no-duplicate-string */
import { Cardano } from '@cardano-sdk/core';
import { KeyManagement, ObservableWallet, SingleAddressWallet } from '@cardano-sdk/wallet';
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
import { combineLatest, filter, firstValueFrom, map, of } from 'rxjs';
import { env } from '../environment';

describe('SingleAddressWallet.assets/nft', () => {
  let wallet: ObservableWallet;

  beforeAll(async () => {
    const _keyAgent = await keyAgentById(0, env.KEY_MANAGEMENT_PROVIDER, env.KEY_MANAGEMENT_PARAMS);
    _keyAgent.knownAddresses$ = of([
      {
        accountIndex: 0,
        address: Cardano.Address(
          // eslint-disable-next-line max-len
          'addr_test1qpapna8hhj2hx2q2s9mdp7995a3hgundyvvvj0v0yq68lt8e6dgndgyep9stycsnejcnu8vm7a6dtqqhmf362z7fy5ksg46rum'
        ),
        index: 0,
        networkId: Cardano.NetworkId.testnet,
        rewardAccount: Cardano.RewardAccount('stake_test1uruax5fk5zvsjc9jvgfuevf7rkdlwax4sqta5ca9p0yj2tg4cf29e'),
        type: KeyManagement.AddressType.External
      }
    ]);
    wallet = new SingleAddressWallet(
      {
        name: 'Test Wallet'
      },
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
  });

  afterAll(() => {
    wallet.shutdown();
  });

  it('supports multiple CIP-25 NFT metadata in one tx', async () => {
    const nfts = await firstValueFrom(
      combineLatest([wallet.assets$, wallet.balance.utxo.total$]).pipe(
        filter(([assets, balance]) => assets.size === balance.assets?.size),
        map(([assets]) => [...assets.values()].filter((asset) => !!asset.nftMetadata))
      )
    );
    expect(nfts.find((nft) => nft.nftMetadata!.name === 'One')).toEqual({
      assetId: 'd1ac67dcebc491ce17635d3d9c8775eb739325ce522f6eac733489aa4e4654303031',
      fingerprint: 'asset15wsawsn72dw07m33fqp42suze636mv2k4agxvs',
      history: undefined,
      mintOrBurnCount: 1,
      name: '4e4654303031',
      nftMetadata: {
        description: undefined,
        files: undefined,
        image: ['ipfs://some_hash1'],
        mediaType: undefined,
        name: 'One',
        version: '1.0'
      },
      otherProperties: undefined,
      policyId: 'd1ac67dcebc491ce17635d3d9c8775eb739325ce522f6eac733489aa',
      quantity: 1n,
      tokenMetadata: { desc: undefined, icon: 'ipfs://some_hash1', name: 'One' }
    });
    expect(nfts.find((nft) => nft.nftMetadata!.name === 'Two')).toBeDefined();
  });

  it('parses CIP-25 NFT metadata with files', async () => {
    const nfts = await firstValueFrom(
      combineLatest([wallet.assets$, wallet.balance.utxo.total$]).pipe(
        filter(([assets, balance]) => assets.size === balance.assets?.size),
        map(([assets]) => [...assets.values()].filter((asset) => !!asset.nftMetadata))
      )
    );
    expect(nfts.find((nft) => nft.nftMetadata!.name === 'NFT with files')).toEqual({
      assetId: 'e80c05f27dec74e8c04f27bdf711dff8ae03167dda9b7760b7d92cef4e46542d66696c6573',
      fingerprint: 'asset16w7fcptllh5qfgux8hmp3wymne7xh5y65vxueh',
      history: undefined,
      mintOrBurnCount: 1,
      name: '4e46542d66696c6573',
      nftMetadata: {
        description: ['NFT with different types of files'],
        files: [
          {
            mediaType: 'video/mp4',
            name: 'some name',
            src: ['file://some_video_file']
          },
          {
            mediaType: 'audio/mpeg',
            name: 'some name',
            src: ['file://some_audio_file', 'file://another_audio_file']
          }
        ],
        image: ['ipfs://somehash'],
        mediaType: 'image/png',
        name: 'NFT with files',
        otherProperties: new Map([['id', '1']]),
        version: '1.0'
      },
      otherProperties: undefined,
      policyId: 'e80c05f27dec74e8c04f27bdf711dff8ae03167dda9b7760b7d92cef',
      quantity: 1n,
      tokenMetadata: {
        desc: 'NFT with different types of files',
        description: 'NFT with different types of files',
        files: [
          {
            mediaType: 'video/mp4',
            name: 'some name',
            src: 'file://some_video_file'
          },
          {
            mediaType: 'audio/mpeg',
            name: 'some name',
            src: ['file://some_audio_file', 'file://another_audio_file']
          }
        ],
        icon: 'ipfs://somehash',
        id: '1',
        mediaType: 'image/png',
        name: 'NFT with files'
      }
    });
  });
});
