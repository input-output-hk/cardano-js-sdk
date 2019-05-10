import * as cardanoNodeBindings from 'cardano-wallet'

function isNode (): boolean {
  try {
    return !!process
  } catch (e) {
    return false
  }
}

export function getBindingsForEnvironment () {
  return isNode()
    ? cardanoNodeBindings
    : require('cardano-wallet-browser') as typeof cardanoNodeBindings
}

export function getRandomBytesForEnvironmentAsHex (byteLength = 32): string {
  if (isNode()) {
    const crypto = require('crypto')
    const buf = crypto.randomBytes(byteLength)
    return buf.toString('hex')
  } else {
    const byteArray = new Uint8Array(byteLength)
    const w = window as any
    const randomBytes = w.crypto.getRandomValues(byteArray)
    return Array
      .from(randomBytes)
      .map((b: any) => b.toString(16).padStart(2, '0'))
      .join('')
  }
}
