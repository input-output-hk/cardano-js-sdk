import { Utils, InMemoryKeyManager } from '../..'
import { addressDiscoveryWithinBounds, AddressType, Utxo } from '../../Wallet'
import { generateTestTransaction } from './test_transaction'

/*
  This seed generates the following "chain state"

  Account 1 = mnemonic1:
  - Some UTXOs in the first BIP44 range (first 20 addresses), for external addresses
  - Account 1 can be considered a genesis account, as it moved funds to other accounts without UTXOs
  - Its mnemonic won't be exposed as without txOut, it is useless,

  Account 2 = mnemonic2
  - No change, only receipt, in the first and second BIP44 ranges (first 40 addresses)

  Account 3 = mnemonic3
  - No UTXOs
*/
export function generateSeed () {
  const mnemonic1 = Utils.generateMnemonic()
  const mnemonic2 = Utils.generateMnemonic()
  const mnemonic3 = Utils.generateMnemonic()

  const account1 = InMemoryKeyManager({ password: '', mnemonic: mnemonic1 }).publicAccount()
  const account2 = InMemoryKeyManager({ password: '', mnemonic: mnemonic2 }).publicAccount()

  const account2Addresses = addressDiscoveryWithinBounds({
    account: account2,
    lowerBound: 0,
    upperBound: 39,
    type: AddressType.external
  })

  const tx1 = generateTestTransaction({
    publicAccount: account1,
    testInputs: [
      { type: AddressType.external, value: '100000' },
      { type: AddressType.external, value: '200000' },
      { type: AddressType.external, value: '300000' },
      { type: AddressType.external, value: '200000' },
      { type: AddressType.external, value: '100000' }
    ],
    lowerBoundOfAddresses: 0,
    testOutputs: [
      { address: account2Addresses[0].address, value: '400000' },
      { address: account2Addresses[5].address, value: '200000' },
      { address: account2Addresses[10].address, value: '200000' }
    ]
  })

  const tx2 = generateTestTransaction({
    publicAccount: account1,
    testInputs: [
      { type: AddressType.external, value: '100000' },
      { type: AddressType.external, value: '200000' },
      { type: AddressType.external, value: '300000' },
      { type: AddressType.external, value: '200000' },
      { type: AddressType.external, value: '100000' }
    ],
    lowerBoundOfAddresses: 4,
    testOutputs: [
      { address: account2Addresses[15].address, value: '400000' },
      { address: account2Addresses[20].address, value: '200000' },
      { address: account2Addresses[25].address, value: '200000' }
    ]
  })

  const account1Utxos: Utxo[] = tx1.inputs.concat(tx2.inputs).map(input => {
    return { address: input.value.address, id: tx1.transaction.id().to_hex(), index: 0, value: '1000000' }
  })

  const account2Utxos: Utxo[] = [
    { id: tx1.transaction.id().to_hex(), index: 0, address: account2Addresses[0].address, value: '200000' },
    { id: tx1.transaction.id().to_hex(), index: 1, address: account2Addresses[5].address, value: '200000' },
    { id: tx1.transaction.id().to_hex(), index: 2, address: account2Addresses[10].address, value: '200000' },
    { id: tx2.transaction.id().to_hex(), index: 3, address: account2Addresses[15].address, value: '200000' },
    { id: tx2.transaction.id().to_hex(), index: 4, address: account2Addresses[20].address, value: '200000' },
    { id: tx2.transaction.id().to_hex(), index: 5, address: account2Addresses[25].address, value: '200000' }
  ]

  return {
    accountMnemonics: {
      account1: mnemonic2,
      account2: mnemonic3
    },
    transactions: [
      { inputs: tx1.inputs, outputs: tx1.transaction.toJson().outputs.map((txOut: any) => ({ address: txOut.address, value: String(txOut.value) })) },
      { inputs: tx2.inputs, outputs: tx2.transaction.toJson().outputs.map((txOut: any) => ({ address: txOut.address, value: String(txOut.value) })) }
    ],
    utxos: account1Utxos.concat(account2Utxos)
  }
}

