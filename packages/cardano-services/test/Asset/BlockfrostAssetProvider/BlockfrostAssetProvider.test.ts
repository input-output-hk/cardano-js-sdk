/* eslint-disable sonarjs/no-duplicate-string */
/* eslint-disable @typescript-eslint/no-explicit-any */
/* eslint-disable max-len */

import { Asset, Cardano } from '@cardano-sdk/core';
import { BlockFrostAPI, Responses } from '@blockfrost/blockfrost-js';

import { blockfrostAssetProvider } from '../../../src';

jest.mock('@blockfrost/blockfrost-js');

describe('blockfrostAssetProvider', () => {
  const apiKey = 'someapikey';

  describe('getAsset', () => {
    const mockedAssetResponse = {
      asset: 'b0d07d45fe9514f80213f4020e5a61241458be626841cde717cb38a76e7574636f696e',
      asset_name: '6e7574636f696e',
      fingerprint: 'asset1pkpwyknlvul7az0xx8czhl60pyel45rpje4z8w',
      initial_mint_tx_hash: '6804edf9712d2b619edb6ac86861fe93a730693183a262b165fcc1ba1bc99cad',
      metadata: {
        decimals: 6,
        description: 'The Nut Coin',
        logo: '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',
        name: 'nutcoin',
        ticker: 'nutc',
        url: 'https://www.stakenuts.com/'
      },
      mint_or_burn_count: 1,
      onchain_metadata: {
        image: 'ipfs://ipfs/QmfKyJ4tuvHowwKQCbCHj4L5T3fSj8cjs7Aau8V7BWv226',
        name: 'My NFT token'
      },
      policy_id: 'b0d07d45fe9514f80213f4020e5a61241458be626841cde717cb38a7',
      quantity: '12000'
    } as Responses['asset'];

    test('asset with only 1 mint', async () => {
      BlockFrostAPI.prototype.assetsById = jest.fn().mockResolvedValue(mockedAssetResponse);
      BlockFrostAPI.prototype.assetsHistory = jest.fn();
      BlockFrostAPI.prototype.txsMetadata = jest.fn().mockResolvedValue([]);

      const blockfrost = new BlockFrostAPI({ network: 'preprod', projectId: apiKey });
      const client = blockfrostAssetProvider(blockfrost);
      const response = await client.getAsset({
        assetId: Cardano.AssetId('b0d07d45fe9514f80213f4020e5a61241458be626841cde717cb38a76e7574636f696e'),
        extraData: { nftMetadata: true, tokenMetadata: true }
      });

      expect(response).toMatchObject<Asset.AssetInfo>({
        assetId: Cardano.AssetId('b0d07d45fe9514f80213f4020e5a61241458be626841cde717cb38a76e7574636f696e'),
        fingerprint: Cardano.AssetFingerprint('asset1pkpwyknlvul7az0xx8czhl60pyel45rpje4z8w'),
        name: Cardano.AssetName('6e7574636f696e'),
        nftMetadata: null,
        policyId: Cardano.PolicyId('b0d07d45fe9514f80213f4020e5a61241458be626841cde717cb38a7'),
        quantity: 12_000n,
        supply: 12_000n,
        tokenMetadata: {
          assetId: Cardano.AssetId('b0d07d45fe9514f80213f4020e5a61241458be626841cde717cb38a76e7574636f696e'),
          decimals: 6,
          desc: 'The Nut Coin',
          icon: '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',
          name: 'nutcoin',
          ticker: 'nutc',
          url: 'https://www.stakenuts.com/'
        }
      });
      expect(BlockFrostAPI.prototype.assetsHistory).not.toHaveBeenCalled();
    });

    test('has more than 1 mint or burn', async () => {
      BlockFrostAPI.prototype.assetsById = jest.fn().mockResolvedValue({
        ...mockedAssetResponse,
        mint_or_burn_count: 2
      });
      BlockFrostAPI.prototype.assetsHistory = jest.fn().mockResolvedValue([
        {
          action: 'minted',
          amount: '13000',
          tx_hash: '4123d70f66414cc921f6ffc29a899aafc7137a99a0fd453d6b200863ef5702d6'
        },
        {
          action: 'burned',
          amount: '1000',
          tx_hash: '01d7366549986d83edeea262e97b68eca3430d3bb052ed1c37d2202fd5458872'
        }
      ] as Responses['asset_history']);
      BlockFrostAPI.prototype.txsMetadata = jest.fn().mockResolvedValue([]);

      const blockfrost = new BlockFrostAPI({ network: 'preprod', projectId: apiKey });
      const client = blockfrostAssetProvider(blockfrost);
      const response = await client.getAsset({
        assetId: Cardano.AssetId('b0d07d45fe9514f80213f4020e5a61241458be626841cde717cb38a76e7574636f696e'),
        extraData: { nftMetadata: true, tokenMetadata: true }
      });

      expect(response).toMatchObject<Asset.AssetInfo>({
        assetId: Cardano.AssetId('b0d07d45fe9514f80213f4020e5a61241458be626841cde717cb38a76e7574636f696e'),
        fingerprint: Cardano.AssetFingerprint('asset1pkpwyknlvul7az0xx8czhl60pyel45rpje4z8w'),
        name: Cardano.AssetName('6e7574636f696e'),
        nftMetadata: null,
        policyId: Cardano.PolicyId('b0d07d45fe9514f80213f4020e5a61241458be626841cde717cb38a7'),
        quantity: 12_000n,
        supply: 12_000n,
        tokenMetadata: {
          assetId: Cardano.AssetId('b0d07d45fe9514f80213f4020e5a61241458be626841cde717cb38a76e7574636f696e'),
          decimals: 6,
          desc: 'The Nut Coin',
          icon: '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',
          name: 'nutcoin',
          ticker: 'nutc',
          url: 'https://www.stakenuts.com/'
        }
      });
    });

    test('has nft metadata', async () => {
      BlockFrostAPI.prototype.assetsById = jest.fn().mockResolvedValue(mockedAssetResponse);
      BlockFrostAPI.prototype.txsMetadata = jest.fn().mockResolvedValue([
        { json_metadata: { other: 'no nft' }, label: '1' },
        {
          json_metadata: {
            b0d07d45fe9514f80213f4020e5a61241458be626841cde717cb38a7: {
              '6e7574636f696e': {
                image: ['ipfs://image'],
                name: 'test nft',
                version: '1.0'
              }
            }
          },
          label: '721'
        }
      ]);

      const blockfrost = new BlockFrostAPI({ network: 'preprod', projectId: apiKey });
      const client = blockfrostAssetProvider(blockfrost);
      const response = await client.getAsset({
        assetId: Cardano.AssetId('b0d07d45fe9514f80213f4020e5a61241458be626841cde717cb38a76e7574636f696e'),
        extraData: { nftMetadata: true, tokenMetadata: true }
      });
      expect(response).toMatchObject<Asset.AssetInfo>({
        assetId: Cardano.AssetId('b0d07d45fe9514f80213f4020e5a61241458be626841cde717cb38a76e7574636f696e'),
        fingerprint: Cardano.AssetFingerprint('asset1pkpwyknlvul7az0xx8czhl60pyel45rpje4z8w'),
        name: Cardano.AssetName('6e7574636f696e'),
        nftMetadata: {
          image: Asset.Uri('ipfs://image'),
          name: 'test nft',
          version: '1.0'
        },
        policyId: Cardano.PolicyId('b0d07d45fe9514f80213f4020e5a61241458be626841cde717cb38a7'),
        quantity: 12_000n,
        supply: 12_000n,
        tokenMetadata: {
          assetId: Cardano.AssetId('b0d07d45fe9514f80213f4020e5a61241458be626841cde717cb38a76e7574636f696e'),
          decimals: 6,
          desc: 'The Nut Coin',
          icon: 'iVBORw0KGgoAAAANSUhEUgAAADAAAAAoCAYAAAC4h3lxAAAABGdBTUEAALGPC/xhBQAAACBjSFJNAAB6JgAAgIQAAPoAAACA6AAAdTAAAOpgAAA6mAAAF3CculE8AAAABmJLR0QA/wD/AP+gvaeTAAAAB3RJTUUH5QITCDUPjqwFHwAAB9xJREFUWMPVWXtsU9cZ/8499/r6dZ3E9rUdO7ZDEgglFWO8KaOsJW0pCLRKrN1AqqYVkqoqrYo0ja7bpElru1WairStFKY9WzaE1E1tx+jokKqwtqFNyhKahEJJyJNgJ37E9r1+3HvO/sFR4vhx7SBtfH/F3/l93/f7ne/4PBxEKYU72dj/ZfH772v1TU+HtqbTaX8wOO01GPQpRVH7JEm+vGHDuq6z7/8jUSoHKtaBKkEUFUXdajDy1hUrmrs6zn/wWS7m7pZVjMUirKGUTnzc+e9xLcTrPPVfZzDz06Sc2lyQGEIyAPzT7Xa+dvE/3e+XLaCxoflHsVj8MAAYs74aa/WHoenwvpkZKeFy2Z5NJlOPUkqXZccFwSSrKjlyffjLH+TL6XTUGTGL/6hklD3ldIrj2M5MRmkLBMcvaRLQ1Nj88sxM/HCBfMP+eu/OYGDqe6l0WmpoqJ/88upgrU7HrQNA/cFg6MlkKiLlBtVUO40cx54BgHvLIT/HJLvdeqh/4NKxogKWN7fsCoUi7xTLxLJ4vLq6ak//wKVOrdXtttrTDMPsqJA8AAAwDErdu3VL3alTf5ma9eWCpoKhn5dKpCiqJxicPucQPVu0FHaInn35yHMcKwPAa4SQ3QCwFgDWUko3qSr5vqqSgTypuEg4Mo/zvA74/Y0rZSnZU8akSHV17k2fXfy0txjI5224kEym1s/1EUI7LBbztweHrkzkizn49LP6U6feepFSeggAQK/n04SQZ8bGrxdeQjZrbRvGzLH5hcibRqOhPplMfS1fIY5jz4xPDBdcGggho2h3z9sOLRazdG3wqp9SMgUlzGZ17SSEPsRx7J8CwfGu3PF57WhqqjfN/VxVJUxKUrIdITAXKpDJKFscosdfaFy0u+/K9aXTmXe0kAcAmA5Nng5Hbj6Tj/wCAYFAcN7uEY3GXGazMSHLqVVFapgBoMPna9yqhRAAgCTJMa3YUjZPgNFkSlWYx5eUkx+0tKx83V3rF+cVYJjruWCe133DIXqMmrNrFSDabRcWkywYmG5XFOW6aHcfb9324CoAgMmbo9MIoXkneCajiAihV/c/8eSiBSw4BxyiZxQA6m7H7FBKT2CMn2MY5jFFUX6ZO+5w2j8aHZ7YH40FByrJD5DnHGAY5uTtIA8AgBDaR4F2Yxb3WizCgmtA4ObUPSazodduqz3Suu0hf0U1cjvgdNSJ1dWWveFwdDUAtAiC2Uopdcdi8c9Zlh3GmDGl05mtAKAvo47EcdwThJCjqqpWFxALlNITomg73tff21GRAJez7iVK4WGGYfoJIQduBsbm7UrLm1ueCoUiv65kpiilw1ZbzcFoZOYoIcRTAn6eYZgXJm+Oni+Vd3YJbdyweSch9HlK6SpVVfcyDDq7Yf3m2XPBIXraKyV/a4b9UkLawbLsZgB4rwR8CyGkw13r+5fX27BckwBAEJ47oKpk8+DgUIdod7fV1vqOAMDrlZLPmqKoB+rrvXIgOP6w0WjYy3Ls5RL4bUk52bVm9fqnCk7M3CXU2ND8+MxM7BcIIftiyRYyntcdHh0bmr0wfmXl6p2SJB2KRmP3l4j7zejYUFtRAQAAgslm1Bv4nyGEDpYiIwjmjw0G/RjP866JiclNqqqWfKLq9fyZkdHBBXcnl9O71GDgD8bj0ncRQqZ8sRgzL9yYHH2pqICsOUTPLgA4CXNeZFmzWIS/YhYfjUZmvqPjuceSckrz25pS2h2cmlhbaBwhzr6kfsnL8Xhif55YYFl23Y3Jkdl7EVMoUSA4/q6qqNsBIPd11e52u45FwtG3CSH7yiEPAGC1Vt9dXGBmanDoygFLlbAjtzZCCMyC6VeaOpA1l9N7l1kwtauKaozHE28YTQaQpeR7+TqjxXheR0fHhhgt2CX1S3clEtKC16HL5djYe+niBU0CcmYA2W21/Qih5ZqDcoxlMZ24MaJJAABA87IVJ8Lh6N65Pr1B/+LIyLUfAhRZQvnM6ah7ZDHkAQB0vK6/HHxNTc2ruT5Zkldn/y5LACFk+2LIAwAwCGl6yGSt88KHXbmrBCHkqEgAz+vWLFZALJb4qNwYhFDhCSknkSwnQ4sVgDFeWg7+gQe2r1tAmkGTFQlACHWVg89nhJA9ot3dphV/eeCLp/Pw6K5IQP0S39uLFXCLwDG7zf1cKZxD9LSlUunHc/12u/2t2Vzl/rzu8zb8PZlM7bwdQgDgPK/nX2nddt+53//ht3LW2dS0fF0iLj2vquojuQFmwXRucPBKa8UCmpe1iOFwpAsAfLdJBFBKwVIlXJ2JxqKCxbwyHkvoCkAlv9/71U+7Oq+UJWDZ0hViJBL1cRynbNq0sSeeiPl6ei4NqIqq6TSmlB7X6bjuTEY5pgWfzwxGPZhMpt39/b3vzvWXFGCzulZjjM/DrauDwcAr8bjcgzGjZUuVBMH8k2uDX7wCAFDr8n2LEPI7SqmhTP6SzVbz6MDlz0/nDpT8EmOM22HOvUeWU2wp8iyLgRL6hk7Hrc2SBwC4MTlykmXZRozxn00mbVcphNA5jJmV+chr6oDd5l6jN/A/TqfSuwEAGITGMIsvGo3GTwTB3Dc2NjGSxdZYq4VIOOoNBANnKE0XPXE3brjHOTQ08k2MmVZOxzVJCbkFIQSCYEphzPaFQuGzTpfjb319PZ8UFXin/5OvrHPg/9HueAH/BSUqOuNZm4fyAAAAJXRFWHRkYXRlOmNyZWF0ZQAyMDIxLTAyLTE5VDA4OjUyOjI1KzAwOjAwCmFGlgAAACV0RVh0ZGF0ZTptb2RpZnkAMjAyMS0wMi0xOVQwODo1MjoyMyswMDowMBjsyxAAAAAASUVORK5CYII=',
          name: 'nutcoin',
          ticker: 'nutc',
          url: 'https://www.stakenuts.com/'
        }
      });
    });

    test('no extra data', async () => {
      BlockFrostAPI.prototype.assetsById = jest.fn().mockResolvedValue(mockedAssetResponse);
      BlockFrostAPI.prototype.assetsHistory = jest.fn();
      BlockFrostAPI.prototype.txsMetadata = jest.fn();

      const blockfrost = new BlockFrostAPI({ network: 'preprod', projectId: apiKey });
      const client = blockfrostAssetProvider(blockfrost);
      const response = await client.getAsset({
        assetId: Cardano.AssetId('b0d07d45fe9514f80213f4020e5a61241458be626841cde717cb38a76e7574636f696e'),
        extraData: { nftMetadata: false, tokenMetadata: false }
      });

      expect(response).toMatchObject<Asset.AssetInfo>({
        assetId: Cardano.AssetId('b0d07d45fe9514f80213f4020e5a61241458be626841cde717cb38a76e7574636f696e'),
        fingerprint: Cardano.AssetFingerprint('asset1pkpwyknlvul7az0xx8czhl60pyel45rpje4z8w'),
        name: Cardano.AssetName('6e7574636f696e'),
        nftMetadata: undefined,
        policyId: Cardano.PolicyId('b0d07d45fe9514f80213f4020e5a61241458be626841cde717cb38a7'),
        quantity: 12_000n,
        supply: 12_000n,
        tokenMetadata: undefined
      });
      expect(BlockFrostAPI.prototype.assetsHistory).not.toHaveBeenCalled();
      expect(BlockFrostAPI.prototype.txsMetadata).not.toHaveBeenCalled();
    });

    test('description and image as array', async () => {
      BlockFrostAPI.prototype.assetsById = jest.fn().mockResolvedValue({
        asset: '8153f8be9f05b2f32b481bbf7af877f592160b39e87f5f55c8ab035f4e46543031',
        asset_name: '4e46543031',
        fingerprint: 'asset1h2z87pq2tr4ksxl5nkzd2ltrrtd6vvmf5nnn46',
        initial_mint_tx_hash: 'cb2cf241d03f0f6c523a2064b51de783db590f2871da24ce89698db2bef5fb39',
        metadata: null,
        mint_or_burn_count: 1,
        onchain_metadata: {
          description: ['description 1', 'description 2'],
          id: '1',
          image: ['ipfs://QmRhTTbUrPYEw3mJGGhQqQST9k86v1DPBiTTWJGKDJsVFw'],
          name: 'Cardano foundation NFT guide token'
        },
        policy_id: '8153f8be9f05b2f32b481bbf7af877f592160b39e87f5f55c8ab035f',
        quantity: '1'
      });
      BlockFrostAPI.prototype.txsMetadata = jest.fn().mockResolvedValue([
        { json_metadata: { other: 'no nft' }, label: '1' },
        {
          json_metadata: {
            '8153f8be9f05b2f32b481bbf7af877f592160b39e87f5f55c8ab035f': {
              '4e46543031': {
                image: ['ipfs://QmRhTTbUrPYEw3mJGGhQqQST9k86v1DPBiTTWJGKDJsVFw'],
                name: 'test nft',
                version: '1.0'
              }
            }
          },
          label: '721'
        }
      ]);

      const blockfrost = new BlockFrostAPI({ network: 'preprod', projectId: apiKey });
      const client = blockfrostAssetProvider(blockfrost);
      const response = await client.getAsset({
        assetId: Cardano.AssetId('8153f8be9f05b2f32b481bbf7af877f592160b39e87f5f55c8ab035f4e46543031'),
        extraData: { nftMetadata: true, tokenMetadata: true }
      });
      expect(response).toMatchObject<Asset.AssetInfo>({
        assetId: Cardano.AssetId('8153f8be9f05b2f32b481bbf7af877f592160b39e87f5f55c8ab035f4e46543031'),
        fingerprint: Cardano.AssetFingerprint('asset1h2z87pq2tr4ksxl5nkzd2ltrrtd6vvmf5nnn46'),
        name: Cardano.AssetName('4e46543031'),
        nftMetadata: {
          image: Asset.Uri('ipfs://QmRhTTbUrPYEw3mJGGhQqQST9k86v1DPBiTTWJGKDJsVFw'),
          name: 'test nft',
          version: '1.0'
        },
        policyId: Cardano.PolicyId('8153f8be9f05b2f32b481bbf7af877f592160b39e87f5f55c8ab035f'),
        quantity: 1n,
        supply: 1n,
        tokenMetadata: null
      });
    });
  });
});
