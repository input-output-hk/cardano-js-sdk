import { Bip44AccountPublic } from 'cardano-wallet'
import { TransactionOutput } from '../Transaction'

export function Wallet (_account: Bip44AccountPublic) {
  return {
    getNextReceivingAddress: () => new Error('Not yet implemented'),
    getNextChangeAddress: () => new Error('Not yet implemented'),
    balance: () => new Error('Not yet implemented'),
    balanceTransaction: (_outputs: TransactionOutput[]) => new Error('Not yet implemented')
  }
}
