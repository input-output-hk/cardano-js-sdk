import { Bip44AccountPublic } from 'cardano-wallet'

export function Wallet(account: Bip44AccountPublic) {
  return {
    getNextReceivingAddress: 1,
    getNextChangeAddress: 1,
    balance: 1,
    balanceTransaction: 1
  }
}