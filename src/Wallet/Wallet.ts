import { Bip44AccountPublic } from 'cardano-wallet'
import { TransactionOutput } from '../Transaction'
import { Provider } from '../Provider'

export function Wallet (_provider: Provider) {
  return (_account: Bip44AccountPublic) => {
    return {
      getNextReceivingAddress: () => new Error('Not yet implemented'),
      getNextChangeAddress: () => new Error('Not yet implemented'),
      balance: () => new Error('Not yet implemented'),
      selectInputsForTransaction: (_outputs: TransactionOutput[]) => new Error('Not yet implemented')
    }
  }
}