// Uncomment and run this file with `npx ts-node src/test/utils/mock_provider.ts` to regenerate the seed
// console.log(JSON.stringify(generateSeed(), null, 4))

export const seed = {
  'accountMnemonics': {
    'account1': 'dune bike sunny phrase service clip slice taste game limit define symbol',
    'account2': 'brave path obscure silk drum mosquito all coffee next summer nothing winner'
  },
  'transactions': [
    {
      'inputs': [
        {
          'pointer': {
            'id': 'dedd121350a4337e65b7b6188aada7f2c06add547a3fc722a9910d97998c7759',
            'index': 0
          },
          'value': {
            'address': 'Ae2tdPwUPEZGiQQTVEcNicxT9omVNNTVwkgM3A4atejUQaimxa9Y5FPgaKY',
            'value': '100000'
          },
          'addressing': {
            'change': 0,
            'index': 0
          }
        },
        {
          'pointer': {
            'id': '60ef31b7f3033a981182d4c6f08384c74d94e5669360cea680459c27c308088f',
            'index': 1
          },
          'value': {
            'address': 'Ae2tdPwUPEZGfJ2hQvKtJewggrung58P4GWh1K8KgKYgSJ2CB9fHmyArCJX',
            'value': '200000'
          },
          'addressing': {
            'change': 0,
            'index': 1
          }
        },
        {
          'pointer': {
            'id': '91698b97779e76876ea05655ce7f70b75a2bb8f67b75a218a772eadac6bbcb2e',
            'index': 2
          },
          'value': {
            'address': 'Ae2tdPwUPEYzLpMAhWQJ6KQacUWh1D53bCnvJPfXVuab2UMJBPhkAKPCJAb',
            'value': '300000'
          },
          'addressing': {
            'change': 0,
            'index': 2
          }
        },
        {
          'pointer': {
            'id': '88543abc5b47664c734d4b0870bd48bdd880d590d39a6792e8fa0298f4311c50',
            'index': 3
          },
          'value': {
            'address': 'Ae2tdPwUPEZKzpvrs2oZSA3ftFKFLGu3eccKZ5iEpMSwzXzfjpMknKDAFZw',
            'value': '200000'
          },
          'addressing': {
            'change': 0,
            'index': 3
          }
        },
        {
          'pointer': {
            'id': '2de5075d9dccb85fc181709679ed4b52539ac5b67b75c15397a1af80dde0d69a',
            'index': 4
          },
          'value': {
            'address': 'Ae2tdPwUPEZ4Rc8yxB726KP2W15Zvn5FRZR5CZbVoK6yYMYHLnTCt6AeqNQ',
            'value': '100000'
          },
          'addressing': {
            'change': 0,
            'index': 4
          }
        }
      ],
      'outputs': [
        {
          'address': 'Ae2tdPwUPEYxJD58QiQesER14LvUtZKC3CQmnkvgiADAKqpTXPaRMbj4xo2',
          'value': '198036'
        },
        {
          'address': 'Ae2tdPwUPEZ5mjoaDxQeZhqDsD82gdTT8AGmPxFQ6bN7ALXnJXNYoLxYTty',
          'value': '200000'
        },
        {
          'address': 'Ae2tdPwUPEZLLSW7Y33qFVhkm2DhUzKamXuijrmQqBx3nstFBzNFaeJpEFh',
          'value': '200000'
        }
      ]
    },
    {
      'inputs': [
        {
          'pointer': {
            'id': '273afe80b119ab518b01e5bbe936425d4cd84e1fb9056d5eef79d60371213787',
            'index': 0
          },
          'value': {
            'address': 'Ae2tdPwUPEZ4Rc8yxB726KP2W15Zvn5FRZR5CZbVoK6yYMYHLnTCt6AeqNQ',
            'value': '100000'
          },
          'addressing': {
            'change': 0,
            'index': 4
          }
        },
        {
          'pointer': {
            'id': 'f360479df2b54997795cf28be471bf5a16518e895ec637877aa5ded27cb229b3',
            'index': 1
          },
          'value': {
            'address': 'Ae2tdPwUPEZ83naRuph3AxaoPAyGbnLduu7FvgDhd2XjpbpcSSYeTgvuSxW',
            'value': '200000'
          },
          'addressing': {
            'change': 0,
            'index': 5
          }
        },
        {
          'pointer': {
            'id': 'f4ef145e8104828dae1aa6631faefdc08dd962dd21176e9b62a7b9b36e09ab08',
            'index': 2
          },
          'value': {
            'address': 'Ae2tdPwUPEYxM2oCK42hHw4gTo8K5p7BthQQxecEJDxRWxTQQMvxvyUCbbV',
            'value': '300000'
          },
          'addressing': {
            'change': 0,
            'index': 6
          }
        },
        {
          'pointer': {
            'id': '143508ba21cebacc8c99122676de600450a30e8d51c4cd1ab090975092e47672',
            'index': 3
          },
          'value': {
            'address': 'Ae2tdPwUPEZEAJKhiMpNFURjybgAboYbaZRFLXtbGZBg7JaY13mLXWBnd6C',
            'value': '200000'
          },
          'addressing': {
            'change': 0,
            'index': 7
          }
        },
        {
          'pointer': {
            'id': '76cb4ca05a35b37cc84265d52649baf3d6c4910580ece140919babe9426e2a42',
            'index': 4
          },
          'value': {
            'address': 'Ae2tdPwUPEZEbC3pCF3NwnZfhKo1i5PTgwcsZsNor4po6qbfQbrB12FK9q2',
            'value': '100000'
          },
          'addressing': {
            'change': 0,
            'index': 8
          }
        }
      ],
      'outputs': [
        {
          'address': 'Ae2tdPwUPEZC68988DdY4VKUXGHuUadkZiQEc14FJhEDuZoaXzu8gHAiXoL',
          'value': '198036'
        },
        {
          'address': 'Ae2tdPwUPEZ3mXn6kBpoGfBp6ZjWbeHir6LJQtQ95mJ6DGYt4wGwSWpLyCB',
          'value': '200000'
        },
        {
          'address': 'Ae2tdPwUPEZKZcGaQderAkYknURwJ34dzxWq3WDPS1y6K2PXjcmuy94zeo7',
          'value': '200000'
        }
      ]
    }
  ],
  'utxos': [
    {
      'address': 'Ae2tdPwUPEZGiQQTVEcNicxT9omVNNTVwkgM3A4atejUQaimxa9Y5FPgaKY',
      'id': 'c4b435294aed00ed3e5cb3208714b76a79096bf037f8a22cb4bafe48795c20a3',
      'index': 0,
      'value': '1000000'
    },
    {
      'address': 'Ae2tdPwUPEZGfJ2hQvKtJewggrung58P4GWh1K8KgKYgSJ2CB9fHmyArCJX',
      'id': 'c4b435294aed00ed3e5cb3208714b76a79096bf037f8a22cb4bafe48795c20a3',
      'index': 0,
      'value': '1000000'
    },
    {
      'address': 'Ae2tdPwUPEYzLpMAhWQJ6KQacUWh1D53bCnvJPfXVuab2UMJBPhkAKPCJAb',
      'id': 'c4b435294aed00ed3e5cb3208714b76a79096bf037f8a22cb4bafe48795c20a3',
      'index': 0,
      'value': '1000000'
    },
    {
      'address': 'Ae2tdPwUPEZKzpvrs2oZSA3ftFKFLGu3eccKZ5iEpMSwzXzfjpMknKDAFZw',
      'id': 'c4b435294aed00ed3e5cb3208714b76a79096bf037f8a22cb4bafe48795c20a3',
      'index': 0,
      'value': '1000000'
    },
    {
      'address': 'Ae2tdPwUPEZ4Rc8yxB726KP2W15Zvn5FRZR5CZbVoK6yYMYHLnTCt6AeqNQ',
      'id': 'c4b435294aed00ed3e5cb3208714b76a79096bf037f8a22cb4bafe48795c20a3',
      'index': 0,
      'value': '1000000'
    },
    {
      'address': 'Ae2tdPwUPEZ4Rc8yxB726KP2W15Zvn5FRZR5CZbVoK6yYMYHLnTCt6AeqNQ',
      'id': 'c4b435294aed00ed3e5cb3208714b76a79096bf037f8a22cb4bafe48795c20a3',
      'index': 0,
      'value': '1000000'
    },
    {
      'address': 'Ae2tdPwUPEZ83naRuph3AxaoPAyGbnLduu7FvgDhd2XjpbpcSSYeTgvuSxW',
      'id': 'c4b435294aed00ed3e5cb3208714b76a79096bf037f8a22cb4bafe48795c20a3',
      'index': 0,
      'value': '1000000'
    },
    {
      'address': 'Ae2tdPwUPEYxM2oCK42hHw4gTo8K5p7BthQQxecEJDxRWxTQQMvxvyUCbbV',
      'id': 'c4b435294aed00ed3e5cb3208714b76a79096bf037f8a22cb4bafe48795c20a3',
      'index': 0,
      'value': '1000000'
    },
    {
      'address': 'Ae2tdPwUPEZEAJKhiMpNFURjybgAboYbaZRFLXtbGZBg7JaY13mLXWBnd6C',
      'id': 'c4b435294aed00ed3e5cb3208714b76a79096bf037f8a22cb4bafe48795c20a3',
      'index': 0,
      'value': '1000000'
    },
    {
      'address': 'Ae2tdPwUPEZEbC3pCF3NwnZfhKo1i5PTgwcsZsNor4po6qbfQbrB12FK9q2',
      'id': 'c4b435294aed00ed3e5cb3208714b76a79096bf037f8a22cb4bafe48795c20a3',
      'index': 0,
      'value': '1000000'
    },
    {
      'id': 'c4b435294aed00ed3e5cb3208714b76a79096bf037f8a22cb4bafe48795c20a3',
      'index': 0,
      'address': 'Ae2tdPwUPEYxJD58QiQesER14LvUtZKC3CQmnkvgiADAKqpTXPaRMbj4xo2',
      'value': '200000'
    },
    {
      'id': 'c4b435294aed00ed3e5cb3208714b76a79096bf037f8a22cb4bafe48795c20a3',
      'index': 1,
      'address': 'Ae2tdPwUPEZ5mjoaDxQeZhqDsD82gdTT8AGmPxFQ6bN7ALXnJXNYoLxYTty',
      'value': '200000'
    },
    {
      'id': 'c4b435294aed00ed3e5cb3208714b76a79096bf037f8a22cb4bafe48795c20a3',
      'index': 2,
      'address': 'Ae2tdPwUPEZLLSW7Y33qFVhkm2DhUzKamXuijrmQqBx3nstFBzNFaeJpEFh',
      'value': '200000'
    },
    {
      'id': 'b8396414af5ce98eb230e5d1abdd0a44b4215c38219134d97866f1d6787bc8de',
      'index': 3,
      'address': 'Ae2tdPwUPEZC68988DdY4VKUXGHuUadkZiQEc14FJhEDuZoaXzu8gHAiXoL',
      'value': '200000'
    },
    {
      'id': 'b8396414af5ce98eb230e5d1abdd0a44b4215c38219134d97866f1d6787bc8de',
      'index': 4,
      'address': 'Ae2tdPwUPEZ3mXn6kBpoGfBp6ZjWbeHir6LJQtQ95mJ6DGYt4wGwSWpLyCB',
      'value': '200000'
    },
    {
      'id': 'b8396414af5ce98eb230e5d1abdd0a44b4215c38219134d97866f1d6787bc8de',
      'index': 5,
      'address': 'Ae2tdPwUPEZKZcGaQderAkYknURwJ34dzxWq3WDPS1y6K2PXjcmuy94zeo7',
      'value': '200000'
    }
  ]
}
