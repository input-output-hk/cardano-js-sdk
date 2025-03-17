import * as Crypto from '@cardano-sdk/crypto';
import { BlockfrostClient, BlockfrostSharedWalletProvider } from '../../src';
import { logger } from '@cardano-sdk/util-dev';

const mockedResponses = [
  {
    json_metadata: {
      description: 'd mb-s+lnx+tmt02',
      name: 'mb-s+lnx+tmt02',
      participants: {},
      types: ['payment', 'stake']
    },
    tx_hash: 'c59b418d946b08554d8be35994420d0e9ba5b01a3cafb9979496f55b2fd9fda6'
  },
  {
    json_metadata: {
      description: 'This is really a test wallet, I think with mb-s',
      name: 'Another test ms wallet',
      participants: {},
      types: ['payment', 'stake']
    },
    tx_hash: '6c1a7652b189aaa3efe39e66c0ef8c894c6f6f8e37fceb58dc41064ac628a569'
  },
  {
    json_metadata: {
      description: 'A Multi-Sig test wallet',
      name: 'MS Test',
      participants: {
        '35769ace6c241e0afe467b0a3577af9adea271fc971ba7770ac88712': {
          name: 'Wallet 1'
        },
        '962746268ee907e18c895c9943c6684b01fa7a4956b0fe0fa76cfa6f': {
          name: 'Wallet 2'
        },
        c87b02ef2bed963db3892031ce9387b7d65a83008bad072ddb7409d6: {
          name: 'Wallet 1'
        },
        ebf94d78fb1b185f5b0136260d9192e1270c8303bba5155e773de3fb: {
          name: 'Wallet 2'
        }
      },
      types: ['payment', 'stake']
    },
    tx_hash: '37bbd91b177e0716d5943fb3de8649c9dcabc844553e7656744ffca1c11efddc'
  },
  {
    json_metadata: {
      description: 'A simple Multi-Sig wallet with 3/3 signatures needed.',
      name: 'MS Test 3/3',
      participants: {
        '7429c675051bb444a78d0850be2c45a48f8ed3d4ecdb6f059ed19873': {
          name: 'Wallet 3'
        },
        '35769ace6c241e0afe467b0a3577af9adea271fc971ba7770ac88712': {
          name: 'Wallet 1'
        },
        '15254521db8f70ac44aa585475361727e918465425d9fb53f0d754e3': {
          name: 'Wallet 3'
        },
        '962746268ee907e18c895c9943c6684b01fa7a4956b0fe0fa76cfa6f': {
          name: 'Wallet 2'
        },
        c87b02ef2bed963db3892031ce9387b7d65a83008bad072ddb7409d6: {
          name: 'Wallet 1'
        },
        ebf94d78fb1b185f5b0136260d9192e1270c8303bba5155e773de3fb: {
          name: 'Wallet 2'
        }
      },
      types: ['payment', 'stake']
    },
    tx_hash: '42c2eed5fabb3500b7b66e84c73d78633df567803f4a8afd38d485f71a7fcf84'
  },
  {
    json_metadata: {
      description: 'A simple Multi-Sig wallet with 3/3 signatures needed',
      name: 'MS 3/3',
      participants: {},
      types: ['payment', 'stake']
    },
    tx_hash: 'e51c93492c04fc6b8d475c5bbbac483961d1d2ebf592d019619cd199f17ed6f5'
  },
  {
    json_metadata: {
      description: 'dsfdsfdsf',
      name: 'MS Test',
      participants: {
        '35769ace6c241e0afe467b0a3577af9adea271fc971ba7770ac88712': {
          name: 'sdfdsf'
        },
        '962746268ee907e18c895c9943c6684b01fa7a4956b0fe0fa76cfa6f': {
          name: 'sdfsdf'
        },
        c87b02ef2bed963db3892031ce9387b7d65a83008bad072ddb7409d6: {
          name: 'sdfdsf'
        },
        ebf94d78fb1b185f5b0136260d9192e1270c8303bba5155e773de3fb: {
          name: 'sdfsdf'
        }
      },
      types: ['payment', 'stake']
    },
    tx_hash: '0c746630f885213618db4af244a8d257e8c03a4041a0fcbece10abe0a6526f5d'
  },
  {
    json_metadata: {
      description: 'L + T + K',
      name: 'HW MS Test',
      participants: {
        '7fb20197bb7e2c3b44539fb9784e70db308640c86a1ef45db711cd28': {
          name: 'Keystone'
        },
        '9d237cfa3da50b71859ac7045e4d296252c85f7d72d4c5c889a8c22e': {
          name: 'Keystone'
        },
        a4fb72bcb24a91cb1add70d3158704a4cf14a7909fbbe4edac39efb1: {
          name: 'Ledger'
        },
        ad773cd4bdb0f775c53d34c48e70bd46f1856e21c8103f8d292fcc7a: {
          name: 'Ledger'
        },
        afb321dabccdf5ea26ce4ac9c0cd5aaae6cb47a61e12cd8c8b3f41a0: {
          name: 'Trezor'
        },
        cc9adac917b5a7e191982f1bb979507349e5ae59df8d015a2842f4bd: {
          name: 'Trezor'
        }
      },
      types: ['payment', 'stake']
    },
    tx_hash: 'a160d298a6e49e6b39b33cde296baf171b2ad31c4520cbbc2086d99d3d64bc91'
  }
];

