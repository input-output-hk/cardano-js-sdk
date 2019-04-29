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
