import { Bip44AccountPublic } from 'cardano-wallet'
import { getBindingsForEnvironment } from '../../lib/bindings'
import { AddressType } from '..'
const { AddressKeyIndex, Signature } = getBindingsForEnvironment()

export function verifyMessage (
  account: Bip44AccountPublic,
  { addressType, signingIndex, message, signatureAsHex }: { addressType: AddressType, signingIndex: number, message: string, signatureAsHex: string }
): boolean {
  const publicKey = account.address_key(addressType === AddressType.internal, AddressKeyIndex.new(signingIndex))
  const signature = Signature.from_hex(signatureAsHex)
  return publicKey.verify(Buffer.from(message), signature)
}
