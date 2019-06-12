import { Utils, InMemoryKeyManager } from '../..'
import { AddressType, Utxo } from '../../Wallet'
import { generateTestTransaction } from './test_transaction'
import { addressDiscoveryWithinBounds } from '../../Utils'

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
export async function generateSeed() {
  const mnemonic1 = Utils.generateMnemonic()
  const mnemonic2 = Utils.generateMnemonic()
  const mnemonic3 = Utils.generateMnemonic()

  const account1 = await InMemoryKeyManager({ password: '', mnemonic: mnemonic1 }).publicAccount()
  const account2 = await InMemoryKeyManager({ password: '', mnemonic: mnemonic2 }).publicAccount()

  const account2Addresses = addressDiscoveryWithinBounds({
    account: account2,
    lowerBound: 0,
    upperBound: 39,
    type: AddressType.external
  })

  const tx1 = generateTestTransaction({
    publicAccount: account1,
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
    publicAccount: account1,
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
      { inputs: tx1.inputs, outputs: tx1.transaction.toJson().outputs.map((txOut: any) => ({ address: txOut.address, value: String(txOut.value) })) },
      { inputs: tx2.inputs, outputs: tx2.transaction.toJson().outputs.map((txOut: any) => ({ address: txOut.address, value: String(txOut.value) })) }
    ],
    utxos: account1Utxos.concat(account2Utxos)
  }
}

// Uncomment and run this file with `npx ts-node src/test/utils/mock_provider.ts` to regenerate the seed
// generateSeed().then(r => {
//   console.log(JSON.stringify(r, null, 4))
// })

