import { AddressType, Utxo } from '../../Wallet'
import { generateTestTransaction } from './test_transaction'
import { addressDiscoveryWithinBounds, generateMnemonic } from '../../Utils'
import { InMemoryKeyManager, RustCardano } from '../../lib'
import { ChainSettings } from '../../Cardano'

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
export async function generateSeed () {
  const mnemonic1 = generateMnemonic()
  const mnemonic2 = generateMnemonic()
  const mnemonic3 = generateMnemonic()

  const account1 = await InMemoryKeyManager(RustCardano, { password: '', mnemonic: mnemonic1 }).publicParentKey()
  const account2 = await InMemoryKeyManager(RustCardano, { password: '', mnemonic: mnemonic2 }).publicParentKey()

  const account2Addresses = addressDiscoveryWithinBounds(RustCardano, {
    account: account2,
    lowerBound: 0,
    upperBound: 39,
    type: AddressType.external
  }, ChainSettings.mainnet)

  const tx1 = generateTestTransaction({
    account: account1,
    testInputs: [
      { type: AddressType.external, value: '1000000' },
      { type: AddressType.external, value: '2000000' },
      { type: AddressType.external, value: '3000000' },
      { type: AddressType.external, value: '2000000' },
      { type: AddressType.external, value: '1000000' }
    ],
    lowerBoundOfAddresses: 0,
    testOutputs: [
      { address: account2Addresses[0].address, value: '400000' },
      { address: account2Addresses[5].address, value: '200000' },
      { address: account2Addresses[10].address, value: '200000' }
    ]
  })

  const tx2 = generateTestTransaction({
    account: account1,
    testInputs: [
      { type: AddressType.external, value: '1000000' },
      { type: AddressType.external, value: '2000000' },
      { type: AddressType.external, value: '3000000' },
      { type: AddressType.external, value: '2000000' },
      { type: AddressType.external, value: '1000000' }
    ],
    lowerBoundOfAddresses: 4,
    testOutputs: [
      { address: account2Addresses[15].address, value: '400000' },
      { address: account2Addresses[20].address, value: '200000' },
      { address: account2Addresses[25].address, value: '200000' }
    ]
  })

  const account1Utxos: Utxo[] = tx1.inputs.concat(tx2.inputs).map(input => {
    return { address: input.value.address, id: tx1.transaction.id(), index: 0, value: '10000000' }
  })

  const account2Utxos: Utxo[] = [
    { id: tx1.transaction.id(), index: 0, address: account2Addresses[0].address, value: '200000' },
    { id: tx1.transaction.id(), index: 1, address: account2Addresses[5].address, value: '200000' },
    { id: tx1.transaction.id(), index: 2, address: account2Addresses[10].address, value: '200000' },
    { id: tx2.transaction.id(), index: 3, address: account2Addresses[15].address, value: '200000' },
    { id: tx2.transaction.id(), index: 4, address: account2Addresses[20].address, value: '200000' },
    { id: tx2.transaction.id(), index: 5, address: account2Addresses[25].address, value: '200000' }
  ]

  return {
    accountMnemonics: {
      account1: mnemonic2,
      account2: mnemonic3
    },
    transactions: [
      { id: tx1.transaction.id(), inputs: tx1.inputs, outputs: tx1.transaction.toJson().outputs.map((txOut: any) => ({ address: txOut.address, value: String(txOut.value) })) },
      { id: tx2.transaction.id(), inputs: tx2.inputs, outputs: tx2.transaction.toJson().outputs.map((txOut: any) => ({ address: txOut.address, value: String(txOut.value) })) }
    ],
    utxos: account1Utxos.concat(account2Utxos)
  }
}

// Uncomment and run this file with `npx ts-node src/test/utils/seed.ts` to regenerate the seed
// generateSeed().then(r => {
//   console.log(JSON.stringify(r, null, 4))
// })

