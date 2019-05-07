import { PublicKey } from 'cardano-wallet'
import { getBindingsForEnvironment } from '../lib/bindings'
const { Signature } = getBindingsForEnvironment()

export function verifyMessage ({ publicKey, message, signatureAsHex }: { publicKey: PublicKey, message: string, signatureAsHex: string }) {
  const signature = Signature.from_hex(signatureAsHex)
  return publicKey.verify(Buffer.from(message), signature)
}
