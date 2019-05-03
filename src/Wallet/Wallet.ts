import { Bip44AccountPublic } from 'cardano-wallet'
import { TransactionOutput } from '../Transaction'
import { AddressType } from '.'
import { getBindingsForEnvironment } from '../lib/bindings'
const { AddressKeyIndex, Signature } = getBindingsForEnvironment()

export function Wallet (account: Bip44AccountPublic) {
  return {
    getNextReceivingAddress: () => new Error('Not yet implemented'),
    getNextChangeAddress: () => new Error('Not yet implemented'),
    balance: () => new Error('Not yet implemented'),
    balanceTransaction: (_outputs: TransactionOutput[]) => new Error('Not yet implemented'),
    verifyMessage: ({ addressType, signingIndex, message, signatureAsHex }: { addressType: AddressType, signingIndex: number, message: string, signatureAsHex: string }) => {
      const publicKey = account.address_key(addressType === AddressType.internal, AddressKeyIndex.new(signingIndex))
      const signature = Signature.from_hex(signatureAsHex)
      return publicKey.verify(Buffer.from(message), signature)
    }
  }
}
