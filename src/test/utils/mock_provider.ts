import { Provider } from '../../Provider'
import { TransactionInput, TransactionOutput } from '../../Transaction'
import { Utxo, AddressType, addressDiscoveryWithinBounds } from '../../Wallet'
import { Utils, InMemoryKeyManager } from '../..'
import { generateTestTransaction } from './test_transaction'

let mockUtxoSet: Utxo[] = []
export function seedUtxoSet (utxos: Utxo[]) {
  mockUtxoSet = utxos
}

let mockTransactionSet: { inputs: TransactionInput[], outputs: TransactionOutput[] }[] = []
export function seedTransactionSet (transactions: { inputs: TransactionInput[], outputs: TransactionOutput[] }[]) {
  mockTransactionSet = transactions
}

export function seedMockProvider (utxos: Utxo[], transactions: { inputs: TransactionInput[], outputs: TransactionOutput[] }[]) {
  mockTransactionSet = transactions
  mockUtxoSet = utxos
}

export const mockProvider: Provider = {
  submitTransaction: (_signedTransaction) => Promise.resolve(true),
  queryUtxosByAddress: (addresses) => Promise.resolve(mockUtxoSet.filter(({ address }) => addresses.includes(address))),
  queryTransactionsByAddress: (addresses) => {
    const associatedTransactions = mockTransactionSet.filter(transaction => {
      const inputsExistForAddress = transaction.inputs.filter(input => addresses.includes(input.value.address)).length > 0
      const outputsExistForAddress = transaction.outputs.filter(output => addresses.includes(output.address)).length > 0
      return inputsExistForAddress || outputsExistForAddress
    })
    return Promise.resolve(associatedTransactions)
  }
}

/*
  This seed generates the following "chain state"

  Account 1 = mnemonic1:
  - Some utxos in the first BIP44 range (first 20 addresses), for external addresses
  - Account 1 can be considered a genesis account, as it will have funds available without utxos for transactions in the seed

  Account 2 = mnemonic2
  - No change, only receipt, in the first and second BIP44 ranges (first 40 addresses)

  Account 3 = mnemonic3
  - No utxos
*/
export function logSeed () {
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
    return { address: input.value.address, hash: tx1.transaction.id().to_hex(), value: '1000000' }
  })

  const account2Utxos: Utxo[] = [
    { hash: tx1.transaction.id().to_hex(), address: account2Addresses[0].address, value: '200000' },
    { hash: tx1.transaction.id().to_hex(), address: account2Addresses[5].address, value: '200000' },
    { hash: tx1.transaction.id().to_hex(), address: account2Addresses[10].address, value: '200000' },
    { hash: tx2.transaction.id().to_hex(), address: account2Addresses[15].address, value: '200000' },
    { hash: tx2.transaction.id().to_hex(), address: account2Addresses[20].address, value: '200000' },
    { hash: tx2.transaction.id().to_hex(), address: account2Addresses[25].address, value: '200000' }
  ]

  const seed = {
    accountMnemonics: {
      account1: mnemonic1,
      account2: mnemonic2,
      account3: mnemonic3
    },
    transactions: [
      { inputs: tx1.inputs, outputs: tx1.transaction.toJson().outputs.map((txOut: any) => ({ address: txOut.address, value: String(txOut.value) })) },
      { inputs: tx2.inputs, outputs: tx2.transaction.toJson().outputs.map((txOut: any) => ({ address: txOut.address, value: String(txOut.value) })) }
    ],
    utxos: account1Utxos.concat(account2Utxos)
  }

  console.log(JSON.stringify(seed, null, 4))
}

// Uncomment and run this file with `npx ts-node src/test/utils/mock_provider.ts` to regenerate the seed
// logSeed()