export const seed = {
  "accountMnemonics": {
    "account1": "access sausage absorb leopard brother wave victory travel confirm draw glimpse animal",
    "account2": "cycle burst badge budget fabric utility napkin salmon rubber knee hunt reform"
  },
  "transactions": [
    {
      "inputs": [
        {
          "pointer": {
            "id": "50c691765a7b18d1681e3ca3160307e8ecb298c09c935ead26e21e51e36329f1",
            "index": 0
          },
          "value": {
            "address": "Ae2tdPwUPEZ6oDR4P2CcWCTzxLiGgQRTezrjFBSPitw4nCDgHbV6iPxQTyk",
            "value": "1000000"
          },
          "addressing": {
            "change": 0,
            "index": 0,
            "accountIndex": 0
          }
        },
        {
          "pointer": {
            "id": "4fa89fff297cbc144729982ab76512c441a6bbbd3d83bb2d29a4395b7bc9dc44",
            "index": 1
          },
          "value": {
            "address": "Ae2tdPwUPEYzrf1toTgJbkEXpvQZ3CCRasPUotJGDp4HjEeK9U4rNiyJ4PL",
            "value": "2000000"
          },
          "addressing": {
            "change": 0,
            "index": 1,
            "accountIndex": 0
          }
        },
        {
          "pointer": {
            "id": "b69742db27f442fe93ca7aef917a45b8ea4bef62b08693ae75d5877bc151ed09",
            "index": 2
          },
          "value": {
            "address": "Ae2tdPwUPEZ5qQN7ZMrbf52GzsCXSPzfwxFKexJFyGBbKZXb9hQPxh5h89S",
            "value": "3000000"
          },
          "addressing": {
            "change": 0,
            "index": 2,
            "accountIndex": 0
          }
        },
        {
          "pointer": {
            "id": "8cd009c79fd855b8517584692f78618173e4cb06150b4e3a180252ab6f089324",
            "index": 3
          },
          "value": {
            "address": "Ae2tdPwUPEZCB5tJAHkszVk3hWDZEPuQGEYqs5T1ieXGeMMCmvqKzk6X1oJ",
            "value": "2000000"
          },
          "addressing": {
            "change": 0,
            "index": 3,
            "accountIndex": 0
          }
        },
        {
          "pointer": {
            "id": "8882a06acc04f1c2c3e9c284a29fa0b4b551cbeeb69e665b9762e2ef6846bfaa",
            "index": 4
          },
          "value": {
            "address": "Ae2tdPwUPEZ7UVopLf3cA62JjQhAoQJSHLUbPcBhTLrwbZrW6o6yRu7ha5s",
            "value": "1000000"
          },
          "addressing": {
            "change": 0,
            "index": 4,
            "accountIndex": 0
          }
        }
      ],
      "outputs": [
        {
          "address": "Ae2tdPwUPEZLbgtNSaBHc3LEUCaF1GSE1ZgHDApYfgHMo37DGTUZ3Yz47ir",
          "value": "198036"
        },
        {
          "address": "Ae2tdPwUPEZLanS6tvrZGLqy5dQLtTtB3xTCLtQy226V7YAk3SDgwt9V9AZ",
          "value": "200000"
        },
        {
          "address": "Ae2tdPwUPEZA3mqVuZvzzk28D4uwLkkbj8LpMHVQ9BeGoW8Smi6mzpnKu5n",
          "value": "200000"
        }
      ]
    },
    {
      "inputs": [
        {
          "pointer": {
            "id": "645d49b533c54df44ab1380042a35306131ffde58474664ac5681f4e25be5952",
            "index": 0
          },
          "value": {
            "address": "Ae2tdPwUPEZ7UVopLf3cA62JjQhAoQJSHLUbPcBhTLrwbZrW6o6yRu7ha5s",
            "value": "1000000"
          },
          "addressing": {
            "change": 0,
            "index": 4,
            "accountIndex": 0
          }
        },
        {
          "pointer": {
            "id": "5c49483b9016b197da7b8537e9d41a561a381c5f68d9385ea74d17a0a81f54e4",
            "index": 1
          },
          "value": {
            "address": "Ae2tdPwUPEZN9QPGcGdkrwsS8apBPosQyRBLQMrZ2JW67wY1ndQvbe6Sjn6",
            "value": "2000000"
          },
          "addressing": {
            "change": 0,
            "index": 5,
            "accountIndex": 0
          }
        },
        {
          "pointer": {
            "id": "27adf8b485a20619690dd32f56fbabcead058c8ec4c8a7cc2108b54fe4425127",
            "index": 2
          },
          "value": {
            "address": "Ae2tdPwUPEZCe9QR4svAfHN7Rrr9NUX5V5pDY97oe4PSFbPfbgCEzvMa55R",
            "value": "3000000"
          },
          "addressing": {
            "change": 0,
            "index": 6,
            "accountIndex": 0
          }
        },
        {
          "pointer": {
            "id": "633ea0126b27f4d2e8d97bb79a845e1c89248bdafdeccdacaf65d248e7ad38e9",
            "index": 3
          },
          "value": {
            "address": "Ae2tdPwUPEZ4H5sZ5AJRfrUpXGiCbpGzHGopkcGV9Tdq6iJKYsn2TYmRDra",
            "value": "2000000"
          },
          "addressing": {
            "change": 0,
            "index": 7,
            "accountIndex": 0
          }
        },
        {
          "pointer": {
            "id": "3597d347557f4c6cf37c3879f93dc46a92b3d17139ef3e1e7e3330d78452dfbc",
            "index": 4
          },
          "value": {
            "address": "Ae2tdPwUPEZLVRMEve2GjWbxGfFm9ws577j68cttrL9UfYLhUv4zrf53Mrh",
            "value": "1000000"
          },
          "addressing": {
            "change": 0,
            "index": 8,
            "accountIndex": 0
          }
        }
      ],
      "outputs": [
        {
          "address": "Ae2tdPwUPEYyhqEXhcYHWZsSwFkeJdiYkNPf2xEyAprzQ9wfruoA3avMVGY",
          "value": "198036"
        },
        {
          "address": "Ae2tdPwUPEZLtX243BCbEWi4nwdAvcv274GQxmxJpB1FR2UBiy3HHmopD1R",
          "value": "200000"
        },
        {
          "address": "Ae2tdPwUPEZ3QJWHcWh9gAaacB6rkdHLkxEvUEwMJ6gYRfTshnN7xazAb2P",
          "value": "200000"
        }
      ]
    }
  ],
  "utxos": [
    {
      "address": "Ae2tdPwUPEZ6oDR4P2CcWCTzxLiGgQRTezrjFBSPitw4nCDgHbV6iPxQTyk",
      "id": "edad308e5d8e0047ef501aef84267646367cc524cdc333dbbb348739594c8de9",
      "index": 0,
      "value": "10000000"
    },
    {
      "address": "Ae2tdPwUPEYzrf1toTgJbkEXpvQZ3CCRasPUotJGDp4HjEeK9U4rNiyJ4PL",
      "id": "edad308e5d8e0047ef501aef84267646367cc524cdc333dbbb348739594c8de9",
      "index": 0,
      "value": "10000000"
    },
    {
      "address": "Ae2tdPwUPEZ5qQN7ZMrbf52GzsCXSPzfwxFKexJFyGBbKZXb9hQPxh5h89S",
      "id": "edad308e5d8e0047ef501aef84267646367cc524cdc333dbbb348739594c8de9",
      "index": 0,
      "value": "10000000"
    },
    {
      "address": "Ae2tdPwUPEZCB5tJAHkszVk3hWDZEPuQGEYqs5T1ieXGeMMCmvqKzk6X1oJ",
      "id": "edad308e5d8e0047ef501aef84267646367cc524cdc333dbbb348739594c8de9",
      "index": 0,
      "value": "10000000"
    },
    {
      "address": "Ae2tdPwUPEZ7UVopLf3cA62JjQhAoQJSHLUbPcBhTLrwbZrW6o6yRu7ha5s",
      "id": "edad308e5d8e0047ef501aef84267646367cc524cdc333dbbb348739594c8de9",
      "index": 0,
      "value": "10000000"
    },
    {
      "address": "Ae2tdPwUPEZ7UVopLf3cA62JjQhAoQJSHLUbPcBhTLrwbZrW6o6yRu7ha5s",
      "id": "edad308e5d8e0047ef501aef84267646367cc524cdc333dbbb348739594c8de9",
      "index": 0,
      "value": "10000000"
    },
    {
      "address": "Ae2tdPwUPEZN9QPGcGdkrwsS8apBPosQyRBLQMrZ2JW67wY1ndQvbe6Sjn6",
      "id": "edad308e5d8e0047ef501aef84267646367cc524cdc333dbbb348739594c8de9",
      "index": 0,
      "value": "10000000"
    },
    {
      "address": "Ae2tdPwUPEZCe9QR4svAfHN7Rrr9NUX5V5pDY97oe4PSFbPfbgCEzvMa55R",
      "id": "edad308e5d8e0047ef501aef84267646367cc524cdc333dbbb348739594c8de9",
      "index": 0,
      "value": "10000000"
    },
    {
      "address": "Ae2tdPwUPEZ4H5sZ5AJRfrUpXGiCbpGzHGopkcGV9Tdq6iJKYsn2TYmRDra",
      "id": "edad308e5d8e0047ef501aef84267646367cc524cdc333dbbb348739594c8de9",
      "index": 0,
      "value": "10000000"
    },
    {
      "address": "Ae2tdPwUPEZLVRMEve2GjWbxGfFm9ws577j68cttrL9UfYLhUv4zrf53Mrh",
      "id": "edad308e5d8e0047ef501aef84267646367cc524cdc333dbbb348739594c8de9",
      "index": 0,
      "value": "10000000"
    },
    {
      "id": "edad308e5d8e0047ef501aef84267646367cc524cdc333dbbb348739594c8de9",
      "index": 0,
      "address": "Ae2tdPwUPEZLbgtNSaBHc3LEUCaF1GSE1ZgHDApYfgHMo37DGTUZ3Yz47ir",
      "value": "200000"
    },
    {
      "id": "edad308e5d8e0047ef501aef84267646367cc524cdc333dbbb348739594c8de9",
      "index": 1,
      "address": "Ae2tdPwUPEZLanS6tvrZGLqy5dQLtTtB3xTCLtQy226V7YAk3SDgwt9V9AZ",
      "value": "200000"
    },
    {
      "id": "edad308e5d8e0047ef501aef84267646367cc524cdc333dbbb348739594c8de9",
      "index": 2,
      "address": "Ae2tdPwUPEZA3mqVuZvzzk28D4uwLkkbj8LpMHVQ9BeGoW8Smi6mzpnKu5n",
      "value": "200000"
    },
    {
      "id": "9224942d944020ab1abdd6c19046201a316d1846e2269e082b3bde537d1a8a20",
      "index": 3,
      "address": "Ae2tdPwUPEYyhqEXhcYHWZsSwFkeJdiYkNPf2xEyAprzQ9wfruoA3avMVGY",
      "value": "200000"
    },
    {
      "id": "9224942d944020ab1abdd6c19046201a316d1846e2269e082b3bde537d1a8a20",
      "index": 4,
      "address": "Ae2tdPwUPEZLtX243BCbEWi4nwdAvcv274GQxmxJpB1FR2UBiy3HHmopD1R",
      "value": "200000"
    },
    {
      "id": "9224942d944020ab1abdd6c19046201a316d1846e2269e082b3bde537d1a8a20",
      "index": 5,
      "address": "Ae2tdPwUPEZ3QJWHcWh9gAaacB6rkdHLkxEvUEwMJ6gYRfTshnN7xazAb2P",
      "value": "200000"
    }
  ]
}
