import { Bip44AccountPublic } from 'cardano-wallet'
import { AddressType } from '../../Wallet'
import Transaction, { TransactionInput } from '../../Transaction'
import { addressDiscoveryWithinBounds, estimateTransactionFee } from '../../Utils'

/**
 * generateTestTransaction is a test helper.
 * It can be used to make relatively realistic transactions that can be used for transaction testing or seeding a mock provider.
*/
export function generateTestTransaction ({
  publicAccount,
  testInputs,
  lowerBoundOfAddresses,
  testOutputs,
  inputId
}: {
  publicAccount: Bip44AccountPublic,
  testInputs: { value: string, type: AddressType }[],
  lowerBoundOfAddresses: number,
  testOutputs: { address: string, value: string }[],
  inputId?: string
}) {
  const receiptAddresses = addressDiscoveryWithinBounds({
    account: publicAccount,
    type: AddressType.external,
    lowerBound: lowerBoundOfAddresses,
    upperBound: lowerBoundOfAddresses + testInputs.length
  })

  const changeAddresses = addressDiscoveryWithinBounds({
    account: publicAccount,
    type: AddressType.internal,
    lowerBound: lowerBoundOfAddresses,
    upperBound: lowerBoundOfAddresses + testInputs.length
  })

  const inputs: TransactionInput[] = testInputs.map(({ value }, index) => {
    const { address, index: addressIndex } = testInputs[index].type === AddressType.external
      ? receiptAddresses[index]
      : changeAddresses[index]

    return {
      // Mock a 64 byte transaction id
      pointer: { id: inputId || hexGenerator(64), index },
      value: { address, value },
      addressing: { change: testInputs[index].type === AddressType.internal ? 1 : 0, index: addressIndex }
    }
  })

  const fee = estimateTransactionFee(inputs, testOutputs)

  testOutputs[0].value = (Number(testOutputs[0].value) - Number(fee)).toString()
  return { transaction: Transaction(inputs, testOutputs), inputs }
}

/** Test helper only */
export function hexGenerator (length: number) {
  const maxlen = 8
  const min = Math.pow(16, Math.min(length, maxlen) - 1)
  const max = Math.pow(16, Math.min(length, maxlen)) - 1
  const n = Math.floor(Math.random() * (max - min + 1)) + min
  let r = n.toString(16)
  while (r.length < length) {
    r = r + hexGenerator(length - maxlen)
  }

  return r
}
