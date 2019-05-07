import { getBindingsForEnvironment } from '../lib/bindings'
const { Signature, PublicKey } = getBindingsForEnvironment()

export function verifyMessage ({ publicKey, message, signature: signatureAsHex }: { publicKey: string, message: string, signature: string }) {
  const signatureInterface = Signature.from_hex(signatureAsHex)
  const publicKeyInterface = PublicKey.from_hex(publicKey)
  return publicKeyInterface.verify(Buffer.from(message), signatureInterface)
}