export const seed = {
  'accountMnemonics': {
    'account1': 'tattoo jar maid bus found common else seminar gym choose flip habit',
    'account2': 'topple easy myth stay glad prison friend display feature antenna marble luxury'
  },
  'transactions': [
    {
      'id': 'a3f78a5855a6f0ab16b98f3c060530d844038b49c95bd259ded57d148397a2f0',
      'inputs': [
        {
          'pointer': {
            'id': '54dc5ff4cd5606ad2914cd0f121951e584d48047591514a4384835823d9eb514',
            'index': 0
          },
          'value': {
            'address': 'Ae2tdPwUPEZLVDTRwkaiXxym6fGpzarZB6JriCYA2jnqP7QvqTLPcYhveai',
            'value': '1000000'
          },
          'addressing': {
            'change': 0,
            'index': 0,
            'accountIndex': 0
          }
        },
        {
          'pointer': {
            'id': 'fb869bce80f2baa1b10cb360d677b7dbaba56a6af3607b855b73848de24915b1',
            'index': 1
          },
          'value': {
            'address': 'Ae2tdPwUPEZLWgc7bd75gdNfr24NSFR4X2mEghXLuji6brXGTCFo7vUCTma',
            'value': '2000000'
          },
          'addressing': {
            'change': 0,
            'index': 1,
            'accountIndex': 0
          }
        },
        {
          'pointer': {
            'id': '647cc6c52e192bbaf1ac71226df34f724606f8fe5b81f6f2aa5ad6868665a7fd',
            'index': 2
          },
          'value': {
            'address': 'Ae2tdPwUPEZ3ruXWDNQh7squLAUfDNoK6SMToVHLK26f3sgMNJC1HLgT626',
            'value': '3000000'
          },
          'addressing': {
            'change': 0,
            'index': 2,
            'accountIndex': 0
          }
        },
        {
          'pointer': {
            'id': '5efe355e26734b0e1ee23f61b69bd5e5fc145cf4853d8c5ec8c13d37bf3c8655',
            'index': 3
          },
          'value': {
            'address': 'Ae2tdPwUPEZ3q7rUnMdpDhjWH5xkXPdbGW5hhoWRuPM9rhAX9G5XVHLZds1',
            'value': '2000000'
          },
          'addressing': {
            'change': 0,
            'index': 3,
            'accountIndex': 0
          }
        },
        {
          'pointer': {
            'id': '39954ea98e3d2af94e609020159778031b52c3334428be803b8703e2b555f67d',
            'index': 4
          },
          'value': {
            'address': 'Ae2tdPwUPEZHXuQpkx3nQXfrcr7dYipVGBWvZPG75tozqY2QL589R8C1zvW',
            'value': '1000000'
          },
          'addressing': {
            'change': 0,
            'index': 4,
            'accountIndex': 0
          }
        }
      ],
      'outputs': [
        {
          'address': 'Ae2tdPwUPEZGBjLGCz5zodwQSQm21QrXMZFsFR3iFJyFVAYLK6XUUfZRNVu',
          'value': '198036'
        },
        {
          'address': 'Ae2tdPwUPEZJSYtd7jXPqduaKBdxTLKnXY8eTDJrWegvB7rAoS5EFDya6Eh',
          'value': '200000'
        },
        {
          'address': 'Ae2tdPwUPEZ1HJib4J5jjte5wfcs3zx31vr1AJSnmJoFrdvdtRYB2T9Jdc6',
          'value': '200000'
        }
      ]
    },
    {
      'id': '15d8f7e8c46aea31e1d38ca1144ce5e4a60926d811968980d47ff9b9e835e01a',
      'inputs': [
        {
          'pointer': {
            'id': '16314dce8abf6973e114f24ec75a4376d918a3305127971ad8af989d63d01fc6',
            'index': 0
          },
          'value': {
            'address': 'Ae2tdPwUPEZHXuQpkx3nQXfrcr7dYipVGBWvZPG75tozqY2QL589R8C1zvW',
            'value': '1000000'
          },
          'addressing': {
            'change': 0,
            'index': 4,
            'accountIndex': 0
          }
        },
        {
          'pointer': {
            'id': '7d26a202cb50a0df98bc1749d8ddcb47fb545192f42294a6a12131883577878f',
            'index': 1
          },
          'value': {
            'address': 'Ae2tdPwUPEZJnWY4TjFiL9meehpAEtnyY39orQrPkpeJGvrPfXAoKcvqFUQ',
            'value': '2000000'
          },
          'addressing': {
            'change': 0,
            'index': 5,
            'accountIndex': 0
          }
        },
        {
          'pointer': {
            'id': '851f2931b4640e91cb03a4fda994c5383dee1a5350ebc87ad25c14fbdd5b6c34',
            'index': 2
          },
          'value': {
            'address': 'Ae2tdPwUPEZ6guYM1SN2uhPZnWVKTz91epqeTdvSfJ4ThxfBe59p4xhgVae',
            'value': '3000000'
          },
          'addressing': {
            'change': 0,
            'index': 6,
            'accountIndex': 0
          }
        },
        {
          'pointer': {
            'id': '3a5c577a20161d0280506df9bd77feaae9d9d1e0b9eb4ee5fe593ab6e5af40a6',
            'index': 3
          },
          'value': {
            'address': 'Ae2tdPwUPEZ6JDK3Cisn8YYENZM8xxsDPQAe1SG7nYg2wRiUdb1GuT9zaYH',
            'value': '2000000'
          },
          'addressing': {
            'change': 0,
            'index': 7,
            'accountIndex': 0
          }
        },
        {
          'pointer': {
            'id': '5f5257fe52d5b4a673002af2d43d89fd875d6d3f4a3b78182a0aee07eb657085',
            'index': 4
          },
          'value': {
            'address': 'Ae2tdPwUPEYzTfq1F7xf2SGaiJyPPvZFnVqPzjsUWpjrcjzspU8J2WXqzEE',
            'value': '1000000'
          },
          'addressing': {
            'change': 0,
            'index': 8,
            'accountIndex': 0
          }
        }
      ],
      'outputs': [
        {
          'address': 'Ae2tdPwUPEYztzVbFx9o4sjiXEJ9X1Ro1RVhVABLzcn9ptW7iVfYzoWrS1j',
          'value': '198036'
        },
        {
          'address': 'Ae2tdPwUPEZNHdsZxrSgsuunfXKETPjf37Z68VLDAvC2F5KjqZSr3MPHt6L',
          'value': '200000'
        },
        {
          'address': 'Ae2tdPwUPEZ65KZW6P6ZGEDUJaBWiNiDge1fx48e66Fw7gv1CQ2cmWoL55M',
          'value': '200000'
        }
      ]
    }
  ],
  'utxos': [
    {
      'address': 'Ae2tdPwUPEZLVDTRwkaiXxym6fGpzarZB6JriCYA2jnqP7QvqTLPcYhveai',
      'id': 'a3f78a5855a6f0ab16b98f3c060530d844038b49c95bd259ded57d148397a2f0',
      'index': 0,
      'value': '10000000'
    },
    {
      'address': 'Ae2tdPwUPEZLWgc7bd75gdNfr24NSFR4X2mEghXLuji6brXGTCFo7vUCTma',
      'id': 'a3f78a5855a6f0ab16b98f3c060530d844038b49c95bd259ded57d148397a2f0',
      'index': 0,
      'value': '10000000'
    },
    {
      'address': 'Ae2tdPwUPEZ3ruXWDNQh7squLAUfDNoK6SMToVHLK26f3sgMNJC1HLgT626',
      'id': 'a3f78a5855a6f0ab16b98f3c060530d844038b49c95bd259ded57d148397a2f0',
      'index': 0,
      'value': '10000000'
    },
    {
      'address': 'Ae2tdPwUPEZ3q7rUnMdpDhjWH5xkXPdbGW5hhoWRuPM9rhAX9G5XVHLZds1',
      'id': 'a3f78a5855a6f0ab16b98f3c060530d844038b49c95bd259ded57d148397a2f0',
      'index': 0,
      'value': '10000000'
    },
    {
      'address': 'Ae2tdPwUPEZHXuQpkx3nQXfrcr7dYipVGBWvZPG75tozqY2QL589R8C1zvW',
      'id': 'a3f78a5855a6f0ab16b98f3c060530d844038b49c95bd259ded57d148397a2f0',
      'index': 0,
      'value': '10000000'
    },
    {
      'address': 'Ae2tdPwUPEZHXuQpkx3nQXfrcr7dYipVGBWvZPG75tozqY2QL589R8C1zvW',
      'id': 'a3f78a5855a6f0ab16b98f3c060530d844038b49c95bd259ded57d148397a2f0',
      'index': 0,
      'value': '10000000'
    },
    {
      'address': 'Ae2tdPwUPEZJnWY4TjFiL9meehpAEtnyY39orQrPkpeJGvrPfXAoKcvqFUQ',
      'id': 'a3f78a5855a6f0ab16b98f3c060530d844038b49c95bd259ded57d148397a2f0',
      'index': 0,
      'value': '10000000'
    },
    {
      'address': 'Ae2tdPwUPEZ6guYM1SN2uhPZnWVKTz91epqeTdvSfJ4ThxfBe59p4xhgVae',
      'id': 'a3f78a5855a6f0ab16b98f3c060530d844038b49c95bd259ded57d148397a2f0',
      'index': 0,
      'value': '10000000'
    },
    {
      'address': 'Ae2tdPwUPEZ6JDK3Cisn8YYENZM8xxsDPQAe1SG7nYg2wRiUdb1GuT9zaYH',
      'id': 'a3f78a5855a6f0ab16b98f3c060530d844038b49c95bd259ded57d148397a2f0',
      'index': 0,
      'value': '10000000'
    },
    {
      'address': 'Ae2tdPwUPEYzTfq1F7xf2SGaiJyPPvZFnVqPzjsUWpjrcjzspU8J2WXqzEE',
      'id': 'a3f78a5855a6f0ab16b98f3c060530d844038b49c95bd259ded57d148397a2f0',
      'index': 0,
      'value': '10000000'
    },
    {
      'id': 'a3f78a5855a6f0ab16b98f3c060530d844038b49c95bd259ded57d148397a2f0',
      'index': 0,
      'address': 'Ae2tdPwUPEZGBjLGCz5zodwQSQm21QrXMZFsFR3iFJyFVAYLK6XUUfZRNVu',
      'value': '200000'
    },
    {
      'id': 'a3f78a5855a6f0ab16b98f3c060530d844038b49c95bd259ded57d148397a2f0',
      'index': 1,
      'address': 'Ae2tdPwUPEZJSYtd7jXPqduaKBdxTLKnXY8eTDJrWegvB7rAoS5EFDya6Eh',
      'value': '200000'
    },
    {
      'id': 'a3f78a5855a6f0ab16b98f3c060530d844038b49c95bd259ded57d148397a2f0',
      'index': 2,
      'address': 'Ae2tdPwUPEZ1HJib4J5jjte5wfcs3zx31vr1AJSnmJoFrdvdtRYB2T9Jdc6',
      'value': '200000'
    },
    {
      'id': '15d8f7e8c46aea31e1d38ca1144ce5e4a60926d811968980d47ff9b9e835e01a',
      'index': 3,
      'address': 'Ae2tdPwUPEYztzVbFx9o4sjiXEJ9X1Ro1RVhVABLzcn9ptW7iVfYzoWrS1j',
      'value': '200000'
    },
    {
      'id': '15d8f7e8c46aea31e1d38ca1144ce5e4a60926d811968980d47ff9b9e835e01a',
      'index': 4,
      'address': 'Ae2tdPwUPEZNHdsZxrSgsuunfXKETPjf37Z68VLDAvC2F5KjqZSr3MPHt6L',
      'value': '200000'
    },
    {
      'id': '15d8f7e8c46aea31e1d38ca1144ce5e4a60926d811968980d47ff9b9e835e01a',
      'index': 5,
      'address': 'Ae2tdPwUPEZ65KZW6P6ZGEDUJaBWiNiDge1fx48e66Fw7gv1CQ2cmWoL55M',
      'value': '200000'
    }
  ]
}
