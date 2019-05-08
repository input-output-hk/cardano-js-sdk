import { Bip44AccountPublic } from 'cardano-wallet'
import { addressDiscoveryWithinBounds, AddressType } from '../../Wallet'
import Transaction, { TransactionInput } from '../../Transaction'
import { estimateTransactionFee } from '../../Utils/estimate_fee'

export function generateTestTransaction (publicAccount: Bip44AccountPublic) {
  const [address1, address2] = addressDiscoveryWithinBounds({
    account: publicAccount,
    type: AddressType.external,
    lowerBound: 0,
    upperBound: 1
  })

  const inputs: TransactionInput[] = [
    {
      pointer: { id: '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef', index: 1 },
      value: { address: address1, value: '1000000' },
      addressing: { account: 0, change: 0, index: 0 }
    },
    {
      pointer: { id: 'fedcba9876543210fedcba9876543210fedcba9876543210fedcba9876543210', index: 0 },
      value: { address: address2, value: '5000000' },
      addressing: { account: 0, change: 0, index: 1 }
    }
  ]

  let outputs = [
    { address: 'Ae2tdPwUPEZCEhYAUVU7evPfQCJjyuwM6n81x6hSjU9TBMSy2YwZEVydssL', value: '6000000' }
  ]

  const fee = estimateTransactionFee(inputs, outputs)
  outputs[0].value = (6000000 - Number(fee)).toString()
  return { transaction: Transaction(inputs, outputs), inputs }
}
