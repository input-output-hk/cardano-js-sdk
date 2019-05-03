import { Bip44AccountPublic } from 'cardano-wallet'
import { TransactionOutput } from '../Transaction'
import { AddressType } from '.'
import { verifyMessage } from './lib/verify_message'

export function Wallet (account: Bip44AccountPublic) {
  return {
    getNextReceivingAddress: () => getNextReceivingAddress(account),
    getNextChangeAddress: () => getNextChangeAddress(account),
    balance: () => balance(account),
    balanceTransaction: (outputs: TransactionOutput[]) => balanceTransaction(account, outputs),
    verifyMessage: (verificationArgs: { addressType: AddressType, signingIndex: number, message: string, signatureAsHex: string }) => verifyMessage(account, verificationArgs)
  }
}

function getNextReceivingAddress (_account: Bip44AccountPublic) {
  throw new Error('Not yet implemented')
}

function getNextChangeAddress (_account: Bip44AccountPublic) {
  throw new Error('Not yet implemented')
}

function balance (_account: Bip44AccountPublic) {
  throw new Error('Not yet implemented')
}

function balanceTransaction (_account: Bip44AccountPublic, _outputs: TransactionOutput[]) {
  throw new Error('Not yet implemented')
}