const nativeScriptResponse = {
  cbor: '84a70081825820765bf5499431711696c37ce98cf5b40b94e592ae497c7e1acadf44e97db540de0001818258390029fb060929ae397acd22105b8d512cafbe14beb372b7940734c8e0a049ffdf3c964ec375208a6b46cc6075ad36beb80bcce21663021d78da1a004caf43021a0002d611031a04850a6905a1581de049ffdf3c964ec375208a6b46cc6075ad36beb80bcce21663021d78da1a0005ee750758200e0397a8285695c5f5a581b4cfca2896ecdcab79e1723b36ba0b3904cc8ad04f0800a100828258202ebc0ea3cd6546b9e1c82c8f14a9d59e1f21a8483453e2bce5e1aa9fb5cd37bb5840cefb6d1f99e7ef1d72f2a67779764832949d10b1f62e08602b8bba50da703fe36c91f192e2fd60d709fc027b964979ac6197da708091b591c75e5e21b770b500825820520b5cd3b967df70972451885c54de299738ead98113080130848b39cea2854e5840f092b42091f16082a34789c45471ab1f60ee175fe752ce29f7c42edea6c04151c8c47bf684f53bdefd765de0f2dba9fc1f8e914f29b97c8fae6cc7727465c006f582a119073ea46b6465736372697074696f6e7064206d622d732b6c6e782b746d743032646e616d656e6d622d732b6c6e782b746d7430326c7061727469636970616e7473a065747970657382677061796d656e74657374616b65828202838200581ce3ad78d912029930ec11394610bdd4dd12bc64effb61e2258ab059338200581c8a7c43db68954f99e8afa35130ac65576776eb6500d2c616cb6d1d408200581c83dec074a40f7d6b7cfd902243ec4b902d17960a69a66acd8bd35ce08202838200581c96f941682e4b1873dc45ef6930378915ae637c5be5d6c1fd1f9491e68200581c734a5efd35afe4de6a9bf2ca4c4bfe2a22b370a0acbddd9c3dfbfa6b8200581cd8747c9c7d51385172474bfea67ecdb27eaf9bb5be216118b407775b'
};

describe('BlockfrostSharedWallet', () => {
  let request: jest.Mock;
  let provider: BlockfrostSharedWalletProvider;

  beforeEach(async () => {
    request = jest.fn();
    const client = { request } as unknown as BlockfrostClient;
    provider = new BlockfrostSharedWalletProvider(client, logger);
  });

  describe('discoverWallets', () => {
    it('should return an empty array if no wallets are found', () => {
      request.mockResolvedValueOnce(mockedResponses);
      return expect(
        provider.discoverWallets(Crypto.Ed25519KeyHashHex('0a0ba36b07e61f4b566a99521be1f8b2fdb1ce47246894807b63712b'))
      ).resolves.toEqual([]);
    });

    it('should return all wallets for a given public key', async () => {
      request.mockResolvedValueOnce(mockedResponses);

      request
        .mockResolvedValueOnce(nativeScriptResponse)
        .mockResolvedValueOnce(nativeScriptResponse)
        .mockResolvedValueOnce(nativeScriptResponse);

      const pubKey = '962746268ee907e18c895c9943c6684b01fa7a4956b0fe0fa76cfa6f';
      const wallets = await provider.discoverWallets(Crypto.Ed25519KeyHashHex(pubKey));

      expect(wallets.length).toEqual(3);
      for (const wallet of wallets) {
        expect(wallet.metadata.participants).toHaveProperty(pubKey);
        expect(wallet.nativeScripts).toHaveLength(2);
      }
    });
  });
});
